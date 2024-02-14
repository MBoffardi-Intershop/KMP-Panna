//
//  KMPUtilities.swift
//  KMP-Panna
//
//  Meant to incorporate all KMP-specific logic for connections and data parse
//  Created by Mauro Boffardi on 31.01.24.
//

import Foundation
import SwiftUI

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
    var showDetails: Bool {
        (self.status == STATUS.LOADING) ||
        (self.status == STATUS.WARMUP) ||
        (self.status == STATUS.IGNITION) ||
        (self.status == STATUS.HIGHEFFECT) ||
        (self.status == STATUS.COOLDOWN)
    }
}


func getJSONURL(host: String? = nil) -> URL {
    // use also some error catching instead of retuning empty
    @AppStorage("cfg_burnerHost") var cfg_burnerHost: String = DEFAULTS.BURNER_IP
    var _host = host
    if (host == nil) {
        _host = cfg_burnerHost
    }
    let jsonURL = URL(string: "http://\(_host!)/data.html")!
    return jsonURL
}

// Used in the test button in settings
func getKMPUXURL(host: String) -> URL {
    let kmpUxURL = URL(string: "http://\(host)/")!
    return kmpUxURL
}

enum ConnectionError: Error {
    case invalidHost
    case noConnection
    case noValidJSON
}



class KMPBurnerModel: ObservableObject {
    @Published var kmpData: KMPData?
    @AppStorage("cfg_httpTimeout") var cfg_httpTimeout: Double = DEFAULTS.HTTPTIMEOUT
    
    var isFetchingData = false
    
    // Maps JSON values into ready to use and understandabe values
    func decodeInfo(kmp: KMPData) ->Info {
        
        var info = Info(timestamp: Date())
        
        // Status image and description
        info.isInError = false
        switch kmp.mode2 {
        case "0":
            info.status = STATUS.OFF
            info.statusDesc = "Online, but OFF"
        case "2":
            info.status = STATUS.STANDBY
            info.statusDesc = "Standby"
        case "3":
            info.status = STATUS.LOADING
            info.statusDesc = "Loading pellets"
        case "4":
            info.status = STATUS.IGNITION
            info.statusDesc = "Igniting"
        case "5":
            info.status = STATUS.WARMUP
            info.statusDesc = "Warming up"
        case "8":
            info.status = STATUS.HIGHEFFECT
            info.statusDesc = "Burning with high effect"
        case "9","10":
            info.status = STATUS.COOLDOWN
            info.statusDesc = "Cooling down"
        default:
            info.status = STATUS.ERROR
            info.statusDesc = "\(kmp.alarm1)\n\(kmp.alarm2)"
            info.isInError = true
        }

        info.currentTemp = Double(kmp.ttop) ?? -1
        // KMP bug: pressure does not handle negative values
        let pressure = Int(kmp.draft) ?? 0
        if pressure > 32768 {
            info.xhaustPressure = 65534 - pressure
        } else {
            info.xhaustPressure = pressure
        }
        info.flame = Double(kmp.tFlame) ?? -1
        info.flameFan = Int(kmp.cFan) ?? 0
        info.igniterOn = !kmp.glow.starts(with: "AV") // ON if does not START with AVSTÄNGT
        info.pelletLoader = Int(kmp.feed) ?? -1
        info.startTemp = Double(kmp.tStart) ?? 0
        info.stopTemp = Double(kmp.tStop) ?? 0
        
        return info
    }
    
    // Get the JSON from the provided host.
    func fetchKMPData() {
        let pannaURL = getJSONURL()
        print("Recovering data from \(pannaURL), timeout \(cfg_httpTimeout)s")
        
        // Check if already fetching data
        guard !isFetchingData else {
            print("Skipping, there is already a request pending.")
            return }
        
        isFetchingData = true
        
        let urlRequest = URLRequest(url: pannaURL, timeoutInterval: cfg_httpTimeout)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                return
            }
            
            do {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Data: \(jsonString)")
                }
                //print ("now decoding")
                let decoder = JSONDecoder()
                let kmpData = try decoder.decode(KMPData.self, from: data)
                DispatchQueue.main.async {
                    self.kmpData = kmpData
                    print ("KMPData refreshed.")
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
            
            self.isFetchingData = false
        }
        
        dataTask.resume()
    }
    
    // tries to get and decde JSON from provided host, true if connection works, false otherwise
    /*
    func testKMPConnection (host: String) throws -> Bool {
        let decoder = JSONDecoder()
        var pannaURL = getJSONURL(host: host)
        var data: Data
        
        do {
            data = try Data(contentsOf: pannaURL)
        } catch {
            throw ConnectionError.noConnection
        }
        
        do {
            let _ = try decoder.decode(KMPData.self, from: data)
        } catch {
            throw ConnectionError.noValidJSON
        }
        return true

    }
    */
    
    func resetFetchingStatus() {
        isFetchingData = false
    }
}
