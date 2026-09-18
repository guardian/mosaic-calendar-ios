import SwiftUI

public extension MosaicCalendarView where Header == CalendarHeaderView {
    init(
        days: [any CalendarDayRepresentable] = [],
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell
    ) {
        self.init(days: days, range: range, cell: cell) { context in
            CalendarHeaderView(context: context)
        }
    }

    init(
        days: Binding<[any CalendarDayRepresentable]>,
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell
    ) {
        self.init(days: days, range: range, cell: cell) { context in
            CalendarHeaderView(context: context)
        }
    }

    init<WeekdayLabel: CalendarWeekdayViewable>(
        days: [any CalendarDayRepresentable] = [],
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder weekdayLabel: @escaping (String) -> WeekdayLabel
    ) {
        self.init(days: days, range: range, cell: cell, header: { context in
            CalendarHeaderView(context: context)
        }, weekday: weekdayLabel)
    }

    init<WeekdayLabel: CalendarWeekdayViewable>(
        days: Binding<[any CalendarDayRepresentable]>,
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder weekdayLabel: @escaping (String) -> WeekdayLabel
    ) {
        self.init(days: days, range: range, cell: cell, header: { context in
            CalendarHeaderView(context: context)
        }, weekday: weekdayLabel)
    }

    init<MonthPickerCell: CalendarMonthViewable>(
        days: [any CalendarDayRepresentable] = [],
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder monthPickerCell: @escaping (CalendarMonthPickerCellContext) -> MonthPickerCell
    ) {
        self.init(days: days, range: range, cell: cell, header: { context in
            CalendarHeaderView(context: context)
        }, monthPickerCell: monthPickerCell)
    }

    init<MonthPickerCell: CalendarMonthViewable>(
        days: Binding<[any CalendarDayRepresentable]>,
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder monthPickerCell: @escaping (CalendarMonthPickerCellContext) -> MonthPickerCell
    ) {
        self.init(days: days, range: range, cell: cell, header: { context in
            CalendarHeaderView(context: context)
        }, monthPickerCell: monthPickerCell)
    }

    init<WeekdayLabel: CalendarWeekdayViewable, MonthPickerCell: CalendarMonthViewable>(
        days: [any CalendarDayRepresentable] = [],
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder weekdayLabel: @escaping (String) -> WeekdayLabel,
        @ViewBuilder month: @escaping (CalendarMonthPickerCellContext) -> MonthPickerCell
    ) {
        self.init(days: days, range: range, cell: cell, header: { context in
            CalendarHeaderView(context: context)
        }, weekday: weekdayLabel, month: month)
    }

    init<WeekdayLabel: CalendarWeekdayViewable, MonthPickerCell: CalendarMonthViewable>(
        days: Binding<[any CalendarDayRepresentable]>,
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder weekdayLabel: @escaping (String) -> WeekdayLabel,
        @ViewBuilder month: @escaping (CalendarMonthPickerCellContext) -> MonthPickerCell
    ) {
        self.init(days: days, range: range, cell: cell, header: { context in
            CalendarHeaderView(context: context)
        }, weekday: weekdayLabel, month: month)
    }
}
