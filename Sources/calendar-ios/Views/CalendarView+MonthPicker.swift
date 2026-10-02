import SwiftUI

extension MosaicCalendarView {

    private var visibleYears: [Int] {
        guard let firstMonth = months.first, let lastMonth = months.last else { return [] }
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: firstMonth)
        let endYear = calendar.component(.year, from: lastMonth)
        guard startYear <= endYear else { return [] }
        return Array(startYear...endYear)
    }

    /// A compact 3x4 month grid used when the header enters month-picker mode.
    var monthPicker: some View {
        let spacing: CGFloat = 0
        let columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: 3)

#if os(iOS)
        return TabView(selection: Binding(
            get: { headerContext.pickerYear },
            set: { headerContext.setPickerYear($0) }
        )) {
            ForEach(visibleYears, id: \.self) { year in
                GeometryReader { proxy in
                    let cellHeight = max(0, (proxy.size.height - (spacing * 3)) / 4)

                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(1...12, id: \.self) { monthNumber in
                            monthPickerButton(monthNumber: monthNumber, year: year)
                                .frame(height: cellHeight)
                        }
                    }
                    .frame(width: proxy.size.width - spacing, height: proxy.size.height, alignment: .top)
                }
                .tag(year)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
#else
        return TabView(selection: Binding(
            get: { headerContext.pickerYear },
            set: { headerContext.setPickerYear($0) }
        )) {
            ForEach(visibleYears, id: \.self) { year in
                GeometryReader { proxy in
                    let cellHeight = max(0, (proxy.size.height - (spacing * 3)) / 4)

                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(1...12, id: \.self) { monthNumber in
                            monthPickerButton(monthNumber: monthNumber, year: year)
                                .frame(height: cellHeight)
                        }
                    }
                    .frame(width: proxy.size.width - spacing, height: proxy.size.height, alignment: .top)
                }
                .tag(year)
            }
        }
#endif
    }

    private func monthPickerButton(monthNumber: Int, year: Int) -> some View {
        let calendar = Calendar.current
        let symbols = calendar.shortMonthSymbols
        let monthLabel = symbols[max(0, min(symbols.count - 1, monthNumber - 1))]
        let monthDate = calendar.date(from: DateComponents(year: year, month: monthNumber, day: 1))?.monthAndYear
        let isEnabled = monthDate.map { months.contains($0) } ?? false
        let isSelected = monthDate.map { $0 == displayedMonth.monthAndYear } ?? false
        let context = CalendarMonthPickerCellContext(
            monthNumber: monthNumber,
            monthLabel: monthLabel,
            monthDate: monthDate,
            isSelected: isSelected,
            isEnabled: isEnabled
        )

        return Button {
            guard let monthDate else { return }
            headerContext.selectMonth(monthDate)
        } label: {
            if let monthPickerCellContent {
                monthPickerCellContent(context)
            } else {
                defaultMonthPickerCell(context: context)
            }
        }
        .buttonStyle(.plain)
        .disabled(isEnabled == false)
        .opacity(isEnabled ? 1 : 0.35)
        .accessibilityLabel(monthLabel)
    }

    private func defaultMonthPickerCell(context: CalendarMonthPickerCellContext) -> some View {
        Text(context.monthLabel)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(context.isSelected ? Color.white : Color.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(context.isSelected ? Color.accentColor : Color.secondary.opacity(0.12))
            }
    }
}
