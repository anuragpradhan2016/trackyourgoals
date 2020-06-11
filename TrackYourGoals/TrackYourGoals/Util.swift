//
//  Util.swift
//  TrackYourGoals
//
//  Created by Anurag Pradhan on 6/3/20.
//  Copyright © 2020 Anurag Pradhan. All rights reserved.
//

import Foundation
import SwiftUI

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}

class Util {
    static var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    static func isTaskDueToday(t: Task) -> Bool {
        if t.task_frequency == 0 {
            return Calendar.current.compare(Util.localDate(date: Date()), to: t.task_dueDate!, toGranularity: .day).rawValue == 0
        } else if t.task_frequency == 1 {
            return true
        } else {
            let date = Util.localDate(date: Date())
            return Util.days[t.task_dayOfWeek] == Util.getWeekDay(date: date)
        }
    }
    
    static func getWeekDay(date: Date) -> String {
        let date = Util.localDate(date: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date).capitalized
    }
    
    static func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.timeZone = .current
        return formatter.string(for: date)!
    }
    
    static func stringToDate(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.timeZone = .current
        return formatter.date(from: date)!
    }
    
    static func getPreviousDay(date: Date) -> Date {
        var dayComponent = DateComponents()
        dayComponent.day = -1
        let calendar = Calendar.current
        return calendar.date(byAdding: dayComponent, to: date)!
    }
    
    static func getNextDay(date: Date) -> Date {
        var dayComponent = DateComponents()
        dayComponent.day = +1
        let calendar = Calendar.current
        return calendar.date(byAdding: dayComponent, to: date)!
    }
    
    static func getPreviousMinute(date: Date) -> Date {
        var minuteComponent = DateComponents()
        minuteComponent.minute = -1
        let calendar = Calendar.current
        return calendar.date(byAdding: minuteComponent, to: date)!
    }
    
    static func localDate (date: Date) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.timeZone = .current
        let stringDate = dateFormatter.string(for: date)!
        
        return dateFormatter.date(from: stringDate)!
    }
    
    static func setReminder(id: Int, frequency: Int, reminder: Date, title: String, dayOfWeek: Int, dueDate: Date) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(status, _) in
            
            if status {
                let content = UNMutableNotificationContent()
                let trigger: UNNotificationTrigger
                content.sound = .default
                
                if frequency == 0 {
                    content.title = "\(title) is due on \(Util.dateToString(date: dueDate))!"
                    trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder), repeats: false)
                } else {
                    if frequency == 1 {
                        content.title = "Your daily goal \(title) is due today!"
                        trigger = UNCalendarNotificationTrigger(dateMatching:  Calendar.current.dateComponents([.hour, .minute], from: reminder), repeats: true)
                    } else {
                        var r = reminder
                        content.title = "Your weekly goal \(title) is due today!"
                        
                        while Util.getWeekDay(date: r) != Util.days[dayOfWeek] {
                            r = Util.getNextDay(date: r)
                        }
                        trigger = UNCalendarNotificationTrigger(dateMatching:  Calendar.current.dateComponents([.weekday, .hour, .minute], from: r), repeats: true)
                    }
                    
                }
                
                let request = UNNotificationRequest(identifier: "\(id)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    if error != nil {
                        print("Reminder notification error")
                    }
                })
                
            }
        }
    }
}
