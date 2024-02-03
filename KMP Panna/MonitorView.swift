//
//  MonitorView.swift
//  KMP-Panna
//
//  Created by Mauro Boffardi on 02.02.24.
//


import SwiftUI



struct MonitorView: View {
    @StateObject var viewModel = KMPBurnerModel()
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
                viewModel.fetchKMPData()
            }
            
            // Fetch the data every time the timer expires
            .onReceive(timer) { _ in
                print ("onReceive()")
                viewModel.fetchKMPData()
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

#Preview {
    MonitorView()
}
