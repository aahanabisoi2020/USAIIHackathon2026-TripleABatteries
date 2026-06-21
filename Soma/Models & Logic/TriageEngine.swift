import Foundation

// =====================================================================
// Soma — Triage & Interpretation Engine
// ---------------------------------------------------------------------
// Merges RoundedSquid's offline rule engine with Soma's data model.
// Design principles:
//   • INTERPRET what the caller said; never invent facts (unstated -> nil).
//   • Detect clinical SIGNS flexibly (regex on signs, not rigid phrases).
//   • Fail safe: when unsure, LOW confidence -> escalate to a human.
//   • Steps are SELECTED from a sourced, attributed rulebook — never authored here.
// This engine is the offline fallback / structuring layer. A hosted or
// on-device LLM can replace `assess()` later; it returns the same Assessment.
// =====================================================================

// MARK: - Severity
enum Severity: String, Codable, Hashable {
    case critical   = "CRITICAL"
    case urgent     = "URGENT"
    case notCertain = "NOT CERTAIN"
}

// MARK: - Condition kind (used to key the sourced rulebook)
enum AidKind: String, Codable, Hashable {
    case cardiac, choking, stroke, seizure, anaphylaxis, bleeding
    case overdose, burn, drowning, minor, unknown
}

// MARK: - The structured result the whole app runs on.
// (This is Soma's Assessment, extended with the engine's richer fields.)
struct Assessment: Codable, Hashable {
    var situation: String          // e.g. "Possible seizure"
    var kind: AidKind              // keys the rulebook
    var severity: Severity
    var confidence: Double         // 0.0 - 1.0  (gate reads this)
    var reasoning: String          // short "why", shown as transparency
    var person: String             // "Not stated" if caller didn't say
    var responsive: String         // "Yes" / "No" / "Unknown"
    var duration: String           // "Not stated" if not said
    var rawText: String            // what the caller actually said

    // Convenience for the confidence gate
    var confidencePercent: Int { Int((confidence * 100).rounded()) }

    static let sampleSeizure = Assessment(
        situation: "Possible seizure", kind: .seizure, severity: .urgent,
        confidence: 0.80, reasoning: "Convulsions described — protect head, time it.",
        person: "Adult", responsive: "No", duration: "~3 min",
        rawText: "she fell and she's shaking and won't respond")

    static let lowConfidence = Assessment(
        situation: "Unclear — needs assessment", kind: .unknown, severity: .urgent,
        confidence: 0.40, reasoning: "Not enough detail — escalating by default.",
        person: "Not stated", responsive: "Unknown", duration: "Not stated",
        rawText: "something's wrong, come quick")
}

// MARK: - Engine
enum TriageEngine {

    private static func has(_ t: String, _ p: String) -> Bool {
        t.range(of: p, options: .regularExpression) != nil
    }

    // ---- Extractors: report ONLY what was actually stated ----
    private static func gender(_ t: String) -> String? {
        if has(t, "\\b(she|her|woman|women|female|girl|lady|mother|mom|wife|daughter|sister|grandmother|aunt)\\b") { return "Female" }
        if has(t, "\\b(he|him|his|man|men|male|boy|guy|father|dad|husband|son|brother|grandfather|uncle)\\b") { return "Male" }
        return nil
    }
    private static func age(_ t: String) -> String? {
        if has(t, "\\b(baby|infant|newborn)\\b") { return "infant" }
        if has(t, "\\b(child|kid|toddler|teen|teenager)\\b") { return "child" }
        if has(t, "\\b(elderly|old man|old woman|grandmother|grandfather|senior)\\b") { return "elderly" }
        if has(t, "\\b(man|woman|adult|guy|lady)\\b") { return "adult" }
        return nil
    }
    private static func responsive(_ t: String) -> String {
        if has(t, "won'?t respond|not responding|unrespons|unconscious|passed out|won'?t wake|no response|not moving|out cold") { return "No" }
        if has(t, "talking|conscious|responsive|awake|alert|answering|can stand|walking|coherent") { return "Yes" }
        return "Unknown"
    }
    private static func duration(_ t: String) -> String? {
        if let r = t.range(of: "\\d+\\+?\\s*(second|minute|min|hour|hr)s?", options: .regularExpression) { return String(t[r]) }
        if has(t, "\\bjust (now|happened|collapsed|started)\\b") { return "Just now" }
        return nil
    }

    // ---- Sign-based classifier, resolved most-acute-first ----
    private struct Sit { let situation: String; let kind: AidKind; let severity: Severity; let conf: Double; let why: String }

