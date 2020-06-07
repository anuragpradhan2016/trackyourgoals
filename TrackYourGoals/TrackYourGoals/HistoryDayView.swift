//
//  HistoryDayView.swift
//  TrackYourGoals
//
//  Created by Anurag Pradhan on 6/6/20.
//  Copyright © 2020 Anurag Pradhan. All rights reserved.
//

import Foundation
import SwiftUI

struct HistoryDayView: View {
    var date: String
    var tasks: [Task]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Completed Tasks")){
                    ForEach(self.tasks) {task in
                        if !task.task_completed.isEmpty && task.task_completed.first(where: {Calendar.current.compare(Util.stringToDate(date: self.date), to: $0, toGranularity: .day).rawValue == 0}) != nil {
                            NavigationLink(destination: ViewTaskView(title: task.task_title, frequency: task.task_frequency, notificationsOn: task.task_notification, dueDate: task.task_dueDate ?? Date(), dayOfWeek: task.task_dayOfWeek, onSave: {})
                            ){
                                Text(task.task_title)
                            }
                        }
                    }
                    
                }
                
                Section(header: Text("Incompleted Tasks")){
                    ForEach(self.tasks) {task in
                        if task.task_completed.isEmpty || task.task_completed.first(where: {Calendar.current.compare(Util.stringToDate(date: self.date), to: $0, toGranularity: .day).rawValue == 0}) == nil {
                            NavigationLink(destination: ViewTaskView(title: task.task_title, frequency: task.task_frequency, notificationsOn: task.task_notification, dueDate: task.task_dueDate ?? Date(), dayOfWeek: task.task_dayOfWeek, onSave: {})
                            ){
                                Text(task.task_title)
                            }
                        }
                    }
                    
                }
                .navigationBarTitle(Text("Goals for \(date)"))
            }
        }
    }
}
