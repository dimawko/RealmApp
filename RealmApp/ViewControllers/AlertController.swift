//
//  AlertController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 12.03.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import UIKit

extension UIAlertController {

    static func createAlert(withTitle title: String, andMessage message: String) -> UIAlertController {
        UIAlertController(title: title, message: message, preferredStyle: .alert)
    }

    func action(with taskList: TaskList?, completion: @escaping (String) -> Void) {

        let doneButton = taskList == nil ? Alert.ButtonTitle.save : Alert.ButtonTitle.update

        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            completion(newValue)
        }

        let cancelAction = UIAlertAction(title: Alert.Action.cancel, style: .destructive)

        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = Alert.PlaceHolderText.enterList
            textField.text = taskList?.name
        }
    }

    func action(with task: Task?, completion: @escaping (String, String) -> Void) {

        let title = task == nil ? Alert.ButtonTitle.save : Alert.ButtonTitle.update

        let saveAction = UIAlertAction(title: title, style: .default) { _ in
            guard let newTask = self.textFields?.first?.text else { return }
            guard !newTask.isEmpty else { return }

            if let note = self.textFields?.last?.text, !note.isEmpty {
                completion(newTask, note)
            } else {
                completion(newTask, "")
            }
        }

        let cancelAction = UIAlertAction(title: Alert.Action.cancel, style: .destructive)

        addAction(saveAction)
        addAction(cancelAction)

        addTextField { textField in
            textField.placeholder = Alert.PlaceHolderText.enterTask
            textField.text = task?.name
        }

        addTextField { textField in
            textField.placeholder = Alert.PlaceHolderText.enterNote
            textField.text = task?.note
        }
    }
}
