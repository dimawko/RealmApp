//
//  StorageManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation
import RealmSwift

class StorageManager {
    static let shared = StorageManager()

    var realm: Realm? {
        do {
            let realm = try Realm()
            return realm
        } catch let error as NSError {
            print(error)
        }
        return nil
    }

    private init() {}

    // MARK: - Task List
    func save(_ taskLists: [TaskList]) {
        write {
            realm?.add(taskLists)
        }
    }

    func save(_ taskList: TaskList) {
        write {
            realm?.add(taskList)
        }
    }

    func delete(_ taskList: TaskList) {
        write {
            realm?.delete(taskList.tasks)
            realm?.delete(taskList)
        }
    }

    func edit(_ taskList: TaskList, newValue: String) {
        write {
            taskList.name = newValue
        }
    }

    func done(_ taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }

    // MARK: - Tasks
    func save(_ task: Task, to taskList: TaskList) {
        write {
            taskList.tasks.append(task)
        }
    }

    func delete(_ task: Task, from taskList: TaskList) {
        write {
            guard let index = taskList.tasks.index(of: task) else { return }
            taskList.tasks.remove(at: index)
        }
    }

    func edit(_ task: Task, newValue: String, newNote: String) {
        write {
            task.name = newValue
            task.note = newNote
        }
    }

    func isDone(_ task: Task) {
        write {
            task.isComplete.toggle()
        }
    }

    private func write(completion: () -> Void) {
        do {
            try realm?.write {
                completion()
            }
        } catch let error as NSError {
            print(error)
        }
    }
}
