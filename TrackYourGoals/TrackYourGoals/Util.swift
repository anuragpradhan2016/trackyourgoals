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
            return Calendar.current.compare(Date(), to: t.task_dueDate!, toGranularity: .day).rawValue == 0
        } else if t.task_frequency == 1 {
            return true
        } else {
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let dayInWeek = dateFormatter.string(from: date)
            
            
            return Util.days[t.task_dayOfWeek] == dayInWeek
        }
    }
    
    static func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(for: date)!
    }
}
