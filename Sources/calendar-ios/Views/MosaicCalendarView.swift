import SwiftUI

@MainActor
public struct MosaicCalendarView<Header: CalendarHeaderViewable, Cell: CalendarDayViewable>: View {

    /// The month currently scrolled into view (a start-of-month date).
    @State var scrolledMonth: Date?

    /// The day the user has tapped, if any.
    @State private var selectedDate: Date? = Date()

    /// Ensures initial pager recentering only runs once per view lifecycle.
    @State private var didRunInitialPagerRecentering = false

    /// Observable month state consumed by custom headers.
    @State var headerContext: CalendarHeaderContext

    /// Source days used to build month cells. Binding keeps updates reactive.
    @Binding private var days: [any CalendarDayRepresentable]

    /// Optional visible month range. Binding allows runtime range updates.
    @Binding var range: ClosedRange<Date>?

    /// Calendar and anchor used to derive visible months.
    private let calendar: Calendar
    private let anchorMonth: Date

    /// A stable month window derived from the current range binding.
    var months: [Date] {
        Self.makeVisibleMonths(calendar: calendar, range: range, anchor: anchorMonth)
    }

    /// Builds the view for a given day.
    private let cellContent: (any CalendarDayRepresentable) -> Cell

    /// Builds the header view for the current month.
    private let headerContent: (CalendarHeaderContext) -> Header

    /// Optionally builds the view for a weekday label symbol.
    private let weekdayLabelContent: ((String) -> AnyView)?

    /// Optionally builds the view for a month picker cell.
    let monthPickerCellContent: ((CalendarMonthPickerCellContext) -> AnyView)?

    /// Called whenever the visible month changes, with that month's date interval.
    private var monthChangeHandler: ((DateInterval) -> Void)?

    /// Called when a day is tapped, with the date and its mark (if any).
    private var dateSelectHandler: ((Date, (any CalendarDayRepresentable)?) -> Void)?

    public init(
        days: [any CalendarDayRepresentable] = [],
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder header: @escaping (CalendarHeaderContext) -> Header
    ) {
        self.init(
            days: .constant(days),
            range: .constant(range),
            cellContent: cell,
            headerContent: header,
            weekdayLabelContent: nil,
            monthPickerCellContent: nil
        )
    }

    public init(
        days: Binding<[any CalendarDayRepresentable]>,
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder header: @escaping (CalendarHeaderContext) -> Header
    ) {
        self.init(
            days: days,
            range: .constant(range),
            cellContent: cell,
            headerContent: header,
            weekdayLabelContent: nil,
            monthPickerCellContent: nil
        )
    }

    public init(
        days: Binding<[any CalendarDayRepresentable]>,
        range: Binding<ClosedRange<Date>?>,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder header: @escaping (CalendarHeaderContext) -> Header
    ) {
        self.init(
            days: days,
            range: range,
            cellContent: cell,
            headerContent: header,
            weekdayLabelContent: nil,
            monthPickerCellContent: nil
        )
    }

    public init<WeekdayLabel: CalendarWeekdayViewable>(
        days: [any CalendarDayRepresentable] = [],
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder header: @escaping (CalendarHeaderContext) -> Header,
        @ViewBuilder weekday: @escaping (String) -> WeekdayLabel
    ) {
        self.init(
            days: .constant(days),
            range: .constant(range),
            cellContent: cell,
            headerContent: header,
            weekdayLabelContent: { symbol in AnyView(weekday(symbol)) },
            monthPickerCellContent: nil
        )
    }

    public init<WeekdayLabel: CalendarWeekdayViewable>(
        days: Binding<[any CalendarDayRepresentable]>,
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder header: @escaping (CalendarHeaderContext) -> Header,
        @ViewBuilder weekday: @escaping (String) -> WeekdayLabel
    ) {
        self.init(
            days: days,
            range: .constant(range),
            cellContent: cell,
            headerContent: header,
            weekdayLabelContent: { symbol in AnyView(weekday(symbol)) },
            monthPickerCellContent: nil
        )
    }

