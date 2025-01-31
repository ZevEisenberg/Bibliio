//
//  DayPickerViewController.swift
//  Bibliio
//
//  Created by Adam on 11/8/16.
//  Copyright © 2016 Adam Tecle. All rights reserved.
//

import UIKit
import RealmSwift

protocol DayPickerDelegate: NSObjectProtocol {
    
    func dayPickerViewController(_ dayPickerViewController: DayPickerViewController, selectedDays: List<BoolObject>?)
}

class DayPickerViewController: BaseInputViewController {
    
    weak var delegate: DayPickerDelegate?
    var tableView = UITableView()
    var tableViewHeightConstraint: NSLayoutConstraint!
    
    var book = Book()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
    
    // MARK: - Target Action
    
    dynamic private func saveButtonPressed(_ sender: Any) {
        delegate?.dayPickerViewController(self, selectedDays: selectedDays())
        let _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup
    
    private func setup() {
        saveButton.addTarget(self, action: #selector(saveButtonPressed(_:)), for: .touchUpInside)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.bounces = false
        tableView.allowsMultipleSelection = true
        contentView.backgroundColor = .white
        contentView.addSubview(tableView)
        
        let top = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 20)
        let leading = NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -20)
        tableViewHeightConstraint = NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        
        contentView.addConstraints([top, leading, trailing, tableViewHeightConstraint, bottom])
    }
    
    // MARK: - Helper
    
    private func selectedDays() -> List<BoolObject>? {
        guard let selectedRows = tableView.indexPathsForSelectedRows
            else { return nil }
        
        var days = [false, false, false, false, false, false, false]
        for indexPath in selectedRows {
            days[indexPath.row] = true
        }
        
        let list = List<BoolObject>()
        list.append(objectsIn: days.map({ BoolObject(bool:$0) }))
        return list
    }
    
}

extension DayPickerViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = Date.nameOfDay(forIndex: indexPath.row)
        let cell = UITableViewCell()
        cell.textLabel?.text = day
        
        return cell
    }
    
}

extension DayPickerViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if book.readingDays[indexPath.row].value {
            cell.setSelected(true, animated: false)
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
}
