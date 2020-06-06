//
//  AddTaskView.swift
//  TrackYourGoals
//
//  Created by Anurag Pradhan on 6/2/20.
//  Copyright © 2020 Anurag Pradhan. All rights reserved.
//

import Foundation
import SwiftUI

struct AddTaskView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var title: String
    @Binding var frequency: Int
    @Binding var notificationsOn: Bool
    @Binding var taskSubmitted: Bool
    @Binding var modalDisplayed: Bool
    @Binding var dueDate: Date
    @Binding var dayOfWeek: Int
    
    @State var reminder: Date = Date()
    
    var onSubmit: () -> ()
    
    var frequencies = ["Never", "Daily", "Weekly"]
    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        NavigationView {
            Form {
                Section{
                    TextField("Task Title", text: $title)
                    Picker(selection: $frequency, label: Text("Repeat")) {
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
                    Toggle(isOn: $notificationsOn) {
                        Text("Receive Notificatons")
                    }
                    
                    if self.notificationsOn {
                        if self.frequency == 0 {
                            Text("\(Util.localDate(date: Date()))")
                            Text("\(Util.getNextDay(date: self.dueDate))")
                            
                            DatePicker("Select Reminder Date and Time: ", selection: self.$reminder, in: Util.localDate(date: Date())...Util.getPreviousMinute(date: Util.getNextDay(date: self.dueDate)), displayedComponents: [.hourAndMinute, .date])
                        } else {
                            DatePicker("Select Reminder Time: ", selection: self.$reminder, in: ...self.dueDate, displayedComponents: [.hourAndMinute])
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        self.taskSubmitted = true
                        self.modalDisplayed = false
                        self.onSubmit()
                        
                        if self.notificationsOn {
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(status, _) in
                                
                                if status {
                                    let content = UNMutableNotificationContent()
                                    let trigger: UNNotificationTrigger
                                    content.sound = .default
                                    
                                    if self.frequency == 0 {
                                        content.title = "\(self.title) is due on \(Util.dateToString(date: self.dueDate))!"
                                        trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.reminder), repeats: false)
                                    } else {
                                        content.title = "Your goal \(self.title) is due today!"
                                        
                                        if self.frequency == 1 {
                                            trigger = UNCalendarNotificationTrigger(dateMatching:  Calendar.current.dateComponents([.hour, .minute], from: self.reminder), repeats: true)
                                        } else {
                                            while Util.getWeekDay(date: self.reminder) != self.days[self.dayOfWeek] {
                                                self.reminder = Util.getNextDay(date: self.reminder)
                                            }
                                            
                                            trigger = UNCalendarNotificationTrigger(dateMatching:  Calendar.current.dateComponents(self.frequency == 1 ? [.hour, .minute] : [.weekday, .hour, .minute], from: self.reminder), repeats: true)
                                        }
                                        
                                    }
                                    
                                    let request = UNNotificationRequest(identifier: "reminderForGoals", content: content, trigger: trigger)
                                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                                        if error != nil {
                                            print("Reminder notification error")
                                        }
                                    })
                                    
                                }
                            }
                        }
                    }) {
                        Text("Submit")
                    }
                }
            }
            .navigationBarTitle("Add a Task")
            
        }
        
    }
}