    public init<WeekdayLabel: CalendarWeekdayViewable>(
        days: Binding<[any CalendarDayRepresentable]>,
        range: Binding<ClosedRange<Date>?>,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder header: @escaping (CalendarHeaderContext) -> Header,
        @ViewBuilder weekday: @escaping (String) -> WeekdayLabel
    ) {
        self.init(
            days: days,
            range: range,
            cellContent: cell,
            headerContent: header,
            weekdayLabelContent: { symbol in AnyView(weekday(symbol)) },
            monthPickerCellContent: nil
        )
    }

    public init<MonthPickerCell: CalendarMonthViewable>(
        days: [any CalendarDayRepresentable] = [],
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder header: @escaping (CalendarHeaderContext) -> Header,
        @ViewBuilder monthPickerCell: @escaping (CalendarMonthPickerCellContext) -> MonthPickerCell
    ) {
        self.init(
            days: .constant(days),
            range: .constant(range),
            cellContent: cell,
            headerContent: header,
            weekdayLabelContent: nil,
            monthPickerCellContent: { context in AnyView(monthPickerCell(context)) }
        )
    }

    public init<MonthPickerCell: CalendarMonthViewable>(
        days: Binding<[any CalendarDayRepresentable]>,
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder header: @escaping (CalendarHeaderContext) -> Header,
        @ViewBuilder monthPickerCell: @escaping (CalendarMonthPickerCellContext) -> MonthPickerCell
    ) {
        self.init(
            days: days,
            range: .constant(range),
            cellContent: cell,
            headerContent: header,
            weekdayLabelContent: nil,
            monthPickerCellContent: { context in AnyView(monthPickerCell(context)) }
        )
    }

    public init<MonthPickerCell: CalendarMonthViewable>(
        days: Binding<[any CalendarDayRepresentable]>,
        range: Binding<ClosedRange<Date>?>,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder header: @escaping (CalendarHeaderContext) -> Header,
        @ViewBuilder monthPickerCell: @escaping (CalendarMonthPickerCellContext) -> MonthPickerCell
    ) {
        self.init(
            days: days,
            range: range,
            cellContent: cell,
            headerContent: header,
            weekdayLabelContent: nil,
            monthPickerCellContent: { context in AnyView(monthPickerCell(context)) }
        )
    }

    public init<WeekdayLabel: CalendarWeekdayViewable, MonthPickerCell: CalendarMonthViewable>(
        days: [any CalendarDayRepresentable] = [],
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder header: @escaping (CalendarHeaderContext) -> Header,
        @ViewBuilder weekday: @escaping (String) -> WeekdayLabel,
        @ViewBuilder month: @escaping (CalendarMonthPickerCellContext) -> MonthPickerCell
    ) {
        self.init(
            days: .constant(days),
            range: .constant(range),
            cellContent: cell,
            headerContent: header,
            weekdayLabelContent: { symbol in AnyView(weekday(symbol)) },
            monthPickerCellContent: { context in AnyView(month(context)) }
        )
    }

    public init<WeekdayLabel: CalendarWeekdayViewable, MonthPickerCell: CalendarMonthViewable>(
        days: Binding<[any CalendarDayRepresentable]>,
        range: ClosedRange<Date>? = nil,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder header: @escaping (CalendarHeaderContext) -> Header,
        @ViewBuilder weekday: @escaping (String) -> WeekdayLabel,
        @ViewBuilder month: @escaping (CalendarMonthPickerCellContext) -> MonthPickerCell
    ) {
        self.init(
            days: days,
            range: .constant(range),
            cellContent: cell,
            headerContent: header,
            weekdayLabelContent: { symbol in AnyView(weekday(symbol)) },
            monthPickerCellContent: { context in AnyView(month(context)) }
        )
    }

    public init<WeekdayLabel: CalendarWeekdayViewable, MonthPickerCell: CalendarMonthViewable>(
        days: Binding<[any CalendarDayRepresentable]>,
        range: Binding<ClosedRange<Date>?>,
        @ViewBuilder cell: @escaping (any CalendarDayRepresentable) -> Cell,
        @ViewBuilder header: @escaping (CalendarHeaderContext) -> Header,
        @ViewBuilder weekday: @escaping (String) -> WeekdayLabel,
        @ViewBuilder month: @escaping (CalendarMonthPickerCellContext) -> MonthPickerCell
    ) {
        self.init(
            days: days,
            range: range,
            cellContent: cell,
            headerContent: header,
            weekdayLabelContent: { symbol in AnyView(weekday(symbol)) },
            monthPickerCellContent: { context in AnyView(month(context)) }
        )
    }

