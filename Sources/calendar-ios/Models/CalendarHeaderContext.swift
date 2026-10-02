import Foundation
import Observation

@Observable
public final class CalendarHeaderContext: CalendarHeaderContextRepresentable {
    public private(set) var displayMode: CalendarHeaderDisplayMode = .month
    public private(set) var month: Date = Date()
    public private(set) var pickerYear: Int = Calendar.current.component(.year, from: Date())
    public private(set) var canGoToPreviousMonth: Bool = false
    public private(set) var canGoToNextMonth: Bool = false
    public private(set) var canGoToPreviousYear: Bool = false
    public private(set) var canGoToNextYear: Bool = false

    private var minimumVisibleYear: Int = 0
    private var maximumVisibleYear: Int = 0

    var requestedMonthOffset: Int?
    var requestedMonthSelection: Date?

    public init(
        month: Date,
        canGoToPreviousMonth: Bool,
        canGoToNextMonth: Bool,
        minimumVisibleYear: Int,
        maximumVisibleYear: Int
    ) {
        let year = Calendar.current.component(.year, from: month)
        let minVisibleYear = min(minimumVisibleYear, maximumVisibleYear)
        let maxVisibleYear = max(minimumVisibleYear, maximumVisibleYear)
        self.displayMode = .month
        self.month = month
        self.pickerYear = year
        self.canGoToPreviousMonth = canGoToPreviousMonth
        self.canGoToNextMonth = canGoToNextMonth
        self.minimumVisibleYear = minVisibleYear
        self.maximumVisibleYear = maxVisibleYear
        self.canGoToPreviousYear = year > minVisibleYear
        self.canGoToNextYear = year < maxVisibleYear
    }

    public func changeMonth(by value: Int) {
        requestedMonthOffset = value
    }

    public func changeYear(by value: Int) {
        let nextYear = pickerYear + value
        guard nextYear >= minimumVisibleYear, nextYear <= maximumVisibleYear else { return }
        pickerYear = nextYear
        updateYearNavigationAvailability()
    }

    func setPickerYear(_ year: Int) {
        guard year >= minimumVisibleYear, year <= maximumVisibleYear else { return }
        pickerYear = year
        updateYearNavigationAvailability()
    }

    public func toggleDisplayMode() {
        switch displayMode {
        case .month:
            displayMode = .year
            pickerYear = Calendar.current.component(.year, from: month)
            updateYearNavigationAvailability()
        case .year:
            displayMode = .month
        }
    }

    public func showMonthView() {
        displayMode = .month
    }

    public func selectMonth(_ month: Date) {
        requestedMonthSelection = month.monthAndYear
        displayMode = .month
    }

    func apply(
        month: Date,
        canGoToPreviousMonth: Bool,
        canGoToNextMonth: Bool,
        minimumVisibleYear: Int,
        maximumVisibleYear: Int
    ) {
        self.minimumVisibleYear = min(minimumVisibleYear, maximumVisibleYear)
        self.maximumVisibleYear = max(minimumVisibleYear, maximumVisibleYear)
        self.month = month
        self.canGoToPreviousMonth = canGoToPreviousMonth
        self.canGoToNextMonth = canGoToNextMonth

        if pickerYear < self.minimumVisibleYear {
            pickerYear = self.minimumVisibleYear
        } else if pickerYear > self.maximumVisibleYear {
            pickerYear = self.maximumVisibleYear
        }

        if displayMode == .month {
            pickerYear = Calendar.current.component(.year, from: month)
            updateYearNavigationAvailability()
        }
    }

    func clearRequestedMonthOffset() {
        requestedMonthOffset = nil
    }

    func clearRequestedMonthSelection() {
        requestedMonthSelection = nil
    }

    private func updateYearNavigationAvailability() {
        canGoToPreviousYear = pickerYear > minimumVisibleYear
        canGoToNextYear = pickerYear < maximumVisibleYear
    }
}
