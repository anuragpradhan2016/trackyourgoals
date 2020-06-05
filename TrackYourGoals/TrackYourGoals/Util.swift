//
//  Util.swift
//  TrackYourGoals
//
//  Created by Anurag Pradhan on 6/3/20.
//  Copyright © 2020 Anurag Pradhan. All rights reserved.
//

import Foundation

class Util {
    static var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    static func isTaskDueToday(t: Task) -> Bool {
        if t.task_frequency == 0 {
            return Calendar.current.compare(Util.localDate(date: Date()), to: t.task_dueDate!, toGranularity: .day).rawValue == 0
        } else if t.task_frequency == 1 {
            return true
        } else {
            let date = Util.localDate(date: Date())
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            dateFormatter.timeZone = .current
            let dayInWeek = dateFormatter.string(from: date).capitalized
            
            return Util.days[t.task_dayOfWeek] == dayInWeek
        }
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
    
    static func localDate (date: Date) -> Date {
        return Util.stringToDate(date: Util.dateToString(date: date))
    }
}
