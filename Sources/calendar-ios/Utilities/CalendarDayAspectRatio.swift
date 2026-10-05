import SwiftUI

/// Carries the day cell's preferred width-to-height ratio up to the calendar
/// so the month container can size itself to fit exactly.
struct CalendarDayAspectRatioPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat? = nil

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}

public extension View {

    /// Declares the width-to-height ratio this day cell should be laid out with.
    ///
    /// Apply this inside a `CalendarDayViewable`'s `body`. The calendar reads
    /// the value and grows or shrinks the month grid's bounds to match, so the
    /// last row of days can never overflow.
    ///
    /// ```swift
    /// struct MyDayCell: CalendarDayViewable {
    ///     var day: any CalendarDayRepresentable
    ///
    ///     var body: some View {
    ///         Text(day.date.formatted(.dateTime.day()))
    ///             .frame(maxWidth: .infinity, maxHeight: .infinity)
    ///             .calendarDayAspectRatio(0.85)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter ratio: Width divided by height. Values below `1` make cells
    ///   taller than they are wide. Defaults to `1` (square) when unspecified.
    func calendarDayAspectRatio(_ ratio: CGFloat) -> some View {
        aspectRatio(ratio, contentMode: .fit)
            .preference(key: CalendarDayAspectRatioPreferenceKey.self, value: ratio)
    }
}
