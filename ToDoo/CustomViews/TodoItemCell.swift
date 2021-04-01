//
//  TodoItemCell.swift
//  ToDoo
//
//  Created by Elbert Rivas on 4/1/21.
//

import UIKit

class TodoItemCell: UITableViewCell {
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    
    var delegate: ToDoItemCellDelegate?
    var toDo = ToDo() {
        didSet {
            contentTextView.text = toDo.content
            if toDo.status == Status.done.rawValue {
                doneButton.setTitle("Un-done", for: .normal)
                backgroundColor = .systemGray6
            } else {
                doneButton.setTitle("Done", for: .normal)
                backgroundColor = .white
            }
        }
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        if toDo.status == Status.notDone.rawValue {
            delegate?.markToDoAsDone(id: toDo.id)
        } else {
            delegate?.markToDoAsUnDone(id: toDo.id)
        }
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        delegate?.deleteToDo(id: toDo.id)
    }
}

protocol ToDoItemCellDelegate {
    func markToDoAsDone(id: String)
    func markToDoAsUnDone(id: String)
    func deleteToDo(id: String)
}
