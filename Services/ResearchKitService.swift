import Foundation
import ResearchKit

class ResearchKitService: ObservableObject {
    static let shared = ResearchKitService()
    
    @Published var surveyResults: [ORKTaskResult] = []
    @Published var consentDocument: ORKConsentDocument?
    @Published var errorMessage: String?
    
    private init() {
        setupConsentDocument()
    }
    
    private func setupConsentDocument() {
        let consentDocument = ORKConsentDocument()
        consentDocument.title = "BrainSAIT Health Research Consent"
        
        // Overview section
        let overviewSection = ORKConsentSection(type: .overview)
        overviewSection.title = "Welcome to BrainSAIT Health Research"
        overviewSection.summary = "This research study aims to improve healthcare delivery in Saudi Arabia."
        overviewSection.content = """
        Thank you for your interest in participating in our research study. This study will help us:
        
        • Understand patient health patterns
        • Improve healthcare service delivery
        • Develop better treatment recommendations
        • Enhance patient outcomes
        
        Your participation is voluntary and you may withdraw at any time.
        """
        
        // Data gathering section
        let dataGatheringSection = ORKConsentSection(type: .dataGathering)
        dataGatheringSection.title = "Data Collection"
        dataGatheringSection.summary = "We will collect health data from your device"
        dataGatheringSection.content = """
        With your permission, we will collect:
        
        • Health metrics (heart rate, blood pressure, etc.)
        • Activity data (steps, exercise)
        • Medical records from connected providers
        • Survey responses
        
        All data is encrypted and stored securely.
        """
        
        // Privacy section
        let privacySection = ORKConsentSection(type: .privacy)
        privacySection.title = "Privacy & Confidentiality"
        privacySection.summary = "Your data is protected and confidential"
        privacySection.content = """
        Your privacy is our priority:
        
        • Data is encrypted end-to-end
        • Personal information is de-identified
        • Compliant with HIPAA and Saudi PDPL
        • Data shared only with your consent
        • You can request data deletion anytime
        """
        
        // Time commitment section
        let timeSection = ORKConsentSection(type: .timeCommitment)
        timeSection.title = "Time Commitment"
        timeSection.summary = "Minimal time required"
        timeSection.content = """
        Participation requires:
        
        • Weekly health surveys (5 minutes)
        • Monthly health check-ins (10 minutes)
        • Optional: Daily health tracking
        
        Total estimated time: 1 hour per month
        """
        
        // Benefits section
        let benefitsSection = ORKConsentSection(type: .studyTasks)
        benefitsSection.title = "Potential Benefits"
        benefitsSection.summary = "How this research may help you"
        benefitsSection.content = """
        By participating, you may:
        
        • Receive personalized health insights
        • Track your health progress
        • Access educational resources
        • Contribute to medical research
        • Help improve healthcare in Saudi Arabia
        """
        
        consentDocument.sections = [
            overviewSection,
            dataGatheringSection,
            privacySection,
            timeSection,
            benefitsSection
        ]
        
        consentDocument.addSignature(ORKConsentSignature(
            forPersonWithTitle: "Participant",
            dateFormatString: nil,
            identifier: "participant"
        ))
        
        self.consentDocument = consentDocument
    }
    
    // Create health symptom survey
    func createSymptomSurvey() -> ORKOrderedTask {
        var steps: [ORKStep] = []
        
        // Instruction step
        let instructionStep = ORKInstructionStep(identifier: "intro")
        instructionStep.title = "Health Symptom Survey"
        instructionStep.text = "Please answer the following questions about your current health status."
        steps.append(instructionStep)
        
        // Pain level question
        let painAnswerFormat = ORKScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 0,
            defaultValue: 0,
            step: 1,
            vertical: false,
            maximumValueDescription: "Severe Pain",
            minimumValueDescription: "No Pain"
        )
        let painStep = ORKQuestionStep(
            identifier: "pain_level",
            title: "Pain Level",
            question: "How would you rate your pain level right now?",
            answer: painAnswerFormat
        )
        steps.append(painStep)
        
