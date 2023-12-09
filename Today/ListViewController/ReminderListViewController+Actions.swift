//
//  ReminderListViewController+Actions.swift
//  Today
//
//  Created by Parth Joshi on 12/8/23.
//

import UIKit

extension ReminderListViewController {
    @objc func didPressDoneButton(_ sender: ReminderDoneButton) {
        guard let id = sender.id else { return }
        completeReminder(withId: id)
    }
}
