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
    @State var todaysTaskCompleted = false
    @State var addTaskCompleted = false
    @State var dueDate = Date()
    @State var dayOfWeek = 0
    
    @State var taskSwipe = CGSize.zero
    @State var editTaskUpdateAction: Int = 0 // 0-> nothing, 1 -> delete from daily, 2 -> add to daily
    @State var tasksDueToday: [Task] = []
    @State var upcomingTasks: [Task] = []
    
    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                if self.viewRouter.currentView == "todaysGoals" {
                    NavigationView {
                        List {
                            Section(header: Text("Today's Tasks")){
                                ForEach(self.tasksDueToday){
                                    task in
                                    if (task.task_completed.isEmpty || Calendar.current.compare(Date(), to: task.task_completed.last!, toGranularity: .day).rawValue != 0) && (task.task_deletedAt == nil || Calendar.current.compare(Date(), to: task.task_deletedAt!, toGranularity: .day).rawValue < 0) {
                                        NavigationLink(destination: EditTaskView(title: task.task_title, frequency: task.task_frequency, notificationsOn: task.task_notification, dueDate: task.task_dueDate ?? Date(), dayOfWeek: task.task_dayOfWeek, task: task,
                                                                                 originalStateDueToday: Util.isTaskDueToday(t: task), editTaskAction: self.$editTaskUpdateAction, onSave: {
                                                                                    if (self.editTaskUpdateAction == 1) {
                                                                                        self.tasksDueToday.remove(at: self.tasksDueToday.firstIndex(of: task)!)
                                                                                        self.upcomingTasks.append(task)
                                                                                    } else if (self.editTaskUpdateAction == 2) {
                                                                                        self.tasksDueToday.append(task)
                                                                                    }
                                                                                    self.editTaskUpdateAction = 0
                                                                                    self.viewRouter.currentView = "todaysGoals"
                                        })
                                        ){
                                            
                                            Text(task.task_title)
                                                .onTapGesture(count: 2) {
                                                    self.managedObjectContext.performAndWait {
                                                        task.task_completed.append(Date())
                                                    }
                                                    try? self.managedObjectContext.save()
                                                    
                                                    self.viewRouter.currentView = "todaysGoals"
                                            }
                                        }
                                        
                                    }
                                }
                                .onDelete(perform: self.deleteDailyTask)
                            }
                            
                            Section(header: Text("Upcoming Tasks")){
                                ForEach(self.upcomingTasks
                                    // one time goals should always have due dates
                                    .filter({$0.task_dueDate != nil && $0.task_completed.isEmpty})
                                    .sorted(by: {$0.task_dueDate! < $1.task_dueDate!})){
                                        task in
                                        NavigationLink(destination: EditTaskView(title: task.task_title, frequency: task.task_frequency, notificationsOn: task.task_notification, dueDate: task.task_dueDate ?? Date(), dayOfWeek: task.task_dayOfWeek, task: task,
                                                                                 originalStateDueToday: Util.isTaskDueToday(t: task), editTaskAction: self.$editTaskUpdateAction, onSave: {
                                                                                    if (self.editTaskUpdateAction == 2) {
                                                                                        self.upcomingTasks.remove(at: self.upcomingTasks.firstIndex(of: task)!)
                                                                                        self.tasksDueToday.append(task)
                                                                                    }
                                                                                    self.editTaskUpdateAction = 0
                                                                                    self.viewRouter.currentView = "todaysGoals"
                                        })
                                        ){
                                            HStack() {
                                                Text(task.task_title)
                                                    .frame(width: geometry.size.height/5, alignment: .leading)
                                                Text(Util.dateToString(date: task.task_dueDate!))
                                                    .frame(width: geometry.size.height/5, alignment: .trailing)
                                            }.onTapGesture(count: 2) {
                                                self.managedObjectContext.performAndWait {
                                                    task.task_completed.append(Date())
                                                }
                                                try? self.managedObjectContext.save()
                                                
                                                self.viewRouter.currentView = "todaysGoals"
                                            }
                                        }
                                }
                            }
                            
                            Section(header: Text("Completed Tasks")){
                                ForEach(self.getSortedCompletedTasks()){
                                    task in
                                    if  (task.task_deletedAt == nil || Calendar.current.compare(Date(), to: task.task_deletedAt!, toGranularity: .day).rawValue < 0) {
                                        NavigationLink(destination: ViewTaskView(title: task.task_title, frequency: task.task_frequency, notificationsOn: task.task_notification, dueDate: task.task_dueDate ?? Date(), dayOfWeek: task.task_dayOfWeek, onSave: {})
                                        ){
                                            Text(task.task_title)
                                        }
                                    }
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
                                self.dueDate = Date()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 75, height: 75)
                                    .foregroundColor(.blue)
                            }.sheet(isPresented: self.$modalDisplayed) {
                                AddTaskView(title: self.$task_title, frequency: self.$task_frequency,
                                            notificationsOn: self.$task_notification,
                                            taskSubmitted: self.$addTaskCompleted, modalDisplayed: self.$modalDisplayed,
                                            dueDate: self.$dueDate, dayOfWeek: self.$dayOfWeek, onSubmit: {
                                                if (self.addTaskCompleted){
                                                    
                                                    let task = Task(context: self.managedObjectContext)
                                                    
                                                    task.task_title = self.task_title
                                                    task.task_frequency = self.task_frequency
                                                    task.task_notification = self.task_notification
                                                    task.task_createdAt = Date()
                                                    task.task_dueDate = self.dueDate
                                                    task.task_dayOfWeek = self.dayOfWeek
                                                    task.task_completed = []
                                                    
                                                    do {
                                                        try self.managedObjectContext.save()
                                                        
                                                    } catch {
                                                        print(error)
                                                    }
                                                    
                                                    if task.task_frequency == 0 {
                                                        if (Util.isTaskDueToday(t: task)) {
                                                            self.tasksDueToday.append(task)
                                                        } else {
                                                            self.upcomingTasks.append(task)
                                                        }
                                                    } else if task.task_frequency == 1 {
                                                        self.tasksDueToday.append(task)
                                                    } else {
                                                        if Util.isTaskDueToday(t: task){
                                                            self.tasksDueToday.append(task)
                                                        }
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
            self.todaysTaskCompleted = false
            
            for i in 0..<self.tasks.count {
                let task = self.tasks[i]
                
                if task.task_frequency == 1 {
                    self.tasksDueToday.append(task)
                } else if task.task_frequency == 2 {
                    if Util.isTaskDueToday(t: task){
                        self.tasksDueToday.append(task)
                    }
                } else {
                    if (Util.isTaskDueToday(t: task)) {
                        self.tasksDueToday.append(task)
                    } else {
                        self.upcomingTasks.append(task)
                    }
                }
            }
        }
    }
        
    func deleteDailyTask(with indexSet: IndexSet){
        self.managedObjectContext.performAndWait {
            self.tasksDueToday[indexSet.first!].task_deletedAt = Date()
        }
        try? self.managedObjectContext.save()
        self.tasksDueToday.remove(at: indexSet.first!)
    }
    
    func getSortedCompletedTasks() -> [Task] {
        let completedUpcoming = upcomingTasks.filter{!$0.task_completed.isEmpty}
        let completedDueToday = tasksDueToday.filter{!$0.task_completed.isEmpty && Calendar.current.compare(Date(), to: $0.task_completed.last!, toGranularity: .day).rawValue == 0}
        let allCompletedTasks = completedDueToday + completedUpcoming
        return allCompletedTasks.sorted(by: {$0.task_completed.last! > $1.task_completed.last!})
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
