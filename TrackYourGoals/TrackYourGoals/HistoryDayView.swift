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
    var geometryWidth: CGFloat
    
    @State var collapsed = [0, 1] // i = 1 => the ith section of home is collapsed
    
    var body: some View {
        NavigationView {
            List {
                Section(header:
                    HStack {
                        Text("Incompleted Tasks").frame(width: self.geometryWidth / 2, alignment: .leading).offset(x: self.geometryWidth / 20).foregroundColor(Color.white).padding()
                        Button(action: {
                            self.collapsed[0] = 1 - self.collapsed[0]
                        }) {
                            if (self.collapsed[0] == 0) {
                                Image(systemName: "minus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "plus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.white)
                            }
                        }.frame(width: self.geometryWidth / 2, alignment: .trailing).offset(x: -self.geometryWidth / 10)
                    }.frame(width: self.geometryWidth).background(Color.black.opacity(0.85)).listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))){
                        if (self.collapsed[0] == 0) {
                            ForEach(self.tasks) {task in
                                if task.task_completed.isEmpty || task.task_completed.first(where: {Calendar.current.compare(Util.stringToDate(date: self.date), to: $0, toGranularity: .day).rawValue == 0}) == nil {
                                    ZStack {
                                        NavigationLink(destination: ViewTaskView(title: task.task_title, frequency: task.task_frequency, notificationsOn: task.task_notification, dueDate: task.task_dueDate ?? Date(), dayOfWeek: task.task_dayOfWeek, details: task.task_details, onSave: {})
                                        ){
                                            EmptyView()
                                            
                                        }
                                        HStack { Text(task.task_title).foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 7)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                            
                        }
                }
                Section(header:
                    HStack {
                        Text("Completed Tasks").frame(width: self.geometryWidth / 2, alignment: .leading).offset(x: self.geometryWidth / 20).foregroundColor(Color.white).padding()
                        Button(action: {
                            self.collapsed[1] = 1 - self.collapsed[1]
                        }) {
                            if (self.collapsed[1] == 0) {
                                Image(systemName: "minus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "plus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.white)
                            }
                        }.frame(width: self.geometryWidth / 2, alignment: .trailing).offset(x: -self.geometryWidth / 10)
                    }.frame(width: self.geometryWidth).background(Color.black.opacity(0.85)).listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))){
                        if (self.collapsed[1] == 0) {
                            ForEach(self.tasks) {task in
                                if !task.task_completed.isEmpty && task.task_completed.first(where: {Calendar.current.compare(Util.stringToDate(date: self.date), to: $0, toGranularity: .day).rawValue == 0}) != nil {
                                    ZStack {
                                        NavigationLink(destination: ViewTaskView(title: task.task_title, frequency: task.task_frequency, notificationsOn: task.task_notification, dueDate: task.task_dueDate ?? Date(), dayOfWeek: task.task_dayOfWeek, details: task.task_details, onSave: {})
                                        ){
                                            EmptyView()
                                            
                                        }
                                        HStack { Text(task.task_title).foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 7)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                        }
                }
                .navigationBarTitle(Text("Goals for \(self.date)").foregroundColor(Color.white).font(.subheadline), displayMode: .large)
            }
        }
    }
}
