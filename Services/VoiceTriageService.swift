import Foundation
import AVFoundation
import Speech

/// VoiceTriageService manages AI-powered voice triage using CallLinc healthcare AI.
/// Handles real-time voice recognition, WebSocket communication, and audio playback.
///
/// ## Features:
/// - Real-time Arabic speech recognition
/// - WebSocket-based AI communication
/// - Audio response playback
/// - Conversation history management
/// - Facility recommendations
///
/// ## Usage:
/// ```swift
/// let service = VoiceTriageService.shared
/// await service.connect()
/// service.sendTextMessage("I have a headache")
/// ```
class VoiceTriageService: NSObject, ObservableObject {
    static let shared = VoiceTriageService()

    @Published var isConnected = false
    @Published var isRecording = false
    @Published var isMuted = false
    @Published var conversationHistory: [ConversationMessage] = []
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var errorMessage: String?

    private var audioEngine: AVAudioEngine?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA"))
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var audioPlayer: AVAudioPlayer? // 🔧 FIX: Retain audio player to prevent premature deallocation
    private var audioPlayerDelegate: AudioPlayerDelegate?
    
    enum ConnectionStatus: String {
        case disconnected = "Disconnected"
        case connecting = "Connecting..."
        case connected = "Connected"
        case error = "Connection Error"
    }
    
    struct ConversationMessage: Identifiable, Codable {
        let id: UUID
        let role: MessageRole
        let content: String
        let timestamp: Date
        let audioURL: URL?
        let citations: [Citation]?
        let recommendedFacilities: [Facility]?
        
        enum MessageRole: String, Codable {
            case user
            case assistant
            case system
        }
    }
    
