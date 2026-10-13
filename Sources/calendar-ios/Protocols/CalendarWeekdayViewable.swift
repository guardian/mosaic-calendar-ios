import SwiftUI

/// Marker protocol for custom weekday label views.
///
/// Conforming views must expose the weekday symbol they render and whether
/// that weekday matches the currently selected date.
public protocol CalendarWeekdayViewable: View {
    var symbol: String { get }

    /// `true` when the selected date falls on this weekday.
    var isSelected: Bool { get }
}
