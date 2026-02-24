import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var progress: ProgressStore

    // The month being displayed (defaults to current month)
    @State private var monthAnchor: Date = Date()
    @State private var selectedDay: Date? = nil

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            // Header with month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .padding(8)
                }
                Spacer()
                Text(monthTitle)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                Spacer()
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .padding(8)
                }
            }

            // Weekday labels
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { sym in
                    Text(sym)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(gridDays, id: \.self) { day in
                    dayCell(for: day)
                        .onTapGesture { selectedDay = day }
                }
            }

            // Selected day details
            if let sel = selectedDay, let dp = progress.progress(for: sel) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Details for \(formatted(sel))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("Addition score: \(dp.additionScore)")
                    Text("Subtraction score: \(dp.subtractionScore)")
                    Text("Multiplication score: \(dp.multiplicationScore)")
                    Text("Division score: \(dp.divisionScore)")
                    Text("Total attempted: \(dp.totalAttempted)")
                    Text(dp.completed ? "✅ Homework completed" : "❌ Homework not completed")
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding()
        .navigationTitle("Homework Tracker")
    }

    // MARK: - Calendar helpers

    /// The title string for the current month and year
    private var monthTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "LLLL yyyy"
        return fmt.string(from: monthAnchor)
    }

    /// The days to display in the calendar grid, including leading blanks to align weekdays
    private var gridDays: [Date] {
        // Build a grid with leading blanks to align first weekday
        let monthDays = progress.daysInMonth(containing: monthAnchor)
        guard let first = monthDays.first else { return [] }
        let firstWeekday = calendar.component(.weekday, from: first)
        // calendar.weekday: 1=Sunday ... 7=Saturday
        let leadingBlanks = (firstWeekday + 6) % 7 // align so Monday is first column
        let blanks = Array(repeating: Date.distantPast, count: leadingBlanks)
        return blanks + monthDays
    }

    /// Creates a view for a single day cell in the calendar
    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        if date == Date.distantPast {
            // Empty cell for leading blanks
            Color.clear.frame(height: 36)
        } else {
            let state = dayState(for: date)
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 36)
                .padding(6)
                .background(state.background)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .foregroundStyle(.white)
        }
    }

    /// Enumeration representing the state of a calendar day
    private enum DayState {
        case completed, missed, future, none

        /// Background gradient color for each day state
        var background: some ShapeStyle {
            switch self {
            case .completed: return LinearGradient(colors: [Color.green, Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .missed: return LinearGradient(colors: [Color.red, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .future: return LinearGradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .none: return LinearGradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }

    /// Determines the state of the given date for coloring
    private func dayState(for date: Date) -> DayState {
        let startToday = progress.startOfDay(Date())
        if date > startToday { return .future }
        if let dp = progress.progress(for: date) {
            return dp.completed ? .completed : .missed
        }
        return .missed
    }

    /// Formats a date to a medium style string for display
    private func formatted(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt.string(from: date)
    }

    /// Moves the displayed month to the previous month
    private func previousMonth() {
        if let prev = calendar.date(byAdding: .month, value: -1, to: monthAnchor) { monthAnchor = prev }
        selectedDay = nil
    }

    /// Moves the displayed month to the next month
    private func nextMonth() {
        if let next = calendar.date(byAdding: .month, value: 1, to: monthAnchor) { monthAnchor = next }
        selectedDay = nil
    }
}

#Preview {
    NavigationStack {
        CalendarView()
            .environmentObject(ProgressStore())
    }
}
