//
//  SettingsView.swift
//  KMP-Panna
//
//  Created by Mauro Boffardi on 31.01.24.
//

import SwiftUI

struct SettingsView: View {
    @State public var cfg_burnerHost = DEFAULTS.BURNER_IP
    @State public var cfg_refreshInterval: Double = DEFAULTS.REFRESH
    @State private var isRefreshEditing: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Connection"),
                        footer: Text("IP or hostname of the KMP Pellet Burner, as displayed in the configuration. Do not provide protocol (http://) or a URL")) {
                    
                    TextField("Burner IP or hostname", text: $cfg_burnerHost)
                    
                        Button {
                            let viewModel = KMPBurnerModel()
                            alertMessage = "Connection tested successfully!"
                            do {
                                var isWorking = try viewModel.testKMPConnection(host: cfg_burnerHost)
                            } catch ConnectionError.invalidHost {
                                alertMessage = "Invalid Host, please use a valid IP or hostname"
                            } catch ConnectionError.noConnection {
                                alertMessage = "Cannot connect to host"
                            } catch ConnectionError.noValidJSON {
                                alertMessage = "I can connect to host, but it looks like it is not a KMP Burner"
                            } catch {
                                alertMessage = "Unexpected error (sorry)"
                            }
                            showAlert = true
                            
                        } label: {
                            Text("Test")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(Color.white)
                                .background(Color.accentColor)
                                .cornerRadius(10)
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Connection test"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }

                        Button (action: {
                            UIApplication.shared.open(getKMPUXURL(host: cfg_burnerHost))
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .padding()
                                     .foregroundColor(.white)
                                Text("Open Web Interface")
                                    .padding()
                                    .foregroundColor(Color.white)

                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(10)

                        }


                }
                
                Section(header: Text("Data Refresh"),
                        footer: Text("Interval at which new data will be pulled from the burner")) {
                    
                    Slider(
                        value: $cfg_refreshInterval,
                        in: 3...60, step: 1,
                         onEditingChanged: { editing in
                             isRefreshEditing = editing
                         }
                     )
                     Text("\(Int(cfg_refreshInterval))")
                         .foregroundColor(isRefreshEditing ? .red : .blue)
                }
                
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
