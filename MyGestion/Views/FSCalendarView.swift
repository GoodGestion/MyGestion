// Views/FSCalendarView.swift
import SwiftUI
import FSCalendar

struct FSCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date
    let missions: [Mission]

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.dataSource    = context.coordinator
        calendar.delegate      = context.coordinator
        calendar.scope         = .month

        // ← Français, lundi 1er jour
        calendar.locale        = Locale(identifier: "fr_FR")
        calendar.firstWeekday  = 2

        // ← Thème
        calendar.appearance.headerTitleColor   = .label
        calendar.appearance.weekdayTextColor   = .secondaryLabel
        calendar.appearance.todayColor         = .systemBlue
        calendar.appearance.selectionColor     = .systemBlue

        // ← Sélection initiale
        calendar.select(selectedDate)
        calendar.setCurrentPage(selectedDate, animated: false)

        // On garde la référence pour updateUIView
        context.coordinator.calendar = calendar
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // Recharge les événements
        uiView.reloadData()
        // Reste calé sur la bonne date / mois
        uiView.setCurrentPage(selectedDate, animated: false)
        uiView.select(selectedDate)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, FSCalendarDataSource, FSCalendarDelegate {
        let parent: FSCalendarView
        weak var calendar: FSCalendar?
        let cal = Calendar.current

        init(_ parent: FSCalendarView) {
            self.parent = parent
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }

        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            let count = parent.missions.filter {
                cal.isDate($0.startDate, inSameDayAs: date)
            }.count
            return min(count, 3)
        }
    }
}
