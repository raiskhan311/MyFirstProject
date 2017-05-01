//
//  CalendarViewController.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/2/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit
import CVCalendar

class CalendarViewController: UIViewController {
    
    // MARK: IBOutlets

    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var calendarMenuView: CVCalendarMenuView!
    @IBOutlet weak var calendarMonthView: CVCalendarView!
    
    // MARK: Properties
    
    let viewModel = CalendarViewModel()
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarMonthView.calendarDelegate = self
        calendarMenuView.menuViewDelegate = self
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage.imageWithColor(color: Colors.tableViewCellDividerColor)
        
        viewModel.configureGamesForInitialMonth()
        viewModel.isFirstDayOfMonth = true
        registerNotifications()
        postNotification(date: Date())
        let month = Calendar.current.component(.month, from: Date())
        let year = Calendar.current.component(.year, from: Date())
        titleBar.title = dateFormatter.monthSymbols[month - 1] + " " + String(year)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.tintColor = .black
        let titleDict = [NSForegroundColorAttributeName: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = titleDict
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage.imageWithColor(color: Colors.tableViewCellDividerColor)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarMenuView.commitMenuViewUpdate()
        calendarMonthView.commitCalendarViewUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
}

// MARK: CVCalendar delegates for view and menu

extension CalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate {
    
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func firstWeekday() -> Weekday {
        return .sunday
    }
    
    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        dayView.moveDotMarkerBack(true, coloring: false)
        if let date = dayView.date.convertedDate(calendar: Calendar.current) {
            viewModel.selectedDate = date
            postNotification(date: date)
        }
    }
    
    func postNotification(date: Date) {
        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:"CalendarDateChanged"), object: nil, userInfo: ["games" : viewModel.gamesForSelectedDate(date) as Any])
    }
    
    func didShowPreviousMonthView(_ date: Date) {
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        titleBar.title = dateFormatter.monthSymbols[month - 1] + " " +  String(year)
        viewModel.monthChanged(date)
    }
    
    func didShowNextMonthView(_ date: Date) {
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        titleBar.title = dateFormatter.monthSymbols[month - 1] + " " + String(year)
        viewModel.monthChanged(date)
    }
    
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        return viewModel.shouldShowDotMarkerOn(dayView: dayView)
    }
    
    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        return [UIColor.blue]
    }

}

// MARK: - Notifications

extension CalendarViewController {
    
    fileprivate func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(displayLeagueChanged(notification:)), name: ServiceNotificationType.displayLeagueChanged, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSuccess(notification:)), name: ServiceNotificationType.allDataRefreshed, object: .none)
    }
    
    func displayLeagueChanged(notification: Notification) {
        viewModel.initialize()
        self.calendarMonthView.contentController.refreshPresentedMonth()
        postNotification(date: viewModel.selectedDate)
    }
    
    func refreshSuccess(notification: Notification) {
        viewModel.initialize()
        calendarMonthView.contentController.refreshPresentedMonth()
        postNotification(date: viewModel.selectedDate)
    }
}



