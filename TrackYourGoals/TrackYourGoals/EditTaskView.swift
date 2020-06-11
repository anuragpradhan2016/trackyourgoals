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
    @State var reminder: Date
    @State var originalStateDueToday: Bool
    @Binding var editTaskAction: Int
    @State var details: String
    @State var onSave: () -> ()
    
    var frequencies = ["Never", "Daily", "Weekly"]
    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        NavigationView {
            Form {
                Section{
                    CustomTextField(placeholder: Text("Task Title").foregroundColor(Color.white.opacity(0.4)), text: $title).foregroundColor(Color.white)
                    
                    Picker(selection: self.$frequency, label: Text("Repeat").foregroundColor(.white)) {
                        ForEach(0 ..< self.frequencies.count, id: \.self) {
                            Text(self.frequencies[$0]).tag($0)
                        }.colorInvert().colorMultiply(.white)
                    }
                    
                    if (frequency == 2){
                        Picker(selection: $dayOfWeek, label: Text("Select Day").foregroundColor(.white)) {
                            ForEach(0 ..< self.days.count, id: \.self) {
                                Text(self.days[$0]).tag($0)
                            }.colorInvert().colorMultiply(.white)
                        }
                    }
                    
                    if (frequency == 0) {
                        DatePicker(selection: $dueDate, in: Date()..., displayedComponents: .date) {
                            Text("Select due date")
                        }.colorInvert().colorMultiply(.white)
                    }
                }
                
                
                Section {
                    Toggle(isOn: $notificationsOn) {
                        Text("Receive Notificatons").foregroundColor(.white)
                    }
                    
                    if self.notificationsOn {
                        if self.frequency == 0 {
                            DatePicker("Select Reminder Date and Time: ", selection: self.$reminder, in: Util.localDate(date: Date())...Util.getPreviousMinute(date: Util.getNextDay(date: Util.stringToDate(date: Util.dateToString(date: self.dueDate)))), displayedComponents: [.hourAndMinute, .date]).colorInvert().colorMultiply(.white)
                        } else {
                            DatePicker("Select Reminder Time: ", selection: self.$reminder, displayedComponents: [.hourAndMinute]).colorInvert().colorMultiply(.white)
                        }
                    }
                }
                
                Section {
                    TextField("Task Details", text: self.$details)
                }
                
                Section {
                    Button(action: {
                        self.managedObjectContext.performAndWait {
                            self.task.task_title = self.title
                            self.task.task_frequency = self.frequency
                            self.task.task_notification = self.notificationsOn
                            self.task.task_details = self.details
                            
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
                            if (self.notificationsOn) {
                                self.task.task_reminder = self.reminder
                            }
                        }
                        
                        let center = UNUserNotificationCenter.current()
                        center.removePendingNotificationRequests(withIdentifiers: ["\(self.task.task_id)"])
                        center.removeDeliveredNotifications(withIdentifiers: ["\(self.task.task_id)"])
                        
                        if (self.notificationsOn) {
                            Util.setReminder(id: self.task.task_id, frequency: self.frequency, reminder: self.reminder, title: self.title, dayOfWeek: self.dayOfWeek, dueDate: self.dueDate)
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
