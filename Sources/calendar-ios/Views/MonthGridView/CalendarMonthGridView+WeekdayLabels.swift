import SwiftUI

// MARK: - Weekday labels

extension CalendarMonthGridView {

    /// Laid out with the same explicit column width as the day rows so the
    /// labels stay aligned with their columns.
    func weekdayLabels(columnWidth: CGFloat, rowHeight: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { index, symbol in
                let isSelected = isSelectedWeekday(columnIndex: index)

                Group {
                    if let weekdayLabelContent {
                        weekdayLabelContent(symbol, isSelected)
                    } else {
                        Text(symbol)
                            .font(.caption.weight(isSelected ? .bold : .semibold))
                            .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                    }
                }
                .frame(width: columnWidth, height: rowHeight)
            }
        }
    }

    /// `true` when the selected date falls on this column's weekday.
    private func isSelectedWeekday(columnIndex: Int) -> Bool {
        guard let selectedDate else { return false }
        let calendar: Calendar = .current
        let selectedWeekday = calendar.component(.weekday, from: selectedDate)
        // Columns start at the calendar's first weekday, so shift accordingly.
        let columnWeekday = ((calendar.firstWeekday - 1 + columnIndex) % 7) + 1
        return selectedWeekday == columnWeekday
    }

    /// Localized short weekday symbols reordered to match the calendar's first weekday.
    private var weekdaySymbols: [String] {
        let calendar: Calendar = .current
        let symbols = calendar.weekdaySymbols.map({ "\($0.prefix(2))" })
        let firstWeekday = calendar.firstWeekday - 1
        return Array(symbols[firstWeekday...] + symbols[..<firstWeekday])
    }
}
