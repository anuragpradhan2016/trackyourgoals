//
//  ViewTaskView.swift
//  TrackYourGoals
//
//  Created by Ibrahim Jirdeh on 6/4/20.
//  Copyright © 2020 Anurag Pradhan. All rights reserved.
//

import Foundation
import SwiftUI

struct ViewTaskView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var title: String
    @State var frequency: Int
    @State var notificationsOn: Bool
    @State var dueDate: Date
    @State var dayOfWeek: Int
    @State var details: String
    
    @State var onSave: () -> ()
    
    var frequencies = ["Never", "Daily", "Weekly"]
    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        NavigationView {
            Form {
                Section{
                    TextField("Task Title", text: self.$title).disabled(true)
                    Picker(selection: self.$frequency, label: Text("Repeat")) {
                        ForEach(0 ..< self.frequencies.count, id: \.self) {
                            Text(self.frequencies[$0]).tag($0)
                        }
                    }.disabled(true)
                    
                    if (frequency == 2){
                        Picker(selection: $dayOfWeek, label: Text("Select Day")) {
                            ForEach(0 ..< self.days.count, id: \.self) {
                                Text(self.days[$0]).tag($0)
                            }
                        }.disabled(true)
                    }
                    
                    if (frequency == 0) {
                        DatePicker(selection: $dueDate, in: Date()..., displayedComponents: .date) {
                            Text("Select due date")
                        }.disabled(true)
                    }
                }
                
                
                Section {
                    Toggle(isOn: self.$notificationsOn) {
                        Text("Receive Notificatons")
                    }.disabled(true)
                }
                
                Section {
                    TextField("Task Details", text: self.$details)
                }.disabled(true)
                
            }
        }
        .navigationBarTitle("View Task")
    }
    
}
