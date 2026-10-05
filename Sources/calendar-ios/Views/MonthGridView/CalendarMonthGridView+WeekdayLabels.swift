import SwiftUI

// MARK: - Weekday labels

extension CalendarMonthGridView {

    var weekdayLabels: some View {
        LazyVGrid(columns: columns, spacing: 0) {
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(CalendarGridMetrics.weekdayLabelAspectRatio, contentMode: .fit)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Localized short weekday symbols reordered to match the calendar's first weekday.
    private var weekdaySymbols: [String] {
        let calendar: Calendar = .current
        let symbols = calendar.weekdaySymbols.map({ "\($0.prefix(2))" })
        let firstWeekday = calendar.firstWeekday - 1
        return Array(symbols[firstWeekday...] + symbols[..<firstWeekday])
    }
}
