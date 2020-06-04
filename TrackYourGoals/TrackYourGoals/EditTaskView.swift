//
//  EditTaskView.swift
//  TrackYourGoals
//
//  Created by Anurag Pradhan on 6/3/20.
//  Copyright © 2020 Anurag Pradhan. All rights reserved.
//

import Foundation
import SwiftUI

struct EditTaskView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var title: String
    @State var frequency: Int
    @State var notificationsOn: Bool
    @State var dueDate: Date
    @State var dayOfWeek: Int
    @State var task: Task
    @State var originalStateDueToday: Bool
    @Binding var editTaskAction: Int
    
    @State var onSave: () -> ()
    
    var frequencies = ["Never", "Daily", "Weekly"]
    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        NavigationView {
            Form {
                Section{
                    TextField("Task Title", text: self.$title)
                    Picker(selection: self.$frequency, label: Text("Repeat")) {
                        ForEach(0 ..< self.frequencies.count, id: \.self) {
                            Text(self.frequencies[$0]).tag($0)
                        }
                    }
                    
                    if (frequency == 2){
                        Picker(selection: $dayOfWeek, label: Text("Select Day")) {
                            ForEach(0 ..< self.days.count, id: \.self) {
                                Text(self.days[$0]).tag($0)
                            }
                        }
                    }
                    
                    if (frequency == 0) {
                        DatePicker(selection: $dueDate, in: Date()..., displayedComponents: .date) {
                            Text("Select due date")
                        }
                    }
                }
                
                
                Section {
                    Toggle(isOn: self.$notificationsOn) {
                        Text("Receive Notificatons")
                    }
                }
                
                Section {
                    Button(action: {
                        self.managedObjectContext.performAndWait {
                            self.task.task_title = self.title
                            self.task.task_frequency = self.frequency
                            self.task.task_notification = self.notificationsOn
                            
                            if self.frequency == 0 {
                                self.task.task_dueDate = self.dueDate
                            } else {
                                self.task.task_dueDate = nil
                            }
                            
                            if self.frequency == 2 {
                                self.task.task_dayOfWeek = self.dayOfWeek
                            } else {
                                self.task.task_dayOfWeek = 0
                            }
                            
                            if self.originalStateDueToday {
                                if Util.isTaskDueToday(t: self.task) {
                                    self.editTaskAction = 0
                                } else {
                                    self.editTaskAction = 1
                                }
                            } else {
                                if Util.isTaskDueToday(t: self.task) {
                                    self.editTaskAction = 2
                                } else {
                                    self.editTaskAction = 0
                                }
                            }
                        }
                        try? self.managedObjectContext.save()
                        self.onSave()
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                    }
                }
            }
        }
        .navigationBarTitle("Edit Task")
    }
    
}