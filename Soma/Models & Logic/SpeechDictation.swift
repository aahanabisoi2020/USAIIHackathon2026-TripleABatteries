import Foundation
import Speech
import AVFoundation
import Combine

// =====================================================================
// Soma — live dictation (Apple Speech framework, on-device when available)
//   Tap to start, tap to stop; transcript streams into `text`.
// =====================================================================

@MainActor
final class SpeechDictation: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording = false

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let engine = AVAudioEngine()

    func toggle() { isRecording ? stop() : start() }

    func start() {
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else { return }
            Task { @MainActor in self.begin() }
        }
    }

    private func begin() {
        transcript = ""
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)

        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true
        guard let request, let recognizer, recognizer.isAvailable else { return }

        let input = engine.inputNode
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: input.outputFormat(forBus: 0)) { buffer, _ in
            request.append(buffer)
        }
        engine.prepare()
        try? engine.start()
        isRecording = true

        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let result { Task { @MainActor in self.transcript = result.bestTranscription.formattedString } }
            if error != nil || (result?.isFinal ?? false) {
                Task { @MainActor in self.stop() }
            }
        }
    }

    func stop() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil; task = nil
        isRecording = false
    }
}
