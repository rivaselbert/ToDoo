//
//  ViewController.swift
//  ToDoo
//
//  Created by Elbert Rivas on 4/1/21.
//

import UIKit
import JTAppleCalendar

class MainViewController: UIViewController, ToDoItemCellDelegate {
   
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var todosTableView: UITableView!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var textEntryBottomConstraint: NSLayoutConstraint!
    
    private let mainViewModel = MainViewModel()
    private var defaultFormatter = DateFormatter()
    private var formatter = DateFormatter()
    private var selectedDate: Date?
    private var toDoDates = [String]()
    private var toDos = [ToDo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainInit()
        getDateWithToDos()
    }
    
    private func mainInit() {
        title = "ToDoo"
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.selectDates([Date()])
        selectedDate = Date()
        
        defaultFormatter.dateFormat = "yyyy MM dd"
    }
    
    private func getDateWithToDos() {
        mainViewModel.toDoDatesClosure = {[weak self] toDoDates in
            self?.toDoDates = toDoDates
            self?.calendarView.reloadData()
        }
        
        mainViewModel.getDatesWithToDos()
    }
    
    private func getToDos(selectedDate: Date) {
        mainViewModel.toDosClosure = {[weak self] toDos in
            self?.toDos = toDos
            self?.todosTableView.reloadData()
        }
        
        mainViewModel.getToDos(selectedDateString: defaultFormatter.string(from: selectedDate))
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        let content = contentTextField.text!
        if !content.isEmpty {
            guard let selectedDate = selectedDate else { return }
            let docPath = defaultFormatter.string(from: selectedDate)
            let toDo: [String: Any] = [
                "content": content,
                "status": Status.notDone.rawValue,
                "date": selectedDate
            ]
            
            mainViewModel.addToDo(docPath: docPath, toDo: toDo)
            contentTextField.text = ""
        } else {
            print("Textfield is empty")
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    func markToDoAsDone(id: String) {
        showAlert(message: "Mark to-do as done?", positiveAction: "Done") { [self] action in
            if action == AlertControllerAction.positiveButtonClicked {
                let docPath = self.defaultFormatter.string(from: selectedDate!)
                self.mainViewModel.updateToDoStatus(docPath: docPath, id: id, status: Status.done.rawValue)
            }
        }
    }
    
    func markToDoAsUnDone(id: String) {
        showAlert(message: "Mark to-do as undone?", positiveAction: "Undone") { [self] action in
            if action == AlertControllerAction.positiveButtonClicked {
                let docPath = self.defaultFormatter.string(from: selectedDate!)
                self.mainViewModel.updateToDoStatus(docPath: docPath, id: id, status: Status.notDone.rawValue)
            }
        }
    }
    
    func deleteToDo(id: String) {
        showAlert(message: "Delete this to-do?", positiveAction: "Delete") { [self] action in
            if action == AlertControllerAction.positiveButtonClicked {
                let docPath = self.defaultFormatter.string(from: selectedDate!)
                self.mainViewModel.deleteToDo(docPath: docPath, id: id)
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            textEntryBottomConstraint.constant = keyboardSize.height
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.performWithoutAnimation {
            textEntryBottomConstraint.constant = 0
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let toDoItemCell = tableView.dequeueReusableCell(withIdentifier: "todoCell") as! TodoItemCell
        toDoItemCell.delegate = self
        toDoItemCell.toDo = toDos[indexPath.item]
        return toDoItemCell
    }
}

extension MainViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale

        var dateComponent = DateComponents()
        dateComponent.year = 1
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: dateComponent, to: startDate)
        return ConfigurationParameters(startDate: startDate, endDate: endDate!)
    }
}

extension MainViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        selectedDate = date
        configureCell(view: cell, cellState: cellState)
        getToDos(selectedDate: selectedDate!)
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        formatter.dateFormat = "MMM yyyy"
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        header.monthTitle.text = formatter.string(from: range.start)
        return header
    }

    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
}

extension MainViewController {
    // Calendar configurations
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        handleCellEvents(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
    }
        
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.isHidden = false
        } else {
            cell.dateLabel.isHidden = true
        }
    }
    
    func handleCellSelected(cell: DateCell, cellState: CellState) {
        if cellState.isSelected {
            cell.selectedView.layer.cornerRadius =  20
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
    }
    
    func handleCellEvents(cell: DateCell, cellState: CellState) {
        let dateString = defaultFormatter.string(from: cellState.date)
        if toDoDates.contains(dateString) {
            cell.dateLabel.textColor = .red
        } else {
            cell.dateLabel.textColor = .black
        }
    }
}

