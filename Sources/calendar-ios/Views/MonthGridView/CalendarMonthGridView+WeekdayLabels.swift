import SwiftUI

// MARK: - Weekday labels

extension CalendarMonthGridView {

    /// Laid out with the same explicit column width as the day rows so the
    /// labels stay aligned with their columns.
    func weekdayLabels(columnWidth: CGFloat, rowHeight: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Group {
                    if let weekdayLabelContent {
                        weekdayLabelContent(symbol)
                    } else {
                        Text(symbol)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: columnWidth, height: rowHeight)
            }
        }
    }

    /// Localized short weekday symbols reordered to match the calendar's first weekday.
    private var weekdaySymbols: [String] {
        let calendar: Calendar = .current
        let symbols = calendar.weekdaySymbols.map({ "\($0.prefix(2))" })
        let firstWeekday = calendar.firstWeekday - 1
        return Array(symbols[firstWeekday...] + symbols[..<firstWeekday])
    }
}