    private init(
        days: Binding<[any CalendarDayRepresentable]>,
        range: Binding<ClosedRange<Date>?>,
        cellContent: @escaping (any CalendarDayRepresentable) -> Cell,
        headerContent: @escaping (CalendarHeaderContext) -> Header,
        weekdayLabelContent: ((String) -> AnyView)?,
        monthPickerCellContent: ((CalendarMonthPickerCellContext) -> AnyView)?
    ) {
        let calendar = Calendar.current
        let anchor = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) ?? .now
        let visibleMonths = Self.makeVisibleMonths(calendar: calendar, range: range.wrappedValue, anchor: anchor)

        _days = days
        _range = range
        self.calendar = calendar
        self.anchorMonth = anchor
        self.cellContent = cellContent
        self.headerContent = headerContent
        self.weekdayLabelContent = weekdayLabelContent
        self.monthPickerCellContent = monthPickerCellContent

        // Start centered on the current month or clamp to the nearest month in range.
        let initialMonth = Self.initialMonth(for: anchor, in: visibleMonths)
        let minimumVisibleYear = calendar.component(.year, from: visibleMonths.first ?? anchor)
        let maximumVisibleYear = calendar.component(.year, from: visibleMonths.last ?? anchor)
        _scrolledMonth = State(initialValue: initialMonth)
        _headerContext = State(
            initialValue: CalendarHeaderContext(
                month: initialMonth,
                canGoToPreviousMonth: initialMonth != visibleMonths.first,
                canGoToNextMonth: initialMonth != visibleMonths.last,
                minimumVisibleYear: minimumVisibleYear,
                maximumVisibleYear: maximumVisibleYear
            )
        )
    }

    private static func makeDaysByDate(from days: [any CalendarDayRepresentable]) -> [Date: any CalendarDayRepresentable] {
        let calendar = Calendar.current
        return Dictionary(
            days.map { (calendar.startOfDay(for: $0.date), $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    /// The month currently displayed (falls back to the center of the window).
    var displayedMonth: Date {
        scrolledMonth ?? months[middleMonthIndex]
    }

    private var middleMonthIndex: Int {
        max(0, min(months.count - 1, months.count / 2))
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerContent(headerContext)
            ZStack(alignment: .top) {
                if headerContext.displayMode == .month {
                    pager
                        .aspectRatio(monthGridAspectRatio(for: displayedMonth), contentMode: .fit)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }

                if headerContext.displayMode == .year {
                    monthPicker
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .transition(.opacity.combined(with: .scale(scale: 1.02)))
                }
            }
            .animation(.spring, value: headerContext.displayMode)
            .animation(.easeInOut(duration: 0.2), value: displayedMonth)
        }
        .onAppear {
            syncHeaderContext()
            notifyMonthChange()
        }
        .onChange(of: scrolledMonth) {
            syncHeaderContext()
            notifyMonthChange()
        }
        .onChange(of: range) {
            handleRangeChange()
        }
        .onChange(of: headerContext.displayMode, { oldValue, newValue in

        })
        .onChange(of: headerContext.requestedMonthOffset) {
            guard let value = headerContext.requestedMonthOffset else { return }
            headerContext.clearRequestedMonthOffset()
            changeMonth(by: value)
        }
        .onChange(of: headerContext.requestedMonthSelection) {
            guard let value = headerContext.requestedMonthSelection else { return }
            headerContext.clearRequestedMonthSelection()
            headerContext.showMonthView()

            // Wait one UI cycle so the pager is mounted before animating to selection.
            Task { @MainActor in
                await Task.yield()
                setDisplayedMonth(to: value)
                notifyMonthChange()
            }
        }
    }

    private func syncHeaderContext() {
        let minimumVisibleYear = calendar.component(.year, from: months.first ?? anchorMonth)
        let maximumVisibleYear = calendar.component(.year, from: months.last ?? anchorMonth)
        headerContext.apply(
            month: displayedMonth,
            canGoToPreviousMonth: displayedMonth != months.first,
            canGoToNextMonth: displayedMonth != months.last,
            minimumVisibleYear: minimumVisibleYear,
            maximumVisibleYear: maximumVisibleYear
        )
    }

    private func handleRangeChange() {
        let clampedMonth = Self.initialMonth(for: scrolledMonth ?? anchorMonth, in: months)
        if scrolledMonth != clampedMonth {
            scrolledMonth = clampedMonth
        }
        syncHeaderContext()
        notifyMonthChange()
    }

    /// Invokes the registered handler with the displayed month's interval.
    private func notifyMonthChange() {
        monthChangeHandler?(monthInterval(for: displayedMonth))
    }

    /// Invokes the registered handler with the selected date and its mark.
    private func notifyDateSelect(_ date: Date, dayLookup: [Date: any CalendarDayRepresentable]) {
        dateSelectHandler?(date, dayLookup[date.beginningOfDay])
    }

    private func handleDayTapped(_ date: Date, dayLookup: [Date: any CalendarDayRepresentable]) {
        selectedDate = date
        notifyDateSelect(date, dayLookup: dayLookup)
    }

    // MARK: - Paging grid

    /// A horizontally paged, lazily loaded stack of month grids. Only the
    /// visible month (and its immediate neighbors) are ever instantiated.
    ///
    private var pager: some View {
        let dayLookup = Self.makeDaysByDate(from: days)

        return ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 20) {
                    ForEach(months, id: \.self) { month in
                        CalendarMonthGridView(
                            month: month,
                            selectedDate: $selectedDate,
                            daysByDate: dayLookup,
                            cellContent: cellContent,
                            weekdayLabelContent: weekdayLabelContent,
                            onDayTapped: { tappedDate in
                                handleDayTapped(tappedDate, dayLookup: dayLookup)
                            }
                        )
                        .containerRelativeFrame(.horizontal, alignment: .top)
                        .clipped()
                        .scrollTransition { effect, phase in
                            effect
                                .opacity(phase.isIdentity ? 1 : 0.15)
                                .blur(radius: phase.isIdentity ? 0 : 2)
                        }
                        .id(month)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledMonth, anchor: .center)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .onAppear {
                recenterPagerAfterInitialLayout(using: proxy)
            }
        }
    }

    private func recenterPagerAfterInitialLayout(using proxy: ScrollViewProxy) {
        guard !didRunInitialPagerRecentering, let targetMonth = scrolledMonth else { return }
        didRunInitialPagerRecentering = true

        Task { @MainActor in
            // Give SwiftUI an extra pass to settle geometry after conditional mount.
            await Task.yield()
            await Task.yield()

            var transaction = Transaction()
            transaction.disablesAnimations = true

            withTransaction(transaction) {
                proxy.scrollTo(targetMonth, anchor: .center)
            }

            // One more pass catches late layout updates from parent transitions.
            await Task.yield()
            withTransaction(transaction) {
                proxy.scrollTo(targetMonth, anchor: .center)
            }
        }
    }

    /// Keeps day cells square while reducing total height for 4/5-week months.
    private func monthGridAspectRatio(for month: Date) -> CGFloat {
        let weekRows = weekRowCount(for: month)
        let totalRows = weekRows + 1 // +1 for weekday labels
        return 7.0 / CGFloat(totalRows)
    }

    private func weekRowCount(for month: Date) -> Int {
        guard let dayRange = calendar.range(of: .day, in: .month, for: month),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else {
            return 6
        }

        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmptyCount = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        let totalDayCells = leadingEmptyCount + dayRange.count

        return Int(ceil(Double(totalDayCells) / 7.0))
    }

    // MARK: - Modifiers

    /// Registers a handler that fires whenever the displayed month changes
    /// (via swipe, the chevron buttons, or the initial appearance), passing
    /// that month's date interval.
    public func onMonthChange(_ handler: @escaping (DateInterval) -> Void) -> Self {
        var copy = self
        copy.monthChangeHandler = handler
        return copy
    }

    /// Registers a handler that fires when a day is tapped, passing the
    /// selected date and its mark (if one exists on that day).
    public func onDateSelected(_ handler: @escaping (Date, (any CalendarDayRepresentable)?) -> Void) -> Self {
        var copy = self
        copy.dateSelectHandler = handler
        return copy
    }
}
