import SwiftUI

/// The grid of day cells for a single month.
@MainActor
struct CalendarMonthGridView<Cell: View>: View {

    // Month shown in this grid.
    let month: Date

    // Current selected date
    @Binding var selectedDate: Date?

    // Precomputed day lookup keyed by start-of-day.
    let daysByDate: [Date: any CalendarDayRepresentable]

    // View for each of the day cells in the grid.
    let cellContent: (any CalendarDayRepresentable) -> Cell

    // Optional view provided for each of the weekday labels above the grid.
    let weekdayLabelContent: ((String) -> AnyView)?

    // Optional callback fired on every day tap, including re-selecting the same date.
    let onDayTapped: (Date) -> Void

    // Width-to-height ratio for day cells, resolved from the cell view itself.
    var dayCellAspectRatio: CGFloat = CalendarGridMetrics.defaultDayCellAspectRatio

    /// Number of columns in the grid, one per weekday.
    static var columnCount: Int { 7 }

    /// Guards against a zero/negative ratio reported by a cell.
    var resolvedDayCellAspectRatio: CGFloat {
        dayCellAspectRatio > 0 ? dayCellAspectRatio : CalendarGridMetrics.defaultDayCellAspectRatio
    }

    var body: some View {
        // Column widths are computed explicitly instead of relying on
        // `LazyVGrid(.flexible())`, which hands leftover width to the outer
        // columns and makes them visibly wider than the rest.
        GeometryReader { proxy in
            let columnWidth = proxy.size.width / CGFloat(Self.columnCount)
            let dayHeight = columnWidth / resolvedDayCellAspectRatio
            let labelHeight = columnWidth / CalendarGridMetrics.weekdayLabelAspectRatio

            VStack(spacing: 0) {
                weekdayLabels(columnWidth: columnWidth, rowHeight: labelHeight)

                ForEach(Array(weekRows.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: 0) {
                        ForEach(Array(week.enumerated()), id: \.offset) { _, date in
                            dayCell(for: date)
                                .frame(width: columnWidth, height: dayHeight, alignment: .top)
                        }
                    }
                }
            }
            .frame(width: proxy.size.width, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private func dayCell(for date: Date?) -> some View {
        if let date {
            Button {
                selectedDate = date
                onDayTapped(date)
            } label: {
                cellContent(representable(for: date))
            }
            .buttonStyle(.plain)
        } else {
            // Empty slot for days outside the month.
            Color.clear
        }
    }

    /// The caller-supplied day for a date (or a default), with the calendar's
    /// isToday/isSelected state applied.
    private func representable(for date: Date) -> any CalendarDayRepresentable {
        var day = daysByDate[date.beginningOfDay] ?? CalendarDay(date: date)
        day.isToday = date.isToday
        day.isSelected = selectedDate.map { $0.isSameDay(as: date) } ?? false
        return day
    }

    /// Month cells chunked into fixed-width weeks, padded on both ends so every
    /// row has exactly `columnCount` entries.
    private var weekRows: [[Date?]] {
        var cells = monthDays
        let remainder = cells.count % Self.columnCount
        if remainder != 0 {
            cells.append(contentsOf: Array(repeating: nil, count: Self.columnCount - remainder))
        }

        return stride(from: 0, to: cells.count, by: Self.columnCount).map { start in
            Array(cells[start..<start + Self.columnCount])
        }
    }

    /// All cells for the month. nil entries pad the leading days before the 1st.
    private var monthDays: [Date?] {
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
