//
//  ContentView.swift
//  KMP Panna
//
//  Created by Mauro Boffardi on 30.01.24.
//

import SwiftUI

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
    
    func fetchKMPData() {
        let pannaURL = getJSONURL()
        print("Recovering data from \(pannaURL)")
        
        // Check if already fetching data
        guard !isFetchingData else { 
            print("Skipping, there is already a request pending.")
            return }
        
        isFetchingData = true
        
        let urlSession = URLSession(configuration: .default)
        
        let dataTask = urlSession.dataTask(with: pannaURL) { data, response, error in
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
        urlSession.configuration.timeoutIntervalForRequest = DEFAULTS.HTTPTIMEOUT
        urlSession.configuration.timeoutIntervalForResource = DEFAULTS.HTTPTIMEOUT
    }
    
}

struct ContentView: View {
    @StateObject var viewModel = UserViewModel()
    let timer = Timer.publish(every: DEFAULTS.REFRESH, on: .main, in: .common).autoconnect()
    
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
                    case STATUS.OFF:
                        Image("off").controlSize(.mini)
                    case STATUS.IGNITION:
                        Image("ignition").controlSize(.mini)
                    case STATUS.COOLDOWN:
                        Image("cooldown").controlSize(.mini)
                    case STATUS.HIGHEFFECT:
                        Image("higheffect").controlSize(.mini)
                    case STATUS.LOADING:
                        Image("funnel").controlSize(.mini)
                    case STATUS.STANDBY:
                        Image("sleeping").controlSize(.mini)
                    case STATUS.WARMUP:
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
                    
                    if (info.status == STATUS.LOADING) ||
                        (info.status == STATUS.WARMUP) ||
                        (info.status == STATUS.IGNITION) ||
                        (info.status == STATUS.HIGHEFFECT) ||
                        (info.status == STATUS.COOLDOWN) {

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
                            
                        }  // End if that shows burner info only when burner is on
                        
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
