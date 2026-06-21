import Foundation

// =====================================================================
// Soma — Vetted First-Aid Rulebook  sourced + attributed)
// ---------------------------------------------------------------------
// Content authored/verified by the team from cited authorities
// (Mayo Clinic, American Red Cross, Cleveland Clinic, CDC, NIH, AAAAI...).
// The AI never writes these — it only SELECTS the entry by `kind`.
//
// Each guide has:
//   • shortSteps  — panic-appropriate, shown on the card by default
//   • whenToCall  — the "call 911 if…" trigger line
//   • avoid       — key "do NOT" notes (high-value safety content)
//   • source      — attribution (what makes this "guides, not decides")
// Full long-form protocols live in the team's source doc; the card stays
// scannable so a panicking user can actually use it.
// =====================================================================

struct AidGuide: Hashable {
    let title: String
    let source: String
    let whenToCall: String
    let shortSteps: [String]
    let avoid: [String]
}

enum Rulebook {
    static func guide(for kind: AidKind) -> AidGuide { table[kind] ?? table[.unknown]! }

    static let table: [AidKind: AidGuide] = [

        .cardiac: AidGuide(
            title: "Not breathing — start CPR",
            source: "American Red Cross · Mayo Clinic · AHA",
            whenToCall: "Call 911 now if they're unresponsive, not breathing, or have no pulse.",
            shortSteps: [
                "Lay them flat on a hard surface.",
                "Push hard and fast in the centre of the chest — about twice a second, 2 inches deep.",
                "Let the chest rise fully between pushes; aim for 30 at a time.",
                "If trained, give 2 rescue breaths after each 30.",
                "Send someone for an AED and follow its spoken prompts.",
                "Don't stop until they wake or help arrives."],
            avoid: ["Don't pause compressions to keep checking for a pulse."]),

        .choking: AidGuide(
            title: "Choking — clear the airway",
            source: "American Red Cross · Cleveland Clinic · Mayo Clinic",
            whenToCall: "Call 911 if they can't cough, speak, or breathe, or turn blue/grey.",
            shortSteps: [
                "If they're coughing forcefully, let them — don't intervene yet.",
                "If they can't breathe: 5 firm back blows between the shoulder blades.",
                "Then 5 abdominal thrusts (Heimlich), just above the navel.",
                "Keep alternating 5 and 5 until it clears.",
                "For a pregnant or large person, give chest thrusts instead.",
                "If they go unconscious, start CPR."],
            avoid: ["Don't reach blindly into the mouth.", "Don't give water."]),

        .stroke: AidGuide(
            title: "Stroke — note the time (B.E.F.A.S.T.)",
            source: "CDC · American Stroke Association · Mayo Clinic",
            whenToCall: "Call 911 at the first sign — Balance, Eyes, Face droop, Arm weakness, Speech.",
            shortSteps: [
                "Write down the exact time symptoms started.",
                "Keep them sitting up, calm and still.",
                "Keep them awake — don't let them sleep.",
                "Watch their breathing; if it stops, start CPR."],
            avoid: ["Don't give food, drink, or medication (incl. aspirin).",
                    "Don't 'wait and see' — minutes matter."]),

        .anaphylaxis: AidGuide(
            title: "Allergic reaction — use adrenaline",
            source: "Mayo Clinic · Red Cross · Cleveland Clinic · AAAAI",
            whenToCall: "Call 911 immediately if breathing, throat, or swelling symptoms appear.",
            shortSteps: [
                "Use their epinephrine auto-injector (EpiPen) into the outer thigh, hold ~3 sec.",
                "Help them lie down; loosen tight clothing; keep them warm.",
                "Note the time given.",
                "A second dose after 5 min if no improvement and EMS hasn't arrived.",
                "If they stop breathing or moving, start CPR."],
            avoid: ["Do NOT give water."]),

        .bleeding: AidGuide(
            title: "Serious bleeding — apply pressure",
            source: "Mayo Clinic · American Red Cross · Harvard Health",
            whenToCall: "Call 911 if blood is gushing or won't stop with pressure.",
            shortSteps: [
                "Press firmly on the wound with a clean cloth and your palm.",
                "Keep pressing — don't lift to check it.",
                "Raise the injured part above the heart if you can.",
                "If blood soaks through, add more cloth on top — don't remove the first.",
                "If trained, use a tourniquet on a limb and note the time."],
            avoid: ["Don't remove deeply embedded objects.",
                    "Don't apply pressure to an eye or suspected skull fracture."]),

        .seizure: AidGuide(
            title: "Seizure — keep them safe",
            source: "Epilepsy Foundation · American Red Cross",
            whenToCall: "Call 911 if it lasts over 5 min, repeats, or they don't wake afterward.",
            shortSteps: [
                "Move hard or sharp objects away.",
                "Cushion their head with something soft.",
                "Time how long it lasts.",
                "When it stops, gently roll them onto their side."],
            avoid: ["Don't hold them down.", "Don't put anything in their mouth."]),

        .overdose: AidGuide(
            title: "Overdose — protect breathing",
            source: "SAMHSA · American Red Cross",
            whenToCall: "Call 911 if they're hard to wake or breathing slowly.",
            shortSteps: [
                "Give naloxone (Narcan) if available.",
                "Lay them on their side (recovery position).",
                "Watch their breathing closely.",
                "Start CPR if breathing stops."],
            avoid: ["Don't leave them alone."]),

        .burn: AidGuide(
            title: "Burn — cool it",
            source: "American Red Cross · Mayo Clinic",
            whenToCall: "Call 911 for large, deep, or facial/airway burns.",
            shortSteps: [
                "Cool under cool running water for 20 minutes.",
                "Remove rings or tight items near the burn.",
                "Cover loosely with cling film or a clean cloth."],
            avoid: ["Don't use ice, butter, or creams."]),

        .drowning: AidGuide(
            title: "Drowning — breathe for them",
            source: "American Red Cross",
            whenToCall: "Call 911 immediately.",
            shortSteps: [
                "Get them out of the water safely.",
                "If not breathing, give rescue breaths and start CPR.",
                "Keep them warm; if they vomit, roll them on their side."],
            avoid: []),

        .minor: AidGuide(
            title: "Minor injury — keep comfortable",
            source: "American Red Cross",
            whenToCall: "Call 911 if it worsens, won't stop bleeding, or they feel faint.",
            shortSteps: [
                "Keep them calm and still.",
                "Clean the area gently.",
                "Apply ice wrapped in cloth to reduce swelling."],
            avoid: []),

        .unknown: AidGuide(
            title: "Stay with them",
            source: "General first-aid guidance",
            whenToCall: "Call 911 and stay on the line.",
            shortSteps: [
                "Keep them calm and still.",
                "Don't move them unless they're in danger.",
                "Watch their breathing.",
                "Follow the dispatcher."],
            avoid: [])
    ]

    // Ash's synthetic test scenarios — feed these to the engine/LLM to verify.
    static let testScenarios: [String] = [
        "My grandfather just collapsed. He's not waking up and I can't tell if he's breathing.",
        "My dad was complaining about chest pressure and feeling dizzy. He suddenly dropped to the floor. His breathing sounds weird and gaspy.",
        "My little brother is grabbing his throat and can't talk.",
        "My friend is coughing really hard after swallowing a piece of steak.",
        "My sister ate peanuts and now her lips are swelling and she's having trouble breathing.",
        "My friend got stung by a bee. At first he seemed okay, but now he's dizzy and says his throat feels tight.",
        "My grandma's face looks crooked and she can't lift one arm.",
        "My dad suddenly can't get his words out. He knows what he wants to say but it's coming out wrong.",
        "My friend cut his leg on broken glass and blood is pouring out.",
        "My cousin was using a chainsaw and there is blood soaking through towels we keep putting on."
    ]
}
