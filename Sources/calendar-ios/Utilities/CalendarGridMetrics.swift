import CoreGraphics

/// Shared layout constants for the month grid.
///
/// The day cell ratio is supplied by the cell view itself (see
/// `View.calendarDayAspectRatio(_:)`); these values are the fallback and the
/// math that turns that ratio into the month container's bounds.
enum CalendarGridMetrics {

    /// Width-to-height ratio used when a day cell doesn't declare one.
    static let defaultDayCellAspectRatio: CGFloat = 1.0

    /// Width-to-height ratio applied to every weekday label cell.
    static let weekdayLabelAspectRatio: CGFloat = 1.0

    /// The width-to-height ratio of a whole month grid, including the
    /// weekday label row.
    ///
    /// With a column width of `w`, each day row contributes `w / dayCellAspectRatio`
    /// of height and the label row contributes `w / weekdayLabelAspectRatio`,
    /// while total width is `7 * w`. The `w` terms cancel out.
    static func monthGridAspectRatio(weekRows: Int, dayCellAspectRatio: CGFloat) -> CGFloat {
        let ratio = dayCellAspectRatio > 0 ? dayCellAspectRatio : defaultDayCellAspectRatio
        let dayRowsHeight = CGFloat(weekRows) / ratio
        let labelRowHeight = 1 / weekdayLabelAspectRatio
        return 7.0 / (dayRowsHeight + labelRowHeight)
    }
}
