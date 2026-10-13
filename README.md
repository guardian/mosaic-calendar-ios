<img width="245" alt="Group 533" src="https://github.com/user-attachments/assets/ddd16d56-cc05-4b00-990f-c2ba08fd4c92" />


# Mosaic Calendar

A modern, fully SwiftUI calendar with smooth month paging, built-in month picker, and flexible customization for cells, headers, weekday labels, and month tiles.

## Highlights

- 📅 Horizontally paged month calendar
- 🧭 Optional built-in header or fully custom header
- 🗓️ Optional custom weekday labels
- 🧩 Optional custom month-picker cells
- 🎯 Day selection + month-change callbacks
- 🪶 Lightweight API built around SwiftUI view builders

## Requirements

- iOS 18+
- Swift 6

## Installation (Swift Package Manager)

Add this package to your app:

```swift
.package(url: "https://github.com/guardian/mosaic-calendar-ios.git", branch: "main")
```

Then import:

```swift
import MosaicCalendar
```

## Core model

`MosaicCalendarView` takes an array of days conforming to `CalendarDayRepresentable`.

```swift
import SwiftUI
import MosaicCalendar

struct MyCalendarDay: CalendarDayRepresentable {
    var id: Date { date }
    let date: Date
    let color: Color
    var isToday: Bool = false
    var isSelected: Bool = false
}
```

## Quick start (default header)

```swift
MosaicCalendarView(days: days) { day in
    Text(day.date.formatted(.dateTime.day()))
        .foregroundStyle(day.isSelected ? .white : (day.isToday ? .orange : .primary))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(day.isSelected ? Color.blue : Color.clear)
}
.padding()
```

## Protocols required for custom views

Custom view structs passed into `MosaicCalendarView` must conform to the matching protocol:

- Day cells: `CalendarDayViewable` and expose `var day: any CalendarDayRepresentable`
- Custom headers: `CalendarHeaderViewable` and expose `var context: any CalendarHeaderContextRepresentable`
- Custom weekday labels: `CalendarWeekdayViewable` and expose `var symbol: String`
- Custom month picker tiles: `CalendarMonthViewable` and expose `var context: CalendarMonthPickerCellContext`

Example day-cell struct:

```swift
struct DayCell: CalendarDayViewable {
    let day: any CalendarDayRepresentable

    var body: some View {
        Text(day.date.formatted(.dateTime.day()))
    }
}
```

## Usage examples

### 1) Restrict visible months with `range`

```swift
let range = Date.now.monthAndYear.adding(months: -12)! ... Date.now.monthAndYear.adding(months: 12)!

MosaicCalendarView(days: days, range: range) { day in
    DayCell(day: day)
}
```

### 2) Custom header

```swift
struct CustomHeader: CalendarHeaderViewable {
    let context: any CalendarHeaderContextRepresentable

    var body: some View {
        Text(context.month.formatted(.dateTime.month(.wide).year()))
    }
}

MosaicCalendarView(days: days) { day in
    DayCell(day: day)
} header: { context in
    CustomHeader(context: context)
}
```

Your header receives `CalendarHeaderContext`, which lets you:

- read month/year state
- switch between month and year picker mode
- move month/year backward and forward
- select a month directly

### 3) Default header + custom weekday labels

```swift
struct CustomWeekdayLabel: CalendarWeekdayViewable {
    let symbol: String
    /// `true` when the selected date falls on this weekday.
    let isSelected: Bool

    var body: some View {
        Text(symbol)
            .fontWeight(isSelected ? .bold : .regular)
    }
}

MosaicCalendarView(days: days) { day in
    DayCell(day: day)
} weekdayLabel: { symbol, isSelected in
    CustomWeekdayLabel(symbol: symbol, isSelected: isSelected)
}
```

### 4) Default header + custom month picker tiles

```swift
struct CustomMonthTile: CalendarMonthViewable {
    let context: CalendarMonthPickerCellContext

    var body: some View {
        Text(context.monthLabel)
    }
}

MosaicCalendarView(days: days) { day in
    DayCell(day: day)
} monthPickerCell: { context in
    CustomMonthTile(context: context)
}
```

### 5) Fully custom (header + weekday + month picker)

`MosaicCalendarView` has separate overloads:
- Default header overloads use `weekdayLabel` and `monthPickerCell`.
- Custom header overloads use `weekday` and `month`.

When you provide a custom `header`, use the `weekday` and `month` labels:

```swift
MosaicCalendarView(days: days, range: range) { day in
    DayCell(day: day)
} header: { context in
    CustomHeader(context: context)
} weekday: { symbol, isSelected in
    CustomWeekdayLabel(symbol: symbol, isSelected: isSelected)
} month: { context in
    CustomMonthTile(context: context)
}
```

## All available `MosaicCalendarView` modifiers

These are the calendar-specific chainable modifiers currently available:

### `.onDateSelected(_:)`

Called when a date is selected.

```swift
.onDateSelected { date, markedDay in
    print("Selected:", date)
    print("Day payload exists:", markedDay != nil)
}
```

- `date`: selected date
- `markedDay`: matching element from your `days` array for that date (if present)

### `.onMonthChange(_:)`

Called when the visible month changes (initial render, swipe, header navigation, or month picker selection).

```swift
.onMonthChange { interval in
    print("Now showing month starting", interval.start)
}
```

- `interval`: `DateInterval` for the currently visible month, from `startOfMonth` to `startOfNextMonth`.

## API notes

- If `range` is omitted, the calendar shows a 5-month window centered on the current month.
- If `range` is provided, month navigation and month-picker availability are clamped to that range.
- `days` are keyed by start-of-day date, so provide day-level dates (time components are ignored for matching).


---

Thank you for using Mosaic!

*iOS Team, The Guardian*
