//
//  ContentView.swift
//  KMP Panna
//
//  Created by Mauro Boffardi on 30.01.24.
//

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
}

// Status codes
var STATUS_OFF = 0
var STATUS_STANDBY = 2
var STATUS_LOADING = 3
var STATUS_IGNITION = 4
var STATUS_WARMUP = 5
var STATUS_HIGHEFFECT = 8
var STATUS_COOLDOWN = 10
var STATUS_ERROR = -1

class UserViewModel: ObservableObject {
    @Published var kmpData: KMPData?
    
    var isFetchingData = false
    
    // Maps JSON values into ready to use and understandabe values
    func decodeInfo(kmp: KMPData) ->Info {
        
        var info = Info(timestamp: Date())
        
        // Status image and description
        info.isInError = false
        switch kmp.mode2 {
        case "0":
            info.status = STATUS_OFF
            info.statusDesc = "Online, but OFF"
        case "2":
            info.status = STATUS_STANDBY
            info.statusDesc = "Standby"
        case "3":
            info.status = STATUS_LOADING
            info.statusDesc = "Loading pellets"
        case "4":
            info.status = STATUS_IGNITION
            info.statusDesc = "Igniting"
        case "5":
            info.status = STATUS_WARMUP
            info.statusDesc = "Warming up"
        case "8":
            info.status = STATUS_HIGHEFFECT
            info.statusDesc = "Burning with high effect"
        case "9","10":
            info.status = STATUS_COOLDOWN
            info.statusDesc = "Cooling down"
        default:
            info.status = STATUS_ERROR
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
    
    func fetchKMPData() {
        let pannaURL = "http://10.0.0.35/data.html"
        print("Recovering data from \(pannaURL)")
        guard let url = URL(string: pannaURL) else {
            return
        }
        
        // Check if already fetching data
        guard !isFetchingData else { 
            print("Skipping, there is already a request pending.")
            return }
        
        isFetchingData = true
        
        let urlSession = URLSession(configuration: .default)
        
        let dataTask = urlSession.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return
            }
            
            do {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Data: \(jsonString)")
                }
                print ("now decoding")
                let decoder = JSONDecoder()
                let kmpData = try decoder.decode(KMPData.self, from: data)
                DispatchQueue.main.async {
                    self.kmpData = kmpData
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
            
            self.isFetchingData = false
        }
        
        dataTask.resume()
        urlSession.configuration.timeoutIntervalForRequest = 30
        urlSession.configuration.timeoutIntervalForResource = 30
    }
    
}

struct ContentView: View {
    @StateObject var viewModel = UserViewModel()
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            return formatter
        }()
    
    
    var body: some View {
        ScrollView  {
            VStack(spacing: 15.0) {
                
                if let kmp = viewModel.kmpData {
                    let info = viewModel.decodeInfo(kmp: kmp)
                    
                    Text(info.statusDesc).font(.title)
                    switch info.status {
                    case STATUS_OFF:
                        Image("off").controlSize(.mini)
                    case STATUS_IGNITION:
                        Image("ignition").controlSize(.mini)
                    case STATUS_COOLDOWN:
                        Image("cooldown").controlSize(.mini)
                    case STATUS_HIGHEFFECT:
                        Image("higheffect").controlSize(.mini)
                    case STATUS_LOADING:
                        Image("funnel").controlSize(.mini)
                    case STATUS_STANDBY:
                        Image("sleeping").controlSize(.mini)
                    case STATUS_WARMUP:
                        Image("warmup").controlSize(.mini)
                    default:
                        Image("error").controlSize(.mini)
                    }
                    
                    Gauge(value: info.currentTemp, in: info.startTemp...info.stopTemp) {
                    } currentValueLabel: {
                        
                    } minimumValueLabel: {
                        Text("\(Int(info.startTemp))")
                    } maximumValueLabel: {
                        Text("\(Int(info.stopTemp))")
                    }
                    
                    Text("Temperature \(Int(info.currentTemp))°").controlSize(.extraLarge).font(.title)
                    
                    VStack(spacing: 5.0) {
                        LabeledContent("Igniter", value: (info.igniterOn ? "ON" : "OFF"))
                        LabeledContent("Pellet Loader", value: String(info.pelletLoader) + "%")
                        LabeledContent("Flame fan", value: String(info.flameFan) + "%")
                        LabeledContent("Exhaust Pressure", value: String(info.xhaustPressure) + " P")
                        Gauge(value: info.flame, in: 0...999) {
                            Text("Flame")
                        } currentValueLabel: {
                            Text("\(Int(info.flame))")
                        }
                        
                    }
                    
                    Text("Updated: \(dateFormatter.string(from: info.timestamp))").controlSize(.mini).foregroundColor(.gray)
                    
                } else {
                    Image("offline").controlSize(.mini)
                    Text("Connecting...")
                }
            }
            .padding(20.0)
            .preferredColorScheme(.light)
            
            // Fetch the data the first time the UI appears
            .onAppear() {
                print ("onAppear()")
                viewModel.fetchKMPData()
            }
            
            // Fetch the data every time the timer expires
            .onReceive(timer) { _ in
                print ("onReceive()")
                viewModel.fetchKMPData()
            }
            
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }  // enf of view
        
    
}

#Preview {
    ContentView()
}
