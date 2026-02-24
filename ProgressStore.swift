import Foundation
import SwiftUI
import Combine

// MARK: - Models

// Enum representing different types of quizzes
enum QuizKind: String, Codable, CaseIterable, Identifiable {
    case addition, subtraction, multiplication, division
    
    // Unique identifier for each quiz kind (required for Identifiable)
    var id: String { rawValue }
    
    // User-friendly name for each quiz kind
    var displayName: String {
        switch self {
        case .addition: return "Addition"
        case .subtraction: return "Subtraction"
        case .multiplication: return "Multiplication"
        case .division: return "Division"
        }
    }
    
    // Symbol representing the operation
    var symbol: String {
        switch self {
        case .addition: return "+"
        case .subtraction: return "−"
        case .multiplication: return "×"
        case .division: return "÷"
        }
    }
}

// Struct to hold progress for one day
struct DailyProgress: Codable, Identifiable {
    // Use the midnight date as the unique identifier for the day
    let id: Date
    
    // Scores for each quiz type
    var additionScore: Int
    var subtractionScore: Int
    var multiplicationScore: Int
    var divisionScore: Int

    
    // Total number of attempts on that day
    var totalAttempted: Int
    
    // Whether the day's quizzes were completed
    var completed: Bool
}

// MARK: - Progress Store

// Store to keep track of daily progress, saving to UserDefaults
@MainActor
final class ProgressStore: ObservableObject {
    // Dictionary mapping each day to its progress
    @Published private(set) var days: [Date: DailyProgress] = [:]
    
    // Key for saving data in UserDefaults
    private let storageKey = "NumberNinja.Progress"
    
    // Calendar to help with date calculations
    private let calendar = Calendar.current
    
    init() {
        // Load saved data on initialization
        load()
    }
    
    // Convert any date to midnight to standardize keys
    func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
    
    // Record results for a specific quiz kind on a given date
    func recordResult(for date: Date, kind: QuizKind, correct: Int, attempted: Int, markCompleted: Bool) {
        // Normalize date to start of day
        let day = startOfDay(date)
        
        // Get existing progress or create new if none exists
        var existing = days[day] ?? DailyProgress(id: day, additionScore: 0, subtractionScore: 0, multiplicationScore: 0, divisionScore: 0,totalAttempted: 0, completed: false)
        
        // Update the score for the specific quiz kind
        switch kind {
        case .addition: existing.additionScore = correct
        case .subtraction: existing.subtractionScore = correct
        case .multiplication: existing.multiplicationScore = correct
        case .division: existing.divisionScore = correct
        }
        
        // Update total attempts if this is higher
        existing.totalAttempted = max(existing.totalAttempted, attempted)
        
        // Mark as completed if applicable
        existing.completed = existing.completed || markCompleted
        
        // Save updated progress back to dictionary
        days[day] = existing
        
        // Persist the changes
        save()
    }
    
    // Get progress for a given date
    func progress(for date: Date) -> DailyProgress? {
        days[startOfDay(date)]
    }
    
    // Get all days in the month containing the specified date
    func daysInMonth(containing date: Date) -> [Date] {
        // Get the range of days in the month and the month start date
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        
        // Create an array of Dates for each day in the month at midnight
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart).map(startOfDay)
        }
    }
    
    // MARK: - Persistence
    
    // Save the days dictionary to UserDefaults using JSON encoding
    private func save() {
        do {
            let data = try JSONEncoder().encode(days)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save progress: \(error)")
        }
    }
    
    // Load the days dictionary from UserDefaults
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([Date: DailyProgress].self, from: data)
            days = decoded
        } catch {
            print("Failed to load progress: \(error)")
        }
    }
}

