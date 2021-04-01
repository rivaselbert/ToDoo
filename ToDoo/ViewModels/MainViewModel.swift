//
//  MainViewModel.swift
//  ToDoo
//
//  Created by Elbert Rivas on 4/1/21.
//

import Foundation
import FirebaseFirestore


class MainViewModel {
    
    private let firestore = Firestore.firestore()
    private var toDosRef: CollectionReference!
    
    var toDos = [ToDo]() {
        didSet {
            for (index, toDo) in toDos.enumerated() {
                if toDo.status == Status.done.rawValue {
                    toDos.rearrange(from: index, to: toDos.count - 1)
                }
            }
            toDosClosure!(toDos)
        }
    }
    
    var toDoDates = [String]() {
        didSet {
            toDoDatesClosure!(toDoDates)
        }
    }
    
    var toDosClosure: (([ToDo]) -> ())?
    var toDoDatesClosure: (([String]) -> ())?
    
    init() {
        toDosRef = firestore.collection("toDos")
    }
    
    func addToDo(docPath: String, toDo: [String: Any]) {
        let toDosDocRef = toDosRef.document(docPath)
        toDosDocRef.setData(["date": toDo["date"] as Any]) { error in
            if error == nil {
                toDosDocRef.collection("toDos").addDocument(data: toDo) { error in
                    if error == nil {
                        print("Todo written")
                    }
                }
            }
        }
    }
    
    func getDatesWithToDos() {
        toDosRef.addSnapshotListener { (querySnapshot, error) in
            if error == nil {
                var toDoDates = [String]()
                for document in querySnapshot!.documents {
                    let date = document.get("date") as! Timestamp
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy MM dd"
                    let dateString = formatter.string(from: date.dateValue())
                    toDoDates.append(dateString)
                }
                
                self.toDoDates = toDoDates
            }
        }
    }
    
    func getToDos(selectedDateString: String) {
        toDosRef.document(selectedDateString).collection("toDos").addSnapshotListener { (querySnapshot, error) in
            if error == nil {
                var toDos = [ToDo]()
                for document in querySnapshot!.documents {
                    let todo = ToDo(document: document)
                    toDos.append(todo)
                }
                
                self.toDos = toDos
            }
        }
    }
    
    func updateToDoStatus(docPath: String, id: String, status: String) {
        toDosRef.document(docPath).collection("toDos").document(id).updateData(["status" : status]) { error in
            if error == nil {
                print("ToDo updated")
            }
        }
    }
    
    func deleteToDo(docPath: String, id: String) {
        toDosRef.document(docPath).collection("toDos").document(id).delete() { error in
            if error == nil {
                // Check if there are no more to-dos for the selected date
                self.toDosRef.document(docPath).collection("toDos").getDocuments { (querySnapshot, error) in
                    if error == nil {
                        if querySnapshot?.documents.count == 0 {
                            self.toDosRef.document(docPath).delete()
                        }
                    }
                }
            }
        }
    }
}
