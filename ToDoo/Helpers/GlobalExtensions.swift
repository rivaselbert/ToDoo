//
//  GlobalExtensions.swift
//  ToDoo
//
//  Created by Elbert Rivas on 4/1/21.
//

import UIKit

enum AlertControllerAction {
    case positiveButtonClicked
    case negativeButtonClicked
}

extension UIViewController {
    func showOkAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(message: String, positiveAction: String, completion: ((AlertControllerAction) -> ())?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: positiveAction, style: UIAlertAction.Style.default, handler: { _ in
            completion!(.positiveButtonClicked)
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}
