//
//  TasksViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {

    var taskList: TaskList!

    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]

        currentTasks = taskList.tasks.filter("isComplete = false")
        completedTasks = taskList.tasks.filter("isComplete = true")
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == SectionIndex.current ? currentTasks.count : completedTasks.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == SectionIndex.current ? "CURRENT TASKS" : "COMPLETED TASKS"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == SectionIndex.current
        ? currentTasks[indexPath.row]
        : completedTasks[indexPath.row]
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @objc private func addButtonPressed() {
        showAlert()
    }
    // MARK: - Table view swipe actions
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == SectionIndex.current
        ? currentTasks[indexPath.row]
        : completedTasks[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: ActionName.delete) { _, _, _ in
            StorageManager.shared.delete(task, from: self.taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }

        let editAction = UIContextualAction(style: .normal, title: ActionName.edit) { _, _, isDone in
            self.showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)

            }
            isDone(true)
        }

        var doneActionTitle: String
        var rowIndex: IndexPath

        if indexPath.section == SectionIndex.current {
            doneActionTitle = ActionName.done
            rowIndex = IndexPath(
                row: self.completedTasks.index(of: task) ?? SectionIndex.current,
                section: SectionIndex.completed
            )
        } else {
            doneActionTitle = ActionName.undone
            rowIndex = IndexPath(
                row: self.currentTasks.index(of: task) ?? SectionIndex.current,
                section: SectionIndex.current
            )
        }

        let doneAction = UIContextualAction(style: .normal, title: doneActionTitle) { _, _, isDone in
            StorageManager.shared.isDone(task)
            tableView.moveRow(at: indexPath, to: rowIndex)
            isDone(true)
        }

        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)

        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

// MARK: - Alert controller
extension TasksViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? Alert.Title.editTask : Alert.Title.newTask

        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "What do you want to do?")

        alert.action(with: task) { newValue, note in
            if let task = task, let completion = completion {
                StorageManager.shared.edit(task, newValue: newValue, newNote: note)
                completion()
            } else {
                self.saveTask(withName: newValue, andNote: note)
            }
        }

        present(alert, animated: true)
    }

    private func saveTask(withName name: String, andNote note: String) {
        let task = Task(value: [name, note])
        StorageManager.shared.save(task, to: taskList)
        let rowIndex = IndexPath(
            row: currentTasks.index(of: task) ?? SectionIndex.current,
            section: SectionIndex.current
        )
        tableView.insertRows(at: [rowIndex], with: .automatic)
    }
}
