//
//  BackgroundTask.swift
//  KMP-Panna
//
//  Created by Mauro Boffardi on 14.02.24.
//

import SwiftUI
import BackgroundTasks

enum Status {
    case INITIAL, ACTIVE, INACTIVE, ERROR, NOCONNECTION
}

var previousStatus = Status.INITIAL

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
        backgroundKMPCall()
        // Call finish() when done
        task.setTaskCompleted(success: true)
        print ("handleBackgroundTask completed.")

    }
    
    
    func backgroundKMPCall() {
        print ("Executing backgroundKMPCall")
        
        do {
            var burner = KMPBurnerModel()
            if let info = try burner.fetchKMPInfoSync() {
                if info.isBurnerActive {
                    print ("Background: burner is active")
                    if previousStatus != Status.ACTIVE {
                        print ("NOTIFICATION: burner became active")
                        previousStatus = Status.ACTIVE
                    }
                } else if info.isInError {
                    print ("Background: burner is in ERROR")
                    if previousStatus != Status.ERROR {
                        print ("NOTIFICATION: burner became in error status")
                        previousStatus = Status.ERROR
                    }
                } else {
                    print ("Background: burner not active")
                    previousStatus = Status.INACTIVE
                }
            } else {
                print ("Background: Unable to connect?")
                if previousStatus != Status.NOCONNECTION {
                    print ("NOTIFICATION: lost connection")
                    previousStatus = Status.NOCONNECTION
                }
            }
                
        } catch {
            print("Exception during BackgroundTask: \(error)")
            if previousStatus != Status.NOCONNECTION {
                print ("NOTIFICATION: lost connection")
                previousStatus = Status.NOCONNECTION
            }
        }
        
        print ("backgroundKMPCall completed.")

    }
    
}
