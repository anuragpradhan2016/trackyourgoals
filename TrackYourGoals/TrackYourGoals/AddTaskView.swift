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
    @Binding var reminder: Date
    @State var id: Int
    
    var onSubmit: () -> ()
    
    var frequencies = ["Never", "Daily", "Weekly"]
    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        NavigationView {
            Form {
                Section{
                    CustomTextField(placeholder: Text("Task Title").foregroundColor(Color.white.opacity(0.4)), text: $title).foregroundColor(Color.white)
                    
                    Picker(selection: $frequency, label: Text("Repeat").foregroundColor(.white)) {
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
                    Button(action: {
                        self.taskSubmitted = true
                        self.modalDisplayed = false
                        self.onSubmit()
                        
                        if self.notificationsOn {
                            Util.setReminder(id: self.id, frequency: self.frequency, reminder: self.reminder, title: self.title, dayOfWeek: self.dayOfWeek, dueDate: self.dueDate)
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
