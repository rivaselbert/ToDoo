//
//  ToDo.swift
//  ToDoo
//
//  Created by Elbert Rivas on 4/1/21.
//
import Foundation
import FirebaseFirestore

enum Status: String {
    case done = "DONE"
    case notDone = "NOT DONE"
}

struct ToDo {
    var id: String!
    var content: String?
    var status: String?
    var date: Date?
    
    init() {}
    
    init(document: DocumentSnapshot) {
        id = document.documentID as String
        content = document.get("content") as? String
        status = document.get("status") as? String
        date = (document.get("date") as? Timestamp)?.dateValue()
    }
}
