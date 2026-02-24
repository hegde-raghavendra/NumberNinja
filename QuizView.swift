import SwiftUI

struct QuizView: View {
    // What kind of quiz are we running (addition, subtraction, or multiplication)?
    let kind: QuizKind

    // Shared progress store to save results
    @EnvironmentObject var progress: ProgressStore

    // Quiz state variables to keep track of current question, operands, user input, score, feedback, and celebration animation
    @State private var currentIndex: Int = 0
    @State private var left: Int = Int.random(in: 1...12)
    @State private var right: Int = Int.random(in: 1...12)
    @State private var answerText: String = ""
    @State private var score: Int = 0
    @State private var feedback: String = ""
    @State private var showCelebration: Bool = false
    @State private var showCompletionOverlay: Bool = false

    @State private var showedSixtySevenThisSession: Bool = false
    @State private var showSixtySevenPopup: Bool = false

    // A quiz session has 10 questions
    private let totalQuestions = 10

    var body: some View {
        ZStack {
            // Background gradient to make the UI colorful and engaging
            LinearGradient(colors: [Color.pink.opacity(0.6), Color.blue.opacity(0.6), Color.purple.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Title and current score displayed at the top
                HStack {
                    Text("\(kind.displayName) Quiz")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("Score: \(score)/\(totalQuestions)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                // Display the current question in big text
                Text(questionText)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(radius: 4)
                    .padding(.top, 10)

                // Input field and button to check the answer
                HStack(spacing: 12) {
                    TextField("Your answer", text: $answerText)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .padding(14)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
#if os(iOS)
                        .keyboardType(.numberPad) // Show number pad keyboard on iOS
#endif

                    Button {
                        // When "Check" is tapped, validate the answer with animation
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            checkAnswer()
                        }
                    } label: {
                        Text("Check")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .foregroundStyle(.white)
                            .background(
                                LinearGradient(colors: [Color.green, Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: Color.green.opacity(0.4), radius: 10, x: 0, y: 6)
                    }
                }

                // Show feedback text to tell if the answer was correct or not
                if !feedback.isEmpty {
                    Text(feedback)
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(feedback.hasPrefix("Correct") ? .green : .orange)
                        .shadow(radius: 2)
                        .transition(.opacity)
                        .id(feedback)
                }

                // Celebrate correct answers with an emoji and animation
                if showCelebration {
                    Text("🎉 Great Job!")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                        .transition(.scale.combined(with: .opacity))
                }

                // Button to go to the next question or finish the quiz
                Button(action: nextQuestion) {
                    Label(currentIndex + 1 >= totalQuestions ? "Finish" : "Next", systemImage: "arrow.right.circle.fill")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .background(
                            LinearGradient(colors: [Color.pink, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.purple.opacity(0.4), radius: 10, x: 0, y: 6)
                }
                .padding(.top, 6)

                Spacer(minLength: 0)
            }
            .padding()

            if showCompletionOverlay {
                CelebrationView(isPresented: $showCompletionOverlay,
                                title: "Homework Complete!",
                                subtitle: "You answered all 10 questions.")
                    .transition(AnyTransition.opacity.combined(with: AnyTransition.scale))
            }
            
            if showSixtySevenPopup {
                VStack(spacing: 8) {
                    Text("6-7 🎉")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("That's sixty-seven!")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(radius: 12)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationTitle("Number Ninja Jr")
        .onAppear {
            // Reset quiz data when the view appears
            resetSession()
        }
    }

    // MARK: - Quiz Logic

    // Computed property to show the question string based on quiz kind and operands
    private var questionText: String {
        switch kind {
        case .addition:
            return "\(left) + \(right) = ?"
        case .subtraction:
            return "\(left) − \(right) = ?"
        case .multiplication:
            return "\(left) × \(right) = ?"
        case .division:
            return "\(left) ÷ \(right) = ?"
        }
    }

    // Compute the correct answer for the current question
    private var correctAnswer: Int {
        switch kind {
        case .addition: return left + right
        case .subtraction: return left - right
        case .multiplication: return left * right
        case .division: return left / right
        }
    }

    // Reset the quiz session to initial values
    private func resetSession() {
        currentIndex = 0
        score = 0
        feedback = ""
        answerText = ""
        showCelebration = false
        showCompletionOverlay = false

        showedSixtySevenThisSession = false
        showSixtySevenPopup = false

        randomizeOperands()
    }

    // Randomize the left and right operands between 1 and 12 inclusive
    private func randomizeOperands() {
        // Ensure at least one 67 answer per 10-question session for addition/subtraction
        let remaining = totalQuestions - currentIndex
        let mustForce67 = (kind == .addition || kind == .subtraction) && !showedSixtySevenThisSession && remaining <= (totalQuestions - 1)

        switch kind {
        case .division:
            // Keep division as exact integer division
            let divisor = Int.random(in: 1...12)
            let quotient = Int.random(in: 1...12)
            left = quotient * divisor
            right = divisor
        case .subtraction:
            if mustForce67 {
                // a - b = 67 => pick a random b, then a = b + 67
                let b = Int.random(in: 1...12)
                right = b
                left = b + 67
                showedSixtySevenThisSession = true
            } else {
                // Generate non-negative subtraction: left >= right
                let a = Int.random(in: 1...79) // keep within a playful range
                let b = Int.random(in: 1...min(78, a))
                left = max(a, b)
                right = min(a, b)
            }
        case .addition:
            if mustForce67 {
                // a + b = 67 => pick a in 1...66, b = 67 - a
                let a = Int.random(in: 1...66)
                left = a
                right = 67 - a
                showedSixtySevenThisSession = true
            } else {
                left = Int.random(in: 1...50)
                right = Int.random(in: 1...50)
            }
        case .multiplication:
            left = Int.random(in: 1...12)
            right = Int.random(in: 1...12)
        }
    }

    // Check the user's answer when they tap "Check"
    private func checkAnswer() {
        // Try to convert input text to an integer, if invalid show a message
        guard let typed = Int(answerText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            feedback = "Please enter a number."
            withAnimation { showCelebration = false }
            return
        }

        // Compare typed answer to the correct answer
        if typed == correctAnswer {
            feedback = "Correct! 🎉"
            score += 1

            if (kind == .addition || kind == .subtraction) && correctAnswer == 67 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showSixtySevenPopup = true
                }
                // Auto-hide the popup after a moment
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    withAnimation(.easeInOut) { showSixtySevenPopup = false }
                }
            }

            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                showCelebration = true
            }
        } else {
            feedback = "Not quite. The answer is \(correctAnswer)."
            withAnimation { showCelebration = false }
        }
    }

    // Move to the next question or finish the quiz and record progress
    private func nextQuestion() {
        if currentIndex + 1 >= totalQuestions {
            // Save the quiz result into the progress store
            progress.recordResult(for: Date(), kind: kind, correct: score, attempted: totalQuestions, markCompleted: true)
            // Show celebration overlay for completing all questions
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                showCompletionOverlay = true
            }
        }
        currentIndex = min(currentIndex + 1, totalQuestions)
        feedback = ""
        showCelebration = false
        answerText = ""
        // If quiz not finished, prepare next question
        if currentIndex < totalQuestions { randomizeOperands() }
    }
}

#Preview {
    NavigationStack {
        QuizView(kind: .multiplication)
            .environmentObject(ProgressStore())
    }
}

// Fallback local implementation to ensure CelebrationView is available if not compiled from another file.
private struct CelebrationView: View {
    @Binding var isPresented: Bool
    var title: String
    var subtitle: String
    @State private var animate = false
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture { withAnimation { isPresented = false } }

            VStack(spacing: 12) {
                Text("🎉")
                    .font(.system(size: 56))
                Text(title)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                } label: {
                    Text("Awesome!")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                        .foregroundStyle(.white)
                        .background(
                            LinearGradient(colors: [Color.green, Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 6)
            }
            .padding(24)
            .frame(maxWidth: 360)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(LinearGradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
            .scaleEffect(animate ? 1 : 0.9)
            .opacity(animate ? 1 : 0)
            .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 10)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut) { isPresented = false }
            }
        }
    }
}

