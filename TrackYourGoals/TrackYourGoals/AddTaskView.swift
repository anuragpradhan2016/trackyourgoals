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
                }
                
                Section {
                    Button(action: {
                        self.taskSubmitted = true
                        self.modalDisplayed = false
                        self.onSubmit()
                    }) {
                        Text("Submit")
                    }
                }
            }
            .navigationBarTitle("Add a Task")
            
        }
        
    }
}
