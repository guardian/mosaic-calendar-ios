import CoreGraphics

/// Shared layout constants for the month grid.
///
/// These are the single source of truth for cell proportions so the grid
/// itself and the container that sizes it (via `aspectRatio`) can never drift
/// out of sync and overflow their bounds.
enum CalendarGridMetrics {

    /// Width-to-height ratio applied to every day cell.
    static let dayCellAspectRatio: CGFloat = 0.85

    /// Width-to-height ratio applied to every weekday label cell.
    static let weekdayLabelAspectRatio: CGFloat = 1.0

    /// The width-to-height ratio of a whole month grid, including the
    /// weekday label row.
    ///
    /// With a column width of `w`, each row contributes `w / ratio` of height,
    /// so total height is `weekRows * w / dayCellAspectRatio + w / weekdayLabelAspectRatio`
    /// while total width is `7 * w`. The `w` terms cancel out.
    static func monthGridAspectRatio(weekRows: Int) -> CGFloat {
        let dayRowsHeight = CGFloat(weekRows) / dayCellAspectRatio
        let labelRowHeight = 1 / weekdayLabelAspectRatio
        return 7.0 / (dayRowsHeight + labelRowHeight)
    }
}
