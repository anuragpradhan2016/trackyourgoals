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
    @State var task: Task
    @State var onSave: () -> ()
    
    var frequencies = ["Never", "Daily", "Weekly"]
    
    var body: some View {
        Form {
            Section{
                TextField("Task Title", text: self.$title)
                Picker(selection: self.$frequency, label: Text("Repeat")) {
                    ForEach(0 ..< self.frequencies.count, id: \.self) {
                        Text(self.frequencies[$0]).tag($0)
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
                    }
                    try? self.managedObjectContext.save()
                    self.onSave()
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                }
            }
        }
        .navigationBarTitle("Edit Task")
    }
    
}
