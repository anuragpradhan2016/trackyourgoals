//
//  Task.swift
//  TrackYourGoals
//
//  Created by Anurag Pradhan on 6/2/20.
//  Copyright © 2020 Anurag Pradhan. All rights reserved.
//

import Foundation
import CoreData

public class Task:NSManagedObject, Identifiable {
    @NSManaged public var task_dueDate:Date?
    @NSManaged public var task_createdAt:Date
    @NSManaged public var task_title:String
    @NSManaged public var task_frequency:Int // 0 -> Never, 1 -> Daily, 2 -> Weekly
    @NSManaged public var task_notification:Bool
    @NSManaged public var task_completed:Bool
}

extension Task {
    static func getAllTasks() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest() as! NSFetchRequest<Task>
        let sortDescriptor = NSSortDescriptor(key: "task_createdAt", ascending: true)
        
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
}
