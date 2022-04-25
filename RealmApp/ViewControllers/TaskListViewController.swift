//
//  TaskListsViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

private enum SegmentIndex {
    static let date = 0
}

private enum KeyPath {
    static let date = "date"
    static let name = "name"
}

class TaskListViewController: UITableViewController {

    var taskLists: Results<TaskList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        taskLists = StorageManager.shared.realm?.objects(TaskList.self)
        createTempData()
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )

        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        let taskList = taskLists[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = taskList.name

        let uncompletedTasks = TaskList.countUncompletedTasks(for: taskList)

        if uncompletedTasks > 0 || taskList.tasks.isEmpty == true {
            content.secondaryText = "\(uncompletedTasks)"
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
        }

        cell.contentConfiguration = content

        return cell
    }

    // MARK: - Table view swipe actions
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = taskLists[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: ActionName.delete) { _, _, isDone in
            StorageManager.shared.delete(taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            isDone(true)
        }

        let editAction = UIContextualAction(style: .normal, title: ActionName.edit) { _, _, isDone in
            self.showAlert(with: taskList) {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }

            isDone(true)
        }

        let doneAction = UIContextualAction(style: .normal, title: ActionName.done) { _, _, isDone in
            StorageManager.shared.done(taskList)
            tableView.reloadRows(at: [indexPath], with: .automatic)

            isDone(true)
        }

        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)

        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let tasksVC = segue.destination as? TasksViewController else { return }
        let taskList = taskLists[indexPath.row]
        tasksVC.taskList = taskList
    }

    @IBAction func sortingList(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case SegmentIndex.date:
            taskLists =  taskLists.sorted(byKeyPath: KeyPath.date, ascending: true)
        default:
            taskLists = taskLists.sorted(byKeyPath: KeyPath.name, ascending: true)
        }
        tableView.reloadData()
    }

    @objc private func addButtonPressed() {
        showAlert()
    }
}
// MARK: - Private methods
private extension TaskListViewController {
    func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let title = taskList != nil ? Alert.Title.editList : Alert.Title.newList
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Please set title for new task list")

        alert.action(with: taskList) { newValue in
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.edit(taskList, newValue: newValue)
                completion()
            } else {
                self.save(taskList: newValue)
            }
        }

        present(alert, animated: true)
    }

    func save(taskList: String) {
        let taskList = TaskList(value: [taskList])
        StorageManager.shared.save(taskList)
        let rowIndex = IndexPath(row: taskLists.index(of: taskList) ?? SectionIndex.current, section: SectionIndex.current)
        tableView.insertRows(at: [rowIndex], with: .automatic)
    }

    func createTempData() {
        DataManager.shared.createTempData {
            self.tableView.reloadData()
        }
    }
}
