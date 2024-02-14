//
//  BackgroundTask.swift
//  KMP-Panna
//
//  Created by Mauro Boffardi on 14.02.24.
//

import SwiftUI
import BackgroundTasks

struct BackgroundTask {
    @AppStorage("cfg_backgroundRefreshInterval") var cfg_backgroundRefreshInterval: TimeInterval = DEFAULTS.BACKGROUND_REFRESH
    let taskIdentifier = "bcc.KMP-Panna.backgroundTask.monitor"

    func registerBackgroundTask() {
        print ("Registering Background Task with ID  \(taskIdentifier)")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleBackgroundTask(task: task as! BGAppRefreshTask)
        }
        scheduleBackgroundTask()
    }
    
    func scheduleBackgroundTask() {
        print ("Scheduling Background Task with interval of  \(cfg_backgroundRefreshInterval)s")
        do {
            let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: cfg_backgroundRefreshInterval)
            try BGTaskScheduler.shared.submit(request)
            print("Background task scheduled.")
        } catch {
            print("Unable to schedule background task: \(error)")
        }
    }
    
    func handleBackgroundTask(task: BGAppRefreshTask) {
        // Perform background work
        // Fetch data, process updates, etc.

        print ("Executing handleBackgroundTask")
        
        // Call finish() when done
        task.setTaskCompleted(success: true)
        print ("handleBackgroundTask completed.")

    }
    
}
