import SwiftUI

/// The grid of day cells for a single month.
@MainActor
struct CalendarMonthGridView<Cell: View>: View {

    // Month shown in this grid.
    let month: Date

    // Current selected date
    @Binding var selectedDate: Date?

    // Any custom data model mapped to this month's days.
    let daysByDate: [Date: any CalendarDayRepresentable]

    // View for each of the day cells in the grid.
    let cellContent: (any CalendarDayRepresentable) -> Cell

    // Optional view provided for each of the weekday labels above the grid.
    let weekdayLabelContent: ((String) -> AnyView)?

    // Optional callback fired on every day tap, including re-selecting the same date.
    let onDayTapped: (Date) -> Void

    let columns = Array(
        repeating: GridItem(.flexible(), spacing: 0),
        count: 7
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                Group {
                    if let date {
                        Button {
                            selectedDate = date
                            onDayTapped(date)
                        } label: {
                            cellContent(representable(for: date))
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Empty leading slot for days before the 1st.
                        Color.clear
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .aspectRatio(1.0, contentMode: .fill)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            weekdayLabels
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// The caller-supplied day for a date (or a default), with the calendar's
    /// isToday/isSelected state applied.
    private func representable(for date: Date) -> any CalendarDayRepresentable {
        var day = daysByDate[date.beginningOfDay] ?? CalendarDay(date: date)
        day.isToday = date.isToday
        day.isSelected = selectedDate.map { $0.isSameDay(as: date) } ?? false
        return day
    }

    /// All cells for the month. nil entries pad the leading days before the 1st.
    private var days: [Date?] {
        let calendar: Calendar = .current
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else { return [] }

        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmptyCount = (weekdayOfFirst - calendar.firstWeekday + 7) % 7

        var cells: [Date?] = Array(repeating: nil, count: leadingEmptyCount)
        for day in range {
            cells.append(calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth))
        }
        return cells
    }
}
