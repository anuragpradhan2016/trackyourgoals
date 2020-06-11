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
    @State var reminder = Util.localDate(date: Date())
    @State var addTaskCompleted = false
    @State var dueDate = Util.localDate(date: Date())
    @State var dayOfWeek = 0
    @State var numOfTasks = 0
    
    @State var taskSwipe = CGSize.zero
    @State var editTaskUpdateAction: Int = 0 // 0-> nothing, 1 -> delete from daily, 2 -> add to daily
    @State var tasksDueToday: [Task] = []
    @State var upcomingTasks: [Task] = []
    @State var history: [String : [Task]] = [:]
    @State var collapsed = [0, 1, 1] // i = 1 => the ith section of home is collapsed
    @State var details = ""
    
    var backgroundColor = Color.black.opacity(0.9)
    var backgroundUIColor = UIColor.black.withAlphaComponent(0.9)
    
    var foregroundColor = Color.white
    var foregroundUIColor = UIColor.white
    
    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let coloredNavAppearance = UINavigationBarAppearance()
    
    init() {
        coloredNavAppearance.configureWithOpaqueBackground()
        coloredNavAppearance.backgroundColor = backgroundUIColor.withAlphaComponent(0)
        coloredNavAppearance.titleTextAttributes = [.foregroundColor: foregroundUIColor]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: foregroundUIColor]
        
        UITableView.appearance().separatorColor = UIColor.gray.withAlphaComponent(0.4)
        UITableView.appearance().backgroundColor = backgroundUIColor
        UITableViewCell.appearance().backgroundColor = backgroundUIColor.withAlphaComponent(0)
        
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                if self.viewRouter.currentView == "todaysGoals" {
                    NavigationView {
                        List {
                            Section(header:
                                HStack {
                                    Text("Today's Tasks").frame(width: geometry.size.width / 2, alignment: .leading).offset(x: geometry.size.width / 20).foregroundColor(self.foregroundColor).padding()
                                    
                                    Button(action: {
                                        self.collapsed[0] = 1 - self.collapsed[0]
                                        self.viewRouter.currentView = "todaysGoals"
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
                                    }.frame(width: geometry.size.width / 2, alignment: .trailing).offset(x: -geometry.size.width / 10)
                                }.frame(width: geometry.size.width).background(self.backgroundColor.opacity(0.95)).listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))) {
                                    if (self.collapsed[0] == 0) {
                                        ForEach(self.tasksDueToday.filter{($0.task_completed.isEmpty || Calendar.current.compare(Util.localDate(date: Date()), to: $0.task_completed.last!, toGranularity: .day).rawValue != 0) && ($0.task_deletedAt == nil || Calendar.current.compare(Util.localDate(date: Date()), to: $0.task_deletedAt!, toGranularity: .day).rawValue < 0)}){
                                            task in
                                            ZStack {
                                                NavigationLink(destination: EditTaskView(title: task.task_title, frequency: task.task_frequency, notificationsOn: task.task_notification, dueDate: task.task_dueDate ?? Util.localDate(date: Date()), dayOfWeek: task.task_dayOfWeek, task: task, reminder: task.task_notification ? task.task_reminder! : Util.localDate(date: Date()),
                                                                                         originalStateDueToday: Util.isTaskDueToday(t: task), editTaskAction: self.$editTaskUpdateAction,
                                                                                         details: task.task_details, onSave: {
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
                                                    EmptyView()
                                                }
                                                HStack {
                                                    Text(task.task_title)
                                                        .foregroundColor(self.foregroundColor)
                                                        .onTapGesture(count: 2) {
                                                            self.managedObjectContext.performAndWait {
                                                                task.task_completed.append(Util.localDate(date: Date()))
                                                            }
                                                            try? self.managedObjectContext.save()
                                                            
                                                            self.viewRouter.currentView = "todaysGoals"
                                                    }
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 7)
                                                        .foregroundColor(self.foregroundColor)
                                                }
                                            }
                                        }
                                        .onDelete(perform: self.deleteDailyTask)
                                    }
                            }
                            
                            Section(header:
                                HStack {
                                    Text("Upcoming Tasks").frame(width: geometry.size.width / 2, alignment: .leading).offset(x: geometry.size.width / 20).foregroundColor(self.foregroundColor).padding()
                                    Button(action: {
                                        self.collapsed[1] = 1 - self.collapsed[1]
                                        self.viewRouter.currentView = "todaysGoals"
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
                                    }.frame(width: geometry.size.width / 2, alignment: .trailing).offset(x: -geometry.size.width / 10)
                                }.frame(width: geometry.size.width).background(self.backgroundColor.opacity(0.95)).listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))) {
                                    if (self.collapsed[1] == 0) {
                                        ForEach(self.upcomingTasks
                                            // one time goals should always have due dates
                                            .filter({$0.task_dueDate != nil && $0.task_completed.isEmpty})
                                            .sorted(by: {$0.task_dueDate! < $1.task_dueDate!})){
                                                task in
                                                ZStack {
                                                    NavigationLink(destination: EditTaskView(title: task.task_title, frequency: task.task_frequency, notificationsOn: task.task_notification, dueDate: task.task_dueDate ?? Util.localDate(date: Date()), dayOfWeek: task.task_dayOfWeek, task: task, reminder: task.task_notification ? task.task_reminder! : Util.localDate(date: Date()),
                                                                                             originalStateDueToday: Util.isTaskDueToday(t: task), editTaskAction: self.$editTaskUpdateAction,
                                                                                             details: task.task_details, onSave: {
                                                                                                if (self.editTaskUpdateAction == 2) {
                                                                                                    self.upcomingTasks.remove(at: self.upcomingTasks.firstIndex(of: task)!)
                                                                                                    self.tasksDueToday.append(task)
                                                                                                }
                                                                                                self.editTaskUpdateAction = 0
                                                                                                self.viewRouter.currentView = "todaysGoals"
                                                    })
                                                    ){
                                                        EmptyView()
                                                    }
                                                    HStack() {
                                                        Text(task.task_title)
                                                            .frame(width: geometry.size.height/5, alignment: .leading)
                                                            .foregroundColor(self.foregroundColor)
                                                        
                                                        
                                                        Text(Util.dateToString(date: task.task_dueDate!))
                                                            .frame(width: geometry.size.height/5)
                                                            .foregroundColor(self.foregroundColor)
                                                        
                                                        Spacer()
                                                        Image(systemName: "chevron.right")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 7)
                                                            .foregroundColor(self.foregroundColor)
                                                    }.onTapGesture(count: 2) {
                                                        self.managedObjectContext.performAndWait {
                                                            task.task_completed.append(Util.localDate(date: Date()))
                                                        }
                                                        try? self.managedObjectContext.save()
                                                        
                                                        self.viewRouter.currentView = "todaysGoals"
                                                    }
                                                }
                                        }
                                            
                                        .onDelete(perform: self.deleteUpComingTask)
                                    }
                            }
                            
                            Section(header:
                                HStack {
                                    Text("Completed Tasks").frame(width: geometry.size.width / 2, alignment: .leading).offset(x: geometry.size.width / 20).foregroundColor(self.foregroundColor).padding()
                                    Button(action: {
                                        self.collapsed[2] = 1 - self.collapsed[2]
                                        self.viewRouter.currentView = "todaysGoals"
                                    }) {
                                        if (self.collapsed[2] == 0) {
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
                                    }.frame(width: geometry.size.width / 2, alignment: .trailing).offset(x: -geometry.size.width / 10)
                                }.frame(width: geometry.size.width).background(self.backgroundColor.opacity(0.95)).listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)))  {
                                    if (self.collapsed[2] == 0) {
                                        ForEach(self.getSortedCompletedTasks()){
                                            task in
                                            ZStack {
                                                NavigationLink(destination: ViewTaskView(title: task.task_title, frequency: task.task_frequency, notificationsOn: task.task_notification, dueDate: task.task_dueDate ?? Util.localDate(date: Date()), dayOfWeek: task.task_dayOfWeek, details: task.task_details, onSave: {})
                                                ){
                                                    EmptyView()
                                                }
                                                HStack { Text(task.task_title).foregroundColor(self.foregroundColor)
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 7)
                                                        .foregroundColor(self.foregroundColor)
                                                }
                                            }
                                        }
                                    }
                            }
                            
                        }
                        .navigationBarTitle(Text("Your Goals").foregroundColor(Color.white).font(.subheadline), displayMode: .large)
                    }
                } else if self.viewRouter.currentView == "history" {
                    NavigationView {
                        List {
                            ForEach(self.history.sorted(by: {Calendar.current.compare(Util.stringToDate(date: $0.key), to: Util.stringToDate(date: $1.key), toGranularity: .day).rawValue > 0}), id: \.key) { key, value in
                                ZStack {
                                    NavigationLink(destination: HistoryDayView(date: key, tasks: value, geometryWidth: geometry.size.width)) {
                                        EmptyView()
                                    }
                                    
                                    HStack {
                                        Text("\(key): Completed \(self.howManyTasksCompleted(date: key)) out of \(value.count) tasks")
                                            .foregroundColor(self.howManyTasksCompleted(date: key) == value.count ? .green : .red)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 7)
                                            .foregroundColor(self.foregroundColor)
                                    }
                                }
                            }
                        }
                        .navigationBarTitle(Text("History").foregroundColor(Color.white))
                    }
                }
                
                Divider().background(Color.white)
                
                ZStack {
                    HStack {
                        CustomTabViewItem(name: "house", width: geometry.size.width/3, foregroundColor: self.viewRouter.currentView == "todaysGoals" ? .white : .gray, onTapGesture: {self.viewRouter.currentView = "todaysGoals"})
                        
                        ZStack {
                            Button(action: {
                                self.modalDisplayed = true
                                self.task_title = ""
                                self.task_frequency = 0
                                self.task_notification = false
                                self.addTaskCompleted = false
                                self.details = ""
                                self.dueDate = Util.localDate(date: Date())
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(.white)
                            }.sheet(isPresented: self.$modalDisplayed) {
                                AddTaskView(title: self.$task_title, frequency: self.$task_frequency,
                                            notificationsOn: self.$task_notification,
                                            taskSubmitted: self.$addTaskCompleted, modalDisplayed: self.$modalDisplayed,
                                            dueDate: self.$dueDate, dayOfWeek: self.$dayOfWeek, reminder: self.$reminder, id: self.numOfTasks, onSubmit: {
                                                if (self.addTaskCompleted){
                                                    
                                                    let task = Task(context: self.managedObjectContext)
                                                    
                                                    task.task_title = self.task_title
                                                    task.task_frequency = self.task_frequency
                                                    task.task_notification = self.task_notification
                                                    task.task_createdAt = Util.localDate(date: Date())
                                                    task.task_dueDate = Util.localDate(date: self.dueDate)
                                                    task.task_dayOfWeek = self.dayOfWeek
                                                    task.task_reminder = self.reminder
                                                    task.task_completed = []
                                                    task.task_id = self.numOfTasks
                                                    self.numOfTasks += 1
                                                    
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
                        
                        
                        CustomTabViewItem(name: "clock", width: geometry.size.width/3, foregroundColor: self.viewRouter.currentView == "history" ? .white : .gray, onTapGesture: {self.viewRouter.currentView = "history"})
                        
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height/10)
                    .background(self.backgroundColor)
                }
            }.edgesIgnoringSafeArea(.bottom)
        }.onAppear() {
            // get previous days date
            let yesterday = Util.getPreviousDay(date: Util.localDate(date: Date()))
            var date = yesterday
            
            // get the task with the earliest create date (history will go from yesterday to this date)
            let firstTask = self.tasks.min(by: {$0.task_createdAt < $1.task_createdAt})
            
            if firstTask != nil {
                while(Calendar.current.compare(date, to: firstTask!.task_createdAt, toGranularity: .day).rawValue >= 0) {
                    self.history[Util.dateToString(date: date)] = []
                    date = Util.getPreviousDay(date: date)
                }
            }
            
            for i in 0..<self.tasks.count {
                let task = self.tasks[i]
                
                if task.task_frequency == 1 {
                    self.tasksDueToday.append(task)
                    
                    let date = task.task_createdAt
                    var lastDate = task.task_deletedAt ?? yesterday
                    
                    if (Calendar.current.compare(Util.localDate(date: Date()), to: lastDate, toGranularity: .day).rawValue == 0) {
                        lastDate = Util.getPreviousDay(date: lastDate)
                    }
                    
                    while(Calendar.current.compare(date, to: lastDate, toGranularity: .day).rawValue <= 0) {
                        self.history[Util.dateToString(date: lastDate)]!.append(task)
                        lastDate = Util.getPreviousDay(date: lastDate)
                    }
                } else if task.task_frequency == 2 {
                    if Util.isTaskDueToday(t: task){
                        self.tasksDueToday.append(task)
                    }
                    
                    let date = task.task_createdAt
                    var lastDate = task.task_deletedAt ?? yesterday
                    
                    if (Calendar.current.compare(Util.localDate(date: Date()), to: lastDate, toGranularity: .day).rawValue == 0) {
                        lastDate = Util.getPreviousDay(date: lastDate)
                    }
                    
                    while(Calendar.current.compare(lastDate, to: date, toGranularity: .day).rawValue >= 0) {
                        let date = Util.localDate(date: lastDate)
                        let dateFormatter = DateFormatter()
                        
                        dateFormatter.dateFormat = "EEEE"
                        dateFormatter.timeZone = .current
                        
                        let dayInWeek = dateFormatter.string(from: date).capitalized
                        
                        if Util.days[task.task_dayOfWeek] == dayInWeek {
                            self.history[Util.dateToString(date: lastDate)]!.append(task)
                        }
                        
                        lastDate = Util.getPreviousDay(date: lastDate)
                    }
                    
                } else {
                    if (Util.isTaskDueToday(t: task)) {
                        self.tasksDueToday.append(task)
                    } else if Calendar.current.compare(Util.localDate(date: Date()), to: task.task_dueDate!, toGranularity: .day).rawValue < 0 {
                        self.upcomingTasks.append(task)
                    }
                    
                    if (task.task_deletedAt == nil && Calendar.current.compare(Util.localDate(date: Date()), to: task.task_dueDate!, toGranularity: .day).rawValue > 0) {
                        self.history[Util.dateToString(date: task.task_dueDate!)]!.append(task)
                    }
                }
            }
            self.history = self.history.filter({!$0.value.isEmpty})
            self.numOfTasks = self.tasks.count
        }
    }
    
    func deleteDailyTask(with indexSet: IndexSet){
        self.managedObjectContext.performAndWait {
            self.tasksDueToday[indexSet.first!].task_deletedAt = Util.localDate(date: Date())
        }
        try? self.managedObjectContext.save()
        self.tasksDueToday.remove(at: indexSet.first!)
    }
    
    func deleteUpComingTask(with indexSet: IndexSet){
        self.managedObjectContext.performAndWait {
            self.upcomingTasks[indexSet.first!].task_deletedAt = Util.localDate(date: Date())
        }
        try? self.managedObjectContext.save()
        self.upcomingTasks.remove(at: indexSet.first!)
    }
    
    func getSortedCompletedTasks() -> [Task] {
        let completedUpcoming = upcomingTasks.filter{!$0.task_completed.isEmpty}
        let completedDueToday = tasksDueToday.filter{!$0.task_completed.isEmpty && Calendar.current.compare(Util.localDate(date: Date()), to: $0.task_completed.last!, toGranularity: .day).rawValue == 0}
        let allCompletedTasks = completedDueToday + completedUpcoming
        return allCompletedTasks.sorted(by: {$0.task_completed.last! > $1.task_completed.last!}).filter{($0.task_deletedAt == nil || Calendar.current.compare(Util.localDate(date: Date()), to: $0.task_deletedAt!, toGranularity: .day).rawValue < 0)}
    }
    
    func howManyTasksCompleted(date: String) -> Int {
        if self.history[date] != nil {
            var count = 0
            for task in self.history[date]! {
                if !task.task_completed.isEmpty {
                    if task.task_completed.first(where: {Calendar.current.compare(Util.stringToDate(date: date), to: $0, toGranularity: .day).rawValue == 0}) != nil {
                        count += 1
                    }
                }
            }
            
            return count
        } else {
            return 0
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
