import Foundation

// =====================================================================
// Soma — LLM interpretation (Google Gemini)  [primary brain]
// ---------------------------------------------------------------------
// Sends the caller's messy text to Gemini and parses a structured
// Assessment (same shape the rule engine returns). On ANY failure
// (no key, no network, bad JSON) the caller falls back to the offline
// TriageEngine, so the app never depends on the cloud to function.
//
// Privacy: only the live emergency description is sent — never profile data.
// =====================================================================

enum LLMTriage {
    private static let apiKey = "AQ.Ab8RN6KCn4k9GqcUh4UrA3S-C5M1QENH3y9r72HceAYeY60PRw"
    private static let model  = "gemini-1.5-flash"

    private static var endpoint: URL {
        URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)")!
    }

    // The instruction that turns messy panic speech into our exact fields.
    // Constrained hard: JSON only, no invented facts, unknowns marked,
    // and a calibrated confidence so the gate can escalate when unsure.
    private static func prompt(for text: String) -> String {
        """
        You are an emergency triage interpreter. Read the caller's words and
        return ONLY a JSON object (no prose, no markdown) with these keys:
        {
          "situation": string,          // short label, e.g. "Possible seizure"
          "kind": one of ["cardiac","choking","stroke","seizure","anaphylaxis","bleeding","overdose","burn","drowning","minor","unknown"],
          "severity": one of ["CRITICAL","URGENT","NOT CERTAIN"],
          "confidence": number 0-1,     // how sure you are; be honest, low if vague
          "reasoning": string,          // one short sentence, plain language
          "person": string,             // e.g. "Adult" or "Not stated" if not said
          "responsive": one of ["Yes","No","Unknown"],
          "duration": string            // e.g. "~3 min" or "Not stated"
        }
        Rules: use ONLY facts the caller stated; never invent age, gender,
        duration, or responsiveness. If unclear or life-threatening, prefer a
        higher severity and a lower confidence so a human is brought in.
        Do NOT give medical instructions — only interpret and classify.

        Caller said: "\(text)"
        """
    }

    // Decoding shape that matches the prompt's JSON.
    private struct Raw: Codable {
        let situation: String
        let kind: String
        let severity: String
        let confidence: Double
        let reasoning: String
        let person: String
        let responsive: String
        let duration: String
    }

    /// Try Gemini; return nil on any failure so the caller can fall back.
    static func assess(_ text: String) async -> Assessment? {
        guard apiKey != "YOUR_GEMINI_API_KEY", !text.isEmpty else { return nil }

        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt(for: text)]]]],
            "generationConfig": [
                "temperature": 0.2,
                "responseMimeType": "application/json"
            ]
        ]

        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else { return nil }

            // Gemini wraps the model text in candidates[].content.parts[].text
            guard
                let top = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let candidates = top["candidates"] as? [[String: Any]],
                let content = candidates.first?["content"] as? [String: Any],
                let parts = content["parts"] as? [[String: Any]],
                let jsonText = parts.first?["text"] as? String,
                let jsonData = jsonText.data(using: .utf8)
            else { return nil }

            let raw = try JSONDecoder().decode(Raw.self, from: jsonData)
            return map(raw, rawText: text)
        } catch {
            return nil
        }
    }

    private static func map(_ r: Raw, rawText: String) -> Assessment {
        let kind = AidKind(rawValue: r.kind) ?? .unknown
        let sev  = Severity(rawValue: r.severity) ?? .urgent
        let conf = min(1, max(0, r.confidence))
        return Assessment(
            situation: r.situation.isEmpty ? "Unclear — needs assessment" : r.situation,
            kind: kind, severity: sev, confidence: conf,
            reasoning: r.reasoning, person: r.person.isEmpty ? "Not stated" : r.person,
            responsive: ["Yes","No","Unknown"].contains(r.responsive) ? r.responsive : "Unknown",
            duration: r.duration.isEmpty ? "Not stated" : r.duration,
            rawText: rawText)
    }
}