        // Symptoms checklist
        let symptomChoices = [
            ORKTextChoice(text: "Fever", value: "fever" as NSString),
            ORKTextChoice(text: "Cough", value: "cough" as NSString),
            ORKTextChoice(text: "Shortness of Breath", value: "shortness_breath" as NSString),
            ORKTextChoice(text: "Fatigue", value: "fatigue" as NSString),
            ORKTextChoice(text: "Headache", value: "headache" as NSString),
            ORKTextChoice(text: "Nausea", value: "nausea" as NSString),
            ORKTextChoice(text: "Dizziness", value: "dizziness" as NSString),
            ORKTextChoice(text: "None of the above", value: "none" as NSString)
        ]
        let symptomsFormat = ORKTextChoiceAnswerFormat(style: .multipleChoice, textChoices: symptomChoices)
        let symptomsStep = ORKQuestionStep(
            identifier: "symptoms",
            title: "Current Symptoms",
            question: "Select any symptoms you are experiencing:",
            answer: symptomsFormat
        )
        steps.append(symptomsStep)
        
        // Duration question
        let durationChoices = [
            ORKTextChoice(text: "Less than 24 hours", value: "less_24h" as NSString),
            ORKTextChoice(text: "1-3 days", value: "1_3_days" as NSString),
            ORKTextChoice(text: "4-7 days", value: "4_7_days" as NSString),
            ORKTextChoice(text: "More than a week", value: "more_week" as NSString)
        ]
        let durationFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: durationChoices)
        let durationStep = ORKQuestionStep(
            identifier: "symptom_duration",
            title: "Symptom Duration",
            question: "How long have you had these symptoms?",
            answer: durationFormat
        )
        steps.append(durationStep)
        
        // Medication question
        let medicationStep = ORKQuestionStep(
            identifier: "current_medications",
            title: "Current Medications",
            question: "Are you currently taking any medications?",
            answer: ORKBooleanAnswerFormat()
        )
        steps.append(medicationStep)
        
        // Additional notes
        let notesFormat = ORKTextAnswerFormat(maximumLength: 500)
        notesFormat.multipleLines = true
        let notesStep = ORKQuestionStep(
            identifier: "additional_notes",
            title: "Additional Information",
            question: "Please provide any additional details:",
            answer: notesFormat
        )
        notesStep.isOptional = true
        steps.append(notesStep)
        
        // Completion step
        let completionStep = ORKCompletionStep(identifier: "completion")
        completionStep.title = "Thank You"
        completionStep.text = "Your responses have been recorded and will help improve your care."
        steps.append(completionStep)
        
        return ORKOrderedTask(identifier: "symptom_survey", steps: steps)
    }
    
    // Create wellness assessment
    func createWellnessAssessment() -> ORKOrderedTask {
        var steps: [ORKStep] = []
        
        // Intro
        let intro = ORKInstructionStep(identifier: "wellness_intro")
        intro.title = "Weekly Wellness Check"
        intro.text = "Help us understand your overall wellbeing this week."
        steps.append(intro)
        
        // Mood scale
        let moodFormat = ORKScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 1,
            defaultValue: 5,
            step: 1,
            vertical: false,
            maximumValueDescription: "Excellent",
            minimumValueDescription: "Poor"
        )
        let moodStep = ORKQuestionStep(
            identifier: "mood",
            title: "Overall Mood",
            question: "How would you rate your overall mood this week?",
            answer: moodFormat
        )
        steps.append(moodStep)
        
        // Sleep quality
        let sleepFormat = ORKScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 1,
            defaultValue: 5,
            step: 1,
            vertical: false,
            maximumValueDescription: "Very Well",
            minimumValueDescription: "Very Poorly"
        )
        let sleepStep = ORKQuestionStep(
            identifier: "sleep_quality",
            title: "Sleep Quality",
            question: "How well did you sleep this week?",
            answer: sleepFormat
        )
        steps.append(sleepStep)
        
        // Exercise frequency
        let exerciseChoices = [
            ORKTextChoice(text: "0 days", value: "0" as NSString),
            ORKTextChoice(text: "1-2 days", value: "1-2" as NSString),
            ORKTextChoice(text: "3-4 days", value: "3-4" as NSString),
            ORKTextChoice(text: "5-6 days", value: "5-6" as NSString),
            ORKTextChoice(text: "7 days", value: "7" as NSString)
        ]
        let exerciseFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: exerciseChoices)
        let exerciseStep = ORKQuestionStep(
            identifier: "exercise_frequency",
            title: "Exercise",
            question: "How many days did you exercise this week?",
            answer: exerciseFormat
        )
        steps.append(exerciseStep)
        
        // Stress level
        let stressFormat = ORKScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 1,
            defaultValue: 5,
            step: 1,
            vertical: false,
            maximumValueDescription: "Very Stressed",
            minimumValueDescription: "Not Stressed"
        )
        let stressStep = ORKQuestionStep(
            identifier: "stress_level",
            title: "Stress Level",
            question: "What was your average stress level this week?",
            answer: stressFormat
        )
        steps.append(stressStep)
        
        // Completion
        let completion = ORKCompletionStep(identifier: "wellness_completion")
        completion.title = "Assessment Complete"
        completion.text = "Thank you for completing your wellness check!"
        steps.append(completion)
        
        return ORKOrderedTask(identifier: "wellness_assessment", steps: steps)
    }
    
    // Create active task (e.g., fitness test)
    func createFitnessTest() -> ORKOrderedTask {
        return ORKOrderedTask.fitnessCheck(
            withIdentifier: "fitness_test",
            intendedUseDescription: "Measure your fitness level",
            walkDuration: 360, // 6 minutes
            restDuration: 30,
            options: []
        )
    }
    
    // Save survey results
    func saveSurveyResult(_ result: ORKTaskResult) {
        surveyResults.append(result)
        
        // Extract and process results
        processSurveyResult(result)
    }
    
    private func processSurveyResult(_ taskResult: ORKTaskResult) {
        for stepResult in taskResult.results ?? [] {
            guard let stepResult = stepResult as? ORKStepResult else { continue }
            
            for result in stepResult.results ?? [] {
                if let scaleResult = result as? ORKScaleQuestionResult {
                    print("Scale question '\(result.identifier)': \(scaleResult.scaleAnswer ?? 0)")
                } else if let choiceResult = result as? ORKChoiceQuestionResult {
                    print("Choice question '\(result.identifier)': \(choiceResult.choiceAnswers ?? [])")
                } else if let textResult = result as? ORKTextQuestionResult {
                    print("Text question '\(result.identifier)': \(textResult.textAnswer ?? "")")
                } else if let boolResult = result as? ORKBooleanQuestionResult {
                    print("Boolean question '\(result.identifier)': \(boolResult.booleanAnswer ?? false)")
                }
            }
        }
    }
    
    // Export results to JSON
    func exportSurveyResults() -> Data? {
        let results = surveyResults.map { result -> [String: Any] in
            var dict: [String: Any] = [
                "identifier": result.identifier,
                "startDate": result.startDate,
                "endDate": result.endDate
            ]
            
            var answers: [[String: Any]] = []
            for stepResult in result.results ?? [] {
                guard let stepResult = stepResult as? ORKStepResult else { continue }
                for answer in stepResult.results ?? [] {
                    var answerDict: [String: Any] = ["identifier": answer.identifier]
                    
                    if let scaleResult = answer as? ORKScaleQuestionResult {
                        answerDict["value"] = scaleResult.scaleAnswer
                    } else if let choiceResult = answer as? ORKChoiceQuestionResult {
                        answerDict["value"] = choiceResult.choiceAnswers
                    } else if let textResult = answer as? ORKTextQuestionResult {
                        answerDict["value"] = textResult.textAnswer
                    } else if let boolResult = answer as? ORKBooleanQuestionResult {
                        answerDict["value"] = boolResult.booleanAnswer
                    }
                    
                    answers.append(answerDict)
                }
            }
            dict["answers"] = answers
            
            return dict
        }
        
        return try? JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
    }
}
