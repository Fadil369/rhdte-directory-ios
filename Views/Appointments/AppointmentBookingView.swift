import SwiftUI

struct AppointmentBookingView: View {
    let facility: Facility
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var doctorService = DoctorHubService.shared
    @State private var selectedDoctor: Doctor?
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot: TimeSlot?
    @State private var availableSlots: [TimeSlot] = []
    @State private var currentStep: BookingStep = .selectDoctor
    @State private var patientInfo = PatientInfo()
    @State private var showConfirmation = false
    @State private var bookedAppointment: Appointment?
    
    enum BookingStep {
        case selectDoctor
        case selectDateTime
        case patientDetails
        case insurance
        case confirmation
        
        var index: Int {
            switch self {
            case .selectDoctor: return 0
            case .selectDateTime: return 1
            case .patientDetails: return 2
            case .insurance: return 3
            case .confirmation: return 4
            }
        }
        
        var next: Self {
            switch self {
            case .selectDoctor: return .selectDateTime
            case .selectDateTime: return .patientDetails
            case .patientDetails: return .insurance
            case .insurance: return .confirmation
            case .confirmation: return .confirmation
            }
        }
        
        var previous: Self {
            switch self {
            case .selectDoctor: return .selectDoctor
            case .selectDateTime: return .selectDoctor
            case .patientDetails: return .selectDateTime
            case .insurance: return .patientDetails
            case .confirmation: return .insurance
            }
        }
    }
    
