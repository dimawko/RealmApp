//
//  AlertTitle.swift
//  RealmApp
//
//  Created by Dinmukhammed Sagyntkan on 23.04.2022.
//  Copyright © 2022 Alexey Efimov. All rights reserved.
//

enum Alert {
    enum Title {
        static let editList = "Edit List"
        static let newList = "New List"
        static let editTask = "Edit Task"
        static let newTask = "New Task"
    }

    enum ButtonTitle {
        static let save = "Save"
        static let update = "Update"
    }

    enum Action {
        static let cancel = "Cancel"
    }

    enum PlaceHolderText {
        static let enterList = "Enter new list name"
        static let enterTask = "Enter new task name"
        static let enterNote = "Enter note for the task"
    }
}
