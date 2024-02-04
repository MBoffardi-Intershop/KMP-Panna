//
//  MonitorView.swift
//  KMP-Panna
//
//  Created by Mauro Boffardi on 02.02.24.
//


import SwiftUI
import Combine

struct MonitorView: View {
    @StateObject var viewModel = KMPBurnerModel()
    @AppStorage("cfg_burnerHost") var cfg_burnerHost: String = DEFAULTS.BURNER_IP
    @AppStorage("cfg_refreshInterval") var cfg_refreshInterval: Double = DEFAULTS.REFRESH
    @Binding var selectedTab: Int  // used to understand which TabView is currently Shown
  

    let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            return formatter
        }()

    // Timer based on the AppStorage variable cfg_refreshInterval.
    // Change the AppStorage value and the timer automagically reset to the new value
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: cfg_refreshInterval, on: .main, in: .common)
            .autoconnect()
    }
        
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
                    
                    if info.showDetails {

                        VStack(spacing: 5.0) {
                            LabeledContent("Igniter", value: (info.igniterOn ? "ON" : "OFF"))
                            LabeledContent("Pellet Loader", value: "\(info.pelletLoader)%")
                            LabeledContent("Flame fan", value: "\(info.flameFan)%")
                            LabeledContent("Exhaust Pressure", value: "\(info.xhaustPressure) P")
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
                //print ("Refresh timer set to \(timer.interval) seconds.")
                viewModel.fetchKMPData()
            }
            
            // Fetch the data every time the timer expires
            .onReceive(timer) { _ in
                print ("onReceive(\(cfg_refreshInterval) sec)")
                    if selectedTab == TABS.MONITORING {
                        viewModel.fetchKMPData()
                    } else {
                        print("Monitorning View is not active, skipping fetchKMPData() call")
                    }
            }
            
        }
        .refreshable {
            print ("Manual Refresh")
            // forces a new request
            viewModel.resetFetchingStatus()
            viewModel.fetchKMPData()
        }
        
    }  // enf of view
        
    
}

struct MonitorView_Previews: PreviewProvider {
    static var previews: some View {
        MonitorView(selectedTab: .constant(TABS.MONITORING))
    }
}
