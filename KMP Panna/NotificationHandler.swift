//
//  NotificationHandler.swift
//  KMP-Panna
//
//  Created by Mauro Boffardi on 07.02.24.
//

import Foundation
import UserNotifications
import SwiftUI

struct NotificationHandler {
    static func raiseNotification(title: String = "KMP Panna", body: String, critical: Bool = false) {
        @AppStorage("cfg_isNotificationEnabled") var cfg_isNotificationEnabled: Bool = false

        if !cfg_isNotificationEnabled {
            print ("Notification disabled.")
            return
        }
        print ("Notification: title=\(title), body=\(body)")
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if (critical) {
            content.sound = UNNotificationSound.default
        } else {
            content.sound = UNNotificationSound.default
            // Requires entitlement from Apple, wait for it for the moment.
            // Critical Sound bypasses mute switch and DoNotDisturb
            //content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)
        }
            
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
