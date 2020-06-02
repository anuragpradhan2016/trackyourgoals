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
    var onSubmit: () -> ()
    
    var frequencies = ["Never", "Daily", "Weekly"]
    
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
