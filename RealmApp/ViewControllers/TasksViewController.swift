//
//  TasksViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

private enum Section {
    static let current = 0
    static let completed = 1
}

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
        section == Section.current ? currentTasks.count : completedTasks.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == Section.current ? "CURRENT TASKS" : "COMPLETED TASKS"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
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
        let task = indexPath.section == Section.current
        ? currentTasks[indexPath.row]
        : completedTasks[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, isDone in
            StorageManager.shared.delete(task, from: self.taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            isDone(true)
        }

        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
                isDone(true)
            }
        }

        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
            StorageManager.shared.done(task)
            let rowIndex = IndexPath(
                row: self.completedTasks.index(of: task) ?? Section.current,
                section: Section.completed
            )
            tableView.moveRow(at: indexPath, to: rowIndex)
            isDone(true)
        }

        let undoneAction = UIContextualAction(style: .normal, title: "Undone") { _, _, isDone in
            StorageManager.shared.undone(task)
            let rowIndex = IndexPath(
                row: self.currentTasks.index(of: task) ?? Section.current,
                section: Section.current
            )
            tableView.moveRow(at: indexPath, to: rowIndex)
            isDone(true)
        }

        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        undoneAction.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)

        if indexPath.section == Section.current {
            return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
        } else {
            return UISwipeActionsConfiguration(actions: [undoneAction, editAction, deleteAction])
        }
    }
}

extension TasksViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit Task" : "New Task"

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
            row: currentTasks.index(of: task) ?? Section.current,
            section: Section.current
        )
        tableView.insertRows(at: [rowIndex], with: .automatic)
    }
}
