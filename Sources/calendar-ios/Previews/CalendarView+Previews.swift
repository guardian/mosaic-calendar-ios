import SwiftUI

private let previewDays: [PreviewCalendarDay] = [
    PreviewCalendarDay(date: .now, color: .blue),
    PreviewCalendarDay(date: .now.adding(days: 1)!, color: .green),
    PreviewCalendarDay(date: .now.adding(days: 3)!, color: .orange),
    PreviewCalendarDay(date: .now.adding(days: 5)!, color: .pink)
]

private let previewRange: ClosedRange<Date> =
Date.now.monthAndYear.adding(months: -24)!...Date.now.monthAndYear.adding(months: 24)!

#Preview("Basic") {
    ScrollView {
        MosaicCalendarView(days: previewDays) { day in
            BasicPreviewDayCell(day: day)
        }
    }
}

#Preview("Custom Header + Custom Weekday + Month Picker + Callbacks") {
    InteractiveCalendarPreview()
}

#Preview("Default Header + Weekday Labels") {
    ScrollView {
        MosaicCalendarView(days: previewDays) { day in
            PreviewDayCell(day: day)
        } weekdayLabel: { symbol in
            PreviewWeekdayLabel(symbol: symbol)
        }
        .border(.black)
    }
}

#Preview("Custom Header") {
    ScrollView {
        MosaicCalendarView(days: previewDays) { day in
            PreviewDayCell(day: day)
        } header: { context in
            PreviewHeaderView(context: context)
        }
        .border(.black)
    }
}

private struct PreviewWeekdayLabel: CalendarWeekdayViewable {
    let symbol: String

    var body: some View {
        Text(symbol)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct PreviewHeaderView: CalendarHeaderViewable {
    let context: any CalendarHeaderContextRepresentable

    var body: some View {
        HStack {
            Button {
                if context.displayMode == .year {
                    context.changeYear(by: -1)
                } else {
                    context.changeMonth(by: -1)
                }
            } label: {
                Image(systemName: "hand.point.left")
            }
            .disabled(isBackwardDisabled)
            .accessibilityLabel(context.displayMode == .year ? "Previous year" : "Previous month")

            Spacer()

            Text(title)
                .font(.headline)
                .italic()
                .contentShape(Rectangle())
                .onTapGesture {
                    context.toggleDisplayMode()
                }

            Spacer()

            Button {
                if context.displayMode == .year {
                    context.changeYear(by: 1)
                } else {
                    context.changeMonth(by: 1)
                }
            } label: {
                Image(systemName: "hand.point.right")
            }
            .disabled(isForwardDisabled)
            .accessibilityLabel(context.displayMode == .year ? "Next year" : "Next month")
        }
        .dynamicTypeSize(.large ... .accessibility1)
    }

    private var title: String {
        if context.displayMode == .year {
            return String(context.pickerYear)
        }
        return context.month.formatted(.dateTime.month(.wide).year())
    }

    private var isBackwardDisabled: Bool {
        if context.displayMode == .year {
            return context.canGoToPreviousYear == false
        }
        return context.canGoToPreviousMonth == false
    }

    private var isForwardDisabled: Bool {
        if context.displayMode == .year {
            return context.canGoToNextYear == false
        }
        return context.canGoToNextMonth == false
    }
}

private struct BasicPreviewDayCell: View, CalendarDayViewable {
    let day: any CalendarDayRepresentable

    var body: some View {
        Text(day.date.formatted(.dateTime.day()))
            .foregroundStyle(day.isSelected ? .blue : day.isToday ? .orange : .primary)
    }
}

private struct PreviewDayCell: CalendarDayViewable {
    var day: any CalendarDayRepresentable

    var previewDay: PreviewCalendarDay? {
        return day as? PreviewCalendarDay
    }
    
    var body: some View {
        Text(day.date.formatted(.dateTime.day()))
            .font(day.isToday ? .body : .subheadline)
            .dynamicTypeSize(.large ... .accessibility1)
            .fontWeight(day.isToday ? .black : .regular)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(day.isSelected ? Color.white : previewDay?.color ?? Color.primary)
            .background {
                Rectangle()
                    .fill(.black)
                    .opacity(day.isSelected ? 1 : 0)
            }
            .overlay {
                Rectangle()
                    .stroke(.gray)
            }
            .contentShape(Rectangle())
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits(day.isSelected ? [.isSelected] : [])
            // The cell decides its own proportions; the calendar adapts its
            // bounds to match.
            .calendarDayAspectRatio(0.85)
    }

    private var accessibilityLabel: String {
        let base = day.date.formatted(.dateTime.weekday(.wide).month(.wide).day())
        return day.isToday ? "\(base), Today" : base
    }
}

private struct PreviewMonthPickerCell: CalendarMonthViewable {
    let context: CalendarMonthPickerCellContext

    var body: some View {
        Text(context.monthLabel)
            .font(.caption.weight(.bold))
            .foregroundStyle(context.isSelected ? Color.white : Color.purple)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(context.isSelected ? Color.purple : Color.purple.opacity(0.15))
            }
            .padding(5)
    }
}

private struct InteractiveCalendarPreview: View {
    @State private var days = previewDays
    @State private var range: ClosedRange<Date>? = previewRange

    private var bridgedDaysBinding: Binding<[any CalendarDayRepresentable]> {
        Binding<[any CalendarDayRepresentable]>(
            get: { days.map { $0 as any CalendarDayRepresentable } },
            set: { newValue in
                days = newValue.compactMap { $0 as? PreviewCalendarDay }
            }
        )
    }

    private let randomColors: [Color] = [.blue, .green, .orange, .pink, .purple, .red, .teal, .indigo]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Button("Randomize One Day Color") {
                    randomizeOneDayColor()
                }

                MosaicCalendarView(days: bridgedDaysBinding, range: $range) { day in
                    PreviewDayCell(day: day)
                } header: { context in
                    PreviewHeaderView(context: context)
                } weekday: { symbol in
                    PreviewWeekdayLabel(symbol: symbol)
                } month: { context in
                    PreviewMonthPickerCell(context: context)
                }
                .onDateSelected { _, _ in
                    print("Date selected")
                }
                .onMonthChange { _ in
                    print("Month changed")
                }
                .padding()
                .border(.purple)
            }
        }
    }

    private func randomizeOneDayColor() {
        guard days.isEmpty == false else { return }
        let randomIndex = Int.random(in: 0..<days.count)
        let currentColor = days[randomIndex].color
        let availableColors = randomColors.filter { $0 != currentColor }
        guard let nextColor = availableColors.randomElement() else { return }

        // Reassign the array so state change is unambiguous to SwiftUI.
        var updatedDays = days
        updatedDays[randomIndex].color = nextColor
        days = updatedDays
    }
}

private struct PreviewCalendarDay: CalendarDayRepresentable {
    var id: Date { date }
    let date: Date
    var color: Color?
    var isToday: Bool = false
    var isSelected: Bool = false
}
