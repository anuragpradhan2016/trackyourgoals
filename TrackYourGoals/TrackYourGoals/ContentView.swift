//
//  ContentView.swift
//  TrackYourGoals
//
//  Created by Anurag Pradhan on 5/31/20.
//  Copyright © 2020 Anurag Pradhan. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Task.getAllTasks()) var tasks:FetchedResults<Task>
    @ObservedObject var viewRouter = ViewRouter()
    
    @State var modalDisplayed = false
    @State var task_title = ""
    @State var task_frequency = 0
    @State var task_notification = false
    @State var addTaskCompleted = false
    
    @State var tasksDueToday: [Task] = []
    @State var upcomingTasks: [Task] = []
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                if self.viewRouter.currentView == "todaysGoals" {
                    
                    
                    NavigationView {
                        List {
                            Section(header: Text("Incomplete Tasks")){
                                ForEach(self.tasksDueToday){
                                    task in
                                    Text(task.task_title)
                                }
                            }
                            
                            Section(header: Text("Completed Tasks")){
                                ForEach(self.tasksDueToday){
                                    task in
                                    Text(task.task_title)
                                }
                            }
                        }
                        .navigationBarTitle("Today's Goals")
                    }
                    
                    
                    
                } else if self.viewRouter.currentView == "upcomingGoals" {
                    
                } else if self.viewRouter.currentView == "history" {
                    
                } else if self.viewRouter.currentView == "settings" {
                    Text("Settings")
                }
                
                Spacer()
                ZStack {
                    HStack {
                        CustomTabViewItem(tabName: "Today", width: geometry.size.width/6, foregroundColor: self.viewRouter.currentView == "todaysGoals" ? .black : .gray, onTapGesture: {self.viewRouter.currentView = "todaysGoals"})
                        
                        CustomTabViewItem(tabName: "Upcoming", width: geometry.size.width/5, foregroundColor: self.viewRouter.currentView == "upcomingGoals" ? .black : .gray, onTapGesture: {self.viewRouter.currentView = "upcomingGoals"})
                        
                        
                        ZStack {
                            Button(action: {
                                self.modalDisplayed = true
                                self.task_title = ""
                                self.task_frequency = 0
                                self.task_notification = false
                                self.addTaskCompleted = false
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 75, height: 75)
                                    .foregroundColor(.blue)
                            }.sheet(isPresented: self.$modalDisplayed) {
                                AddTaskView(title: self.$task_title, frequency: self.$task_frequency,
                                            notificationsOn: self.$task_notification,
                                            taskSubmitted: self.$addTaskCompleted, modalDisplayed: self.$modalDisplayed, onSubmit: {
                                                if (self.addTaskCompleted){
                                                    
                                                    let task = Task(context: self.managedObjectContext)
                                                    
                                                    task.task_title = self.task_title
                                                    task.task_frequency = self.task_frequency
                                                    task.task_notification = self.task_notification
                                                    task.task_completed = false
                                                    task.task_createdAt = Date()
                                                    
                                                    do {
                                                        try self.managedObjectContext.save()
                                                        
                                                    } catch {
                                                        print(error)
                                                    }
                                                    
                                                    if task.task_frequency == 0 {
                                                      
                                                    } else if task.task_frequency == 1 {
                                                          self.tasksDueToday.append(task)
                                                    } else {
                                                        
                                                    }
                                                }
                                })
                            }
                            
                        }
                        .offset(y: -geometry.size.height/10/2)
                        
                        
                        CustomTabViewItem(tabName: "History", width: geometry.size.width/6, foregroundColor: self.viewRouter.currentView == "history" ? .black : .gray, onTapGesture: {self.viewRouter.currentView = "history"})
                        
                        CustomTabViewItem(tabName: "Settings", width: geometry.size.width/6, foregroundColor: self.viewRouter.currentView == "settings" ? .black : .gray, onTapGesture: {self.viewRouter.currentView = "settings"})
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height/10)
                    .background(Color.white.shadow(radius: 2))
                }
            }.edgesIgnoringSafeArea(.bottom)
        }.onAppear() {
            for i in 0..<self.tasks.count {
                let task = self.tasks[i]
                if task.task_frequency == 1 {
                    self.tasksDueToday.append(task)
                } else if task.task_frequency == 2 {
                    
                } else {
                
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
