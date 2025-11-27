import SwiftUI

struct VoiceTriageView: View {
    @StateObject private var voiceService = VoiceTriageService.shared
    @EnvironmentObject var facilityDataManager: FacilityDataManager
    @State private var textInput = ""
    @State private var showExportSheet = false
    @State private var exportURL: URL?
    @State private var selectedMode: TriageMode = .voice
    @State private var showAppointmentBooking = false
    @State private var selectedFacility: Facility?
    
    enum TriageMode {
        case voice
        case text
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                connectionStatusView
                conversationView
                inputControlsView
            }
            .navigationTitle("CallLinc AI Triage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: exportConversation) {
                            Label("Export Conversation", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: { voiceService.clearConversation() }) {
                            Label("Clear History", systemImage: "trash")
                        }
                        .disabled(voiceService.conversationHistory.isEmpty)
                        
                        Button(role: .destructive, action: {
                            voiceService.disconnect()
                        }) {
                            Label("Disconnect", systemImage: "phone.down")
                        }
                        .disabled(!voiceService.isConnected)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showExportSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
            .sheet(isPresented: $showAppointmentBooking) {
                if let facility = selectedFacility {
                    AppointmentBookingView(facility: facility)
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 20) {
            ModeButton(
                icon: "phone.fill",
                title: "Voice",
                isSelected: selectedMode == .voice,
                color: .blue
            ) {
                selectedMode = .voice
            }
            
            ModeButton(
                icon: "message.fill",
                title: "Text",
                isSelected: selectedMode == .text,
                color: .green
            ) {
                selectedMode = .text
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
    }
    
    private var connectionStatusView: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(statusColor.opacity(0.3), lineWidth: 4)
                        .scaleEffect(voiceService.isConnected ? 1.5 : 1.0)
                        .opacity(voiceService.isConnected ? 0 : 1)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: voiceService.isConnected)
                )
            
            Text(voiceService.connectionStatus.rawValue)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if voiceService.isConnected && selectedMode == .voice {
                Button(action: { voiceService.toggleMute() }) {
                    Image(systemName: voiceService.isMuted ? "mic.slash.fill" : "mic.fill")
                        .foregroundColor(voiceService.isMuted ? .red : .blue)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
    }
    
    private var statusColor: Color {
        switch voiceService.connectionStatus {
        case .connected:
            return .green
        case .connecting:
            return .orange
        case .disconnected:
            return .gray
        case .error:
            return .red
        }
    }
    
    private var conversationView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if voiceService.conversationHistory.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(voiceService.conversationHistory) { message in
                            MessageBubble(
                                message: message,
                                onFacilitySelect: { facility in
                                    selectedFacility = facility
                                    showAppointmentBooking = true
                                }
                            )
                            .id(message.id)
                        }
                    }
                }
                .padding()
            }
            .onChange(of: voiceService.conversationHistory.count) { _ in
                if let lastMessage = voiceService.conversationHistory.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.3))
            
            Text("CallLinc Healthcare AI Agent")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start a conversation for:\n• Appointment scheduling\n• Insurance assistance\n• Medical inquiries\n• Clinic recommendations")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if !voiceService.isConnected {
                Button(action: connectToService) {
                    Label("Connect to CallLinc", systemImage: "phone.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var inputControlsView: some View {
        VStack(spacing: 12) {
            if let error = voiceService.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Dismiss") {
                        voiceService.errorMessage = nil
                    }
                    .font(.caption)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            if selectedMode == .text {
                HStack {
                    TextField("Type your message...", text: $textInput)
                        .textFieldStyle(.roundedBorder)
                        .disabled(!voiceService.isConnected)
                    
                    Button(action: sendTextMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                    .disabled(textInput.isEmpty || !voiceService.isConnected)
                }
                .padding(.horizontal)
            } else if selectedMode == .voice {
                VoiceControlsView(isConnected: voiceService.isConnected, isRecording: voiceService.isRecording) {
                    if voiceService.isConnected {
                        voiceService.disconnect()
                    } else {
                        connectToService()
                    }
                }
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
    }
    
    private func connectToService() {
        Task {
            await voiceService.connect()
        }
    }
    
    private func sendTextMessage() {
        guard !textInput.isEmpty else { return }
        voiceService.sendTextMessage(textInput)
        textInput = ""
    }
    
    private func exportConversation() {
        if let url = voiceService.exportConversation() {
            exportURL = url
            showExportSheet = true
        }
    }
}

struct ModeButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundColor(isSelected ? .white : color)
            .background(isSelected ? color : Color.clear)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color, lineWidth: isSelected ? 0 : 2)
            )
        }
    }
}

struct MessageBubble: View {
    let message: VoiceTriageService.ConversationMessage
    let onFacilitySelect: ((Facility) -> Void)?
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 6) {
                if message.role == .system {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.caption)
                        Text(message.content)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                } else {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(bubbleColor)
                        .foregroundColor(message.role == .user ? .white : .primary)
                        .cornerRadius(16)
                    
                    if let recommendedFacilities = message.recommendedFacilities, !recommendedFacilities.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recommended Facilities:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ForEach(recommendedFacilities) { facility in
                                FacilityRecommendationCard(
                                    facility: facility,
                                    onSelect: { onFacilitySelect?(facility) }
                                )
                            }
                        }
                        .padding(8)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    if let citations = message.citations, !citations.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("References:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            ForEach(citations) { citation in
                                Link(destination: URL(string: citation.url)!) {
                                    HStack {
                                        Image(systemName: "link.circle.fill")
                                            .font(.caption2)
                                        Text(citation.title)
                                            .font(.caption2)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    Text(timeString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: 280, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role != .user {
                Spacer()
            }
        }
    }
    
    private var bubbleColor: Color {
        switch message.role {
        case .user:
            return .blue
        case .assistant:
            return Color(.secondarySystemBackground)
        case .system:
            return .clear
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
}

struct FacilityRecommendationCard: View {
    let facility: Facility
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: facility.type.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(facility.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(facility.district)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let rating = facility.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct VoiceControlsView: View {
    let isConnected: Bool
    let isRecording: Bool
    let onToggleConnection: () -> Void
    
    var body: some View {
        HStack(spacing: 40) {
            Button(action: onToggleConnection) {
                VStack {
                    ZStack {
                        Circle()
                            .fill(isConnected ? Color.red : Color.green)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: isConnected ? "phone.down.fill" : "phone.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                    
                    Text(isConnected ? "Disconnect" : "Connect")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isConnected {
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        if isRecording {
                            Circle()
                                .stroke(Color.blue, lineWidth: 3)
                                .frame(width: 70, height: 70)
                                .scaleEffect(1.2)
                                .opacity(0)
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false), value: isRecording)
                        }
                        
                        Image(systemName: "waveform")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                    
                    Text(isRecording ? "Listening..." : "Ready")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    VoiceTriageView()
        .environmentObject(FacilityDataManager())
}
