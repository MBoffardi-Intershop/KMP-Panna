//
//  KMPUtilities.swift
//  KMP-Panna
//
//  Meant to incorporate all KMP-specific logic for connections and data parse
//  Created by Mauro Boffardi on 31.01.24.
//

import Foundation

/**
 func getBurnerUXURL: URL () {
 return new
 }
 
 */

// Model for KMP JSON Data
// HAS to be exactly as KMP returns it
struct KMPData: Codable {
    let mode: String        // Text representation of the mode (Localized)
    let glow: String        // Text representation of Igniter status (Localized)
    let ttop: String        // top temperature (water temperature?)
    let tbottom: String     // bottom temperature (always 444° ???)
    let feed: String        // pellet feeder %
    let xFan: String        // exhaust fan %
    let cFan: String        // combustion fan %
    let tFlame: String      // numeric indication of flame
    let tFlue: String       // ?
    let draft: String       // Pressure (Pascal)
    let amps: String        // consumed Amperes
    let tRoom: String      // Temperature in the room ??
    let tStart: String      // Ignition threshold temperature
    let tStop: String       // Turn off maximum temperature
    let nattFlagg: String   // ?
    let mode2: String       // Numeric representation of the mode:
      /*
                2=STANDBY
                3=LOADING
                4=IGNITING
                5=WARMUP
                8=HIGHEFFECT
                10=SHUTTING DOWN
       */
    let alarm1: String      // First line of error message
    let alarm2: String      // Second line of error message
    let lang: String        // language code for localized language
    let bmpT: String         // ??
    let Flame: String       // Optical reading for the flame 0 = no flame, 999 max (?)
    let Hardware: String    // ?
}

// Wrapper Structure that makes KMPData more accessible,
// isolating the JSON value interpretation logic
struct Info {
    var status: Int        = -1        // Index of the image to show on screen
    var statusDesc: String = "N/A"      // Description of the status
    var pelletLoader: Int  = 0          // % of time motor is on
    var flameFan: Int      = 0          // % of speed of flame fan
    var xhaustPressure: Int  = 0        // Pressure of exhausts
    var timestamp: Date                 // Datetime at which data is retrieved
    var igniterOn: Bool    = false      // true if igniter is active
    var flame: Double         = 0          // Num repr brightness of the flame
    var currentTemp: Double   = 0.0     // Current Water Temperature
    var startTemp: Double     = 0.0     // Temperature when to start warming up
    var stopTemp: Double      = 0.0     // Temperature when to stop warming up.
    var isInError: Bool    = false      // Panna is in error state
    var errorMessage1: String = ""      // First line of error message
    var errorMessage2: String = ""      // Second line of error
}


func getJSONURL() -> URL {
    // todo, use configuration values here
    // use also some error catching instead of retuning empty
    let jsonURL = URL(string: "http://" + DEFAULTS.BURNER_IP + "/data.html")!
    return jsonURL
}

// Used in the test button in settings
func getKMPUXURL(host: String) -> URL {
    let kmpUxURL = URL(string: "http://" + host + "/")!
    return kmpUxURL
}