    private static func classify(_ t: String) -> Sit {
        // Stroke (FAST) — independent signs so any phrasing scores
        let faceDroop = (has(t, "droop|drooping|sag|sagging") && has(t, "face|mouth|smile|cheek|lip|jaw|eye"))
            || has(t, "(uneven|lopsided|crooked|asymmetr)\\s*(smile|face|mouth|grin)")
        let slurred = has(t, "slur|garbled|jumbled|trouble speaking|can'?t speak|not making sense|talking funny")
        let sideWeak = (has(t, "\\b(left|right|one)\\s+(side|arm|leg|hand|foot)\\b") && has(t, "weak|numb|droop|can'?t (lift|move|feel)|heavy|paralyz|limp"))
        let anySide = has(t, "\\b(left|right|one)\\s+side\\b")
        let strokeScore = (faceDroop ? 2 : 0) + (slurred ? 2 : 0) + (sideWeak ? 2 : 0) + (((faceDroop || sideWeak) && anySide) ? 1 : 0)

        if has(t, "not breathing|stopped breathing|isn'?t breathing|no pulse|no heartbeat|cardiac arrest|turning blue") {
            return Sit(situation: "Suspected cardiac arrest", kind: .cardiac, severity: .critical, conf: 0.94, why: "No breathing reported — time-critical.")
        }
        if has(t, "chok|something stuck|can'?t breathe|cannot breathe|airway|hands? (at|around) (the )?throat") {
            return Sit(situation: "Choking / airway obstruction", kind: .choking, severity: .critical, conf: 0.90, why: "Airway may be blocked.")
        }
        if has(t, "anaphyla|allergic reaction|throat.{0,12}(closing|swelling|tight)|lips? swelling|epipen") {
            return Sit(situation: "Suspected anaphylaxis", kind: .anaphylaxis, severity: .critical, conf: 0.86, why: "Airway swelling described.")
        }
        if has(t, "drown|underwater|pulled (from|out of) (the )?water|submerged") {
            return Sit(situation: "Drowning", kind: .drowning, severity: .critical, conf: 0.88, why: "Water/airway involvement.")
        }
        if strokeScore >= 2 {
            return Sit(situation: "Suspected stroke (FAST signs)", kind: .stroke, severity: .urgent, conf: min(0.92, 0.72 + Double(strokeScore) * 0.05), why: "Face/speech/limb signs — onset time matters.")
        }
        if (has(t, "chest") && has(t, "pain|tight|pressure|grab|clutch|crush")) || has(t, "heart attack") {
            return Sit(situation: "Suspected heart attack", kind: .cardiac, severity: .urgent, conf: 0.84, why: "Cardiac chest pain pattern.")
        }
        if has(t, "seiz|convuls|epilep|\\bfit\\b|jerking|thrashing") {
            return Sit(situation: "Possible seizure", kind: .seizure, severity: .urgent, conf: 0.80, why: "Convulsions described — protect head, time it.")
        }
        if has(t, "bleed|losing (a lot of )?blood|stab|gunshot|shot|haemorrhage|hemorrhage|deep cut|spurting") {
            return Sit(situation: "Serious bleeding / trauma", kind: .bleeding, severity: .urgent, conf: 0.80, why: "Significant blood loss.")
        }
        if has(t, "overdose|too many pills|took.{0,10}pills|fentanyl|heroin|naloxone|narcan|od'?ed") {
            return Sit(situation: "Suspected overdose", kind: .overdose, severity: .urgent, conf: 0.78, why: "Overdose indicators.")
        }
        if has(t, "burn|on fire|scald|electrocut") {
            return Sit(situation: "Burn injury", kind: .burn, severity: .urgent, conf: 0.70, why: "Burn described.")
        }
        if has(t, "ankle|sprain|twist|bruise|scratch|minor cut|sore|stubbed") && has(t, "can stand|walking|fine|not (that )?bad|talking|okay|ok\\b") {
            return Sit(situation: "Minor injury", kind: .minor, severity: .notCertain, conf: 0.42, why: "Low-acuity signs; monitor.")
        }
        if has(t, "fell|fall|collapse|faint|fainted|passed out") {
            return Sit(situation: "Collapse / fall — cause unclear", kind: .unknown, severity: .urgent, conf: 0.58, why: "Cause unclear — do not assume.")
        }
        return Sit(situation: "Unclear — needs assessment", kind: .unknown, severity: .urgent, conf: 0.50, why: "Not enough detail — escalating by default.")
    }

    // ---- Public: messy text -> structured Assessment (offline) ----
    static func assess(_ raw: String) -> Assessment {
        let t = raw.lowercased()
        let s = classify(t)
        let g = gender(t), a = age(t)
        let person = [g, a].compactMap { $0 }.joined(separator: ", ")
        return Assessment(
            situation: s.situation, kind: s.kind, severity: s.severity,
            confidence: s.conf, reasoning: s.why,
            person: person.isEmpty ? "Not stated" : person,
            responsive: responsive(t),
            duration: duration(t) ?? "Not stated",
            rawText: raw)
    }
}