    struct Citation: Codable, Identifiable {
        let id: UUID
        let title: String
        let url: String
        let snippet: String?
    }
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            errorMessage = "Audio session setup failed: \(error.localizedDescription)"
        }
    }
    
    func requestPermissions() async -> Bool {
        let microphoneGranted = await requestMicrophonePermission()
        let speechGranted = await requestSpeechRecognitionPermission()
        return microphoneGranted && speechGranted
    }
    
    private func requestMicrophonePermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    private func requestSpeechRecognitionPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    @MainActor
    func connect() async {
        guard !isConnected else { return }
        
        connectionStatus = .connecting
        
        let permissionsGranted = await requestPermissions()
        guard permissionsGranted else {
            errorMessage = "Microphone and speech recognition permissions required"
            connectionStatus = .error
            return
        }
        
        do {
            setupWebSocket()
            try startAudioRecording()
            isConnected = true
            connectionStatus = .connected
            
            addSystemMessage("Connected to CallLinc Healthcare AI Agent")
        } catch {
            errorMessage = "Connection failed: \(error.localizedDescription)"
            connectionStatus = .error
        }
    }
    
    @MainActor
    func disconnect() {
        stopAudioRecording()
        closeWebSocket()
        isConnected = false
        connectionStatus = .disconnected
        
        addSystemMessage("Disconnected from CallLinc")
    }
    
    /// Sets up WebSocket connection with authentication and configuration
    private func setupWebSocket() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Configuration.Settings.networkTimeout
        configuration.timeoutIntervalForResource = Configuration.Settings.networkTimeout * 2

        session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())

        // Use Configuration for base URL
        let baseURL = Configuration.API.callLincBaseURL
        guard let url = URL(string: "\(baseURL)/ws/voice") else {
            errorMessage = "Invalid WebSocket URL configuration"
            return
        }

        var request = URLRequest(url: url)

        // 🔒 SECURITY: Add authentication if API key is available
        if let apiKey = Configuration.Secrets.callLincAPIKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        // Add custom headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("BrainSAIT-iOS/1.0", forHTTPHeaderField: "User-Agent")

        webSocketTask = session?.webSocketTask(with: request)
        webSocketTask?.resume()
        receiveMessage()
    }
    
    private func closeWebSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        session?.invalidateAndCancel()
        session = nil
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleIncomingMessage(text)
                case .data(let data):
                    self?.handleIncomingAudioData(data)
                @unknown default:
                    break
                }
                self?.receiveMessage()
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = "WebSocket error: \(error.localizedDescription)"
                    self?.connectionStatus = .error
                }
            }
        }
    }
    
    private func handleIncomingMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let response = try? JSONDecoder().decode(TriageResponse.self, from: data) else {
            return
        }
        
        DispatchQueue.main.async {
            let message = ConversationMessage(
                id: UUID(),
                role: .assistant,
                content: response.text,
                timestamp: Date(),
                audioURL: response.audioURL,
                citations: response.citations?.map { Citation(id: UUID(), title: $0.title, url: $0.url, snippet: $0.snippet) },
                recommendedFacilities: response.recommendedFacilities
            )
            self.conversationHistory.append(message)
            
            if let audioURL = response.audioURL {
                self.playAudioResponse(url: audioURL)
            }
        }
    }
    
    private func handleIncomingAudioData(_ data: Data) {
        // Handle raw audio data for real-time streaming
        playAudioData(data)
    }
    
    private func startAudioRecording() throws {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            
            if let audioData = self?.convertBufferToData(buffer) {
                self?.sendAudioData(audioData)
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                let transcription = result.bestTranscription.formattedString
                
                if result.isFinal {
                    DispatchQueue.main.async {
                        self?.addUserMessage(transcription)
                    }
                }
            }
            
            if error != nil {
                self?.stopAudioRecording()
            }
        }
        
        isRecording = true
    }
    
    private func stopAudioRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isRecording = false
    }
    
    private func convertBufferToData(_ buffer: AVAudioPCMBuffer) -> Data? {
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        return Data(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
    }
    
    private func sendAudioData(_ data: Data) {
        guard !isMuted else { return }
        
        let message = URLSessionWebSocketTask.Message.data(data)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("Error sending audio data: \(error)")
            }
        }
    }
    
    func sendTextMessage(_ text: String) {
        let message = TriageRequest(text: text, language: "ar-SA")
        
        guard let data = try? JSONEncoder().encode(message),
              let jsonString = String(data: data, encoding: .utf8) else {
            return
        }
        
        addUserMessage(text)
        
        webSocketTask?.send(.string(jsonString)) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to send message: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func playAudioResponse(url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                playAudioData(data)
            } catch {
                print("Failed to download audio: \(error)")
            }
        }
    }
    
    /// 🔧 FIXED: Properly managed audio playback with retained player instance
    /// Plays audio data from AI response
    /// - Parameter data: Audio data to play
    private func playAudioData(_ data: Data) {
        // Stop any currently playing audio
        audioPlayer?.stop()

        do {
            // Create and retain audio player
            let player = try AVAudioPlayer(data: data)
            player.volume = 1.0

            // Set up delegate for cleanup
            let delegate = AudioPlayerDelegate { [weak self] in
                DispatchQueue.main.async {
                    // Cleanup after playback finishes
                    self?.audioPlayer = nil
                    self?.audioPlayerDelegate = nil
                }
            }
            player.delegate = delegate

            // Retain both player and delegate
            self.audioPlayer = player
            self.audioPlayerDelegate = delegate

            // Prepare and play
            player.prepareToPlay()
            player.play()

            if Configuration.Settings.verboseLogging {
                print("🔊 Playing audio response (\(data.count) bytes)")
            }
        } catch {
            let errorMsg = "Failed to play audio: \(error.localizedDescription)"
            print("❌ \(errorMsg)")
            DispatchQueue.main.async {
                self.errorMessage = errorMsg
            }
        }
    }
    
    func toggleMute() {
        isMuted.toggle()
    }
    
    func clearConversation() {
        conversationHistory.removeAll()
    }
    
    private func addUserMessage(_ text: String) {
        let message = ConversationMessage(
            id: UUID(),
            role: .user,
            content: text,
            timestamp: Date(),
            audioURL: nil,
            citations: nil,
            recommendedFacilities: nil
        )
        conversationHistory.append(message)
    }
    
    private func addSystemMessage(_ text: String) {
        let message = ConversationMessage(
            id: UUID(),
            role: .system,
            content: text,
            timestamp: Date(),
            audioURL: nil,
            citations: nil,
            recommendedFacilities: nil
        )
        conversationHistory.append(message)
    }
    
    func exportConversation() -> URL? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        var text = "CallLinc Healthcare Consultation\n"
        text += "Generated: \(formatter.string(from: Date()))\n\n"
        
        for message in conversationHistory {
            let role = message.role.rawValue.capitalized
            let time = formatter.string(from: message.timestamp)
            text += "[\(time)] \(role):\n\(message.content)\n\n"
            
            if let citations = message.citations, !citations.isEmpty {
                text += "References:\n"
                for citation in citations {
                    text += "- \(citation.title): \(citation.url)\n"
                }
                text += "\n"
            }
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("conversation_\(Date().timeIntervalSince1970).txt")
        
        do {
            try text.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            errorMessage = "Failed to export conversation: \(error.localizedDescription)"
            return nil
        }
    }
}

extension VoiceTriageService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async {
            self.connectionStatus = .connected
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.connectionStatus = .disconnected
        }
    }
}

struct TriageRequest: Codable {
    let text: String
    let language: String
}

struct TriageResponse: Codable {
    let text: String
    let audioURL: URL?
    let citations: [CitationData]?
    let recommendedFacilities: [Facility]?

    struct CitationData: Codable {
        let title: String
        let url: String
        let snippet: String?
    }
}

// MARK: - Audio Player Delegate

/// Helper class to manage AVAudioPlayer lifecycle and callbacks
private class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        super.init()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if Configuration.Settings.verboseLogging {
            print("🔊 Audio playback finished (success: \(flag))")
        }
        onFinish()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("❌ Audio decode error: \(error.localizedDescription)")
        }
        onFinish()
    }
}
