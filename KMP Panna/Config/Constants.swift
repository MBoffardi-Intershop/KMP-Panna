//
//  Constants.swift
//  KMP-Panna
//
//  Created by Mauro Boffardi on 31.01.24.
//

import Foundation

enum STATUS {
    static let OFF = 0
    static let STANDBY = 2
    static let LOADING = 3
    static let IGNITION = 4
    static let WARMUP = 5
    static let HIGHEFFECT = 8
    static let COOLDOWN = 10
    static let ERROR = -1
}

enum DEFAULTS {
    static let BURNER_IP = "10.0.0.35"
    static let REFRESH: Double = 10
    static let HTTPTIMEOUT: Double = 30
}

enum TABS {
    static let MONITORING = 0
    static let SETTINGS = 1
}