    struct PatientInfo {
        var name = ""
        var phone = ""
        var email = ""
        var reason = ""
        var notes = ""
        var hasInsurance = false
        var insuranceProvider = ""
        var policyNumber = ""
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        switch currentStep {
                        case .selectDoctor:
                            doctorSelectionView
                        case .selectDateTime:
                            dateTimeSelectionView
                        case .patientDetails:
                            patientDetailsView
                        case .insurance:
                            insuranceView
                        case .confirmation:
                            confirmationView
                        }
                    }
                    .padding()
                }
                
                navigationButtons
            }
            .navigationTitle("Book Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadDoctors()
            }
            .alert("Appointment Confirmed", isPresented: $showConfirmation) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                if let appointment = bookedAppointment {
                    Text("Your appointment with Dr. \(appointment.doctorName) is confirmed.\nConfirmation Code: \(appointment.confirmationCode)")
                }
            }
        }
    }
    
    private var progressBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<5) { index in
                Rectangle()
                    .fill(index <= currentStep.index ? Color.blue : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
    }
    
    private var doctorSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Doctor")
                .font(.title2)
                .fontWeight(.bold)
            
            if doctorService.isLoading {
                ProgressView("Loading doctors...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if doctorService.doctors.isEmpty {
                VStack {
                    Image(systemName: "stethoscope")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No Doctors Available")
                        .font(.headline)
                }
            } else {
                ForEach(doctorService.doctors) { doctor in
                    DoctorCard(doctor: doctor, isSelected: selectedDoctor?.id == doctor.id) {
                        selectedDoctor = doctor
                    }
                }
            }
        }
    }
    
    private var dateTimeSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Date & Time")
                .font(.title2)
                .fontWeight(.bold)
            
            if let doctor = selectedDoctor {
                Text("Booking with Dr. \(doctor.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            DatePicker(
                "Appointment Date",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .onChange(of: selectedDate) { _ in
                Task {
                    await loadAvailableSlots()
                }
            }
            
            if doctorService.isLoading {
                ProgressView("Loading available slots...")
            } else if availableSlots.isEmpty {
                Text("No available slots for this date")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available Time Slots")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ForEach(availableSlots) { slot in
                            TimeSlotButton(
                                slot: slot,
                                isSelected: selectedTimeSlot?.id == slot.id
                            ) {
                                selectedTimeSlot = slot
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var patientDetailsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Patient Information")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                TextField("Full Name", text: $patientInfo.name)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Phone Number", text: $patientInfo.phone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                
                TextField("Email (Optional)", text: $patientInfo.email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reason for Visit")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $patientInfo.reason)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3))
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Additional Notes (Optional)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $patientInfo.notes)
                        .frame(height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3))
                        )
                }
            }
        }
    }
    
    private var insuranceView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insurance Information")
                .font(.title2)
                .fontWeight(.bold)
            
            Toggle("I have insurance coverage", isOn: $patientInfo.hasInsurance)
                .padding(.vertical, 8)
            
            if patientInfo.hasInsurance {
                VStack(spacing: 12) {
                    TextField("Insurance Provider", text: $patientInfo.insuranceProvider)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Policy Number", text: $patientInfo.policyNumber)
                        .textFieldStyle(.roundedBorder)
                    
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("Your insurance will be verified during check-in")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var confirmationView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Confirm Booking")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                ConfirmationRow(icon: "building.2.fill", title: "Facility", value: facility.displayName)
                
                if let doctor = selectedDoctor {
                    ConfirmationRow(icon: "stethoscope", title: "Doctor", value: doctor.displayName)
                }
                
                if let slot = selectedTimeSlot {
                    ConfirmationRow(icon: "calendar", title: "Date", value: formatDate(selectedDate))
                    ConfirmationRow(icon: "clock", title: "Time", value: formatTime(slot.startTime))
                }
                
                ConfirmationRow(icon: "person.fill", title: "Patient", value: patientInfo.name)
                ConfirmationRow(icon: "phone.fill", title: "Contact", value: patientInfo.phone)
                
                if patientInfo.hasInsurance {
                    ConfirmationRow(icon: "cross.case.fill", title: "Insurance", value: patientInfo.insuranceProvider)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentStep.index > 0 {
                Button(action: previousStep) {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            Button(action: nextStep) {
                if currentStep == .confirmation {
                    Label("Confirm Booking", systemImage: "checkmark.circle.fill")
                } else {
                    Label("Continue", systemImage: "chevron.right")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canProceed)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case .selectDoctor:
            return selectedDoctor != nil
        case .selectDateTime:
            return selectedTimeSlot != nil
        case .patientDetails:
            return !patientInfo.name.isEmpty && !patientInfo.phone.isEmpty && !patientInfo.reason.isEmpty
        case .insurance:
            return !patientInfo.hasInsurance || (!patientInfo.insuranceProvider.isEmpty && !patientInfo.policyNumber.isEmpty)
        case .confirmation:
            return true
        }
    }
    
    private func previousStep() {
        withAnimation {
            currentStep = currentStep.previous
        }
    }
    
    private func nextStep() {
        if currentStep == .confirmation {
            Task {
                await bookAppointment()
            }
        } else {
            withAnimation {
                currentStep = currentStep.next
            }
        }
    }
    
    private func loadDoctors() async {
        do {
            _ = try await doctorService.fetchDoctors(facilityId: facility.id)
        } catch {
            doctorService.errorMessage = error.localizedDescription
        }
    }
    
    private func loadAvailableSlots() async {
        guard let doctor = selectedDoctor else { return }
        
        do {
            availableSlots = try await doctorService.fetchAvailableSlots(
                doctorId: doctor.id,
                date: selectedDate
            )
        } catch {
            doctorService.errorMessage = error.localizedDescription
        }
    }
    
    private func bookAppointment() async {
        guard let doctor = selectedDoctor,
              let timeSlot = selectedTimeSlot else { return }
        
        let request = AppointmentRequest(
            doctorId: doctor.id,
            facilityId: facility.id,
            patientId: UUID().uuidString,
            patientName: patientInfo.name,
            patientPhone: patientInfo.phone,
            patientEmail: patientInfo.email.isEmpty ? nil : patientInfo.email,
            timeSlotId: timeSlot.id,
            appointmentDate: selectedDate,
            consultationType: timeSlot.consultationType,
            reason: patientInfo.reason,
            insuranceProvider: patientInfo.hasInsurance ? patientInfo.insuranceProvider : nil,
            insurancePolicyNumber: patientInfo.hasInsurance ? patientInfo.policyNumber : nil,
            notes: patientInfo.notes.isEmpty ? nil : patientInfo.notes
        )
        
        do {
            bookedAppointment = try await doctorService.bookAppointment(request)
            showConfirmation = true
        } catch {
            doctorService.errorMessage = error.localizedDescription
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DoctorCard: View {
    let doctor: Doctor
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(doctor.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(doctor.specialty)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        if let rating = doctor.rating {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                Text(String(format: "%.1f", rating))
                                    .font(.caption)
                            }
                            .foregroundColor(.orange)
                        }
                        
                        Text("• \(doctor.yearsOfExperience) years exp.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct TimeSlotButton: View {
    let slot: TimeSlot
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                Text(formatTime(slot.startTime))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Image(systemName: slot.consultationType.icon)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundColor(isSelected ? .white : slot.isAvailable ? .primary : .secondary)
            .background(isSelected ? Color.blue : slot.isAvailable ? Color(.tertiarySystemBackground) : Color(.systemGray5))
            .cornerRadius(8)
        }
        .disabled(!slot.isAvailable)
        .buttonStyle(.plain)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ConfirmationRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
            }
            
            Spacer()
        }
    }
}

extension TimeSlot.ConsultationType {
    var icon: String {
        switch self {
        case .inPerson: return "person.fill"
        case .video: return "video.fill"
        case .phone: return "phone.fill"
        }
    }
}
