//
//  SettingsView.swift
//  KMP-Panna
//
//  Created by Mauro Boffardi on 31.01.24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("cfg_burnerHost") var cfg_burnerHost: String = DEFAULTS.BURNER_IP
    @AppStorage("cfg_refreshInterval") var cfg_refreshInterval: Double = DEFAULTS.REFRESH
    @AppStorage("cfg_httpTimeout") var cfg_httpTimeout: Double = DEFAULTS.HTTPTIMEOUT
    @State private var isRefreshEditing: Bool = false
    @State private var isTimeoutEditing: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage = ""
    @State private var isTesting = false
    
    @State private var test = ""
    @State private var testD = 0.0

    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Timeout"),
                        footer: Text("Timeout is the time that the app shud wait for a response, 30sec is usually ok but it can be set higher for slower conections.")) {
                    Slider(
                        value: $cfg_httpTimeout,
                        in: 5...90, step: 5,
                        onEditingChanged: { editing in
                            isTimeoutEditing = editing
                            print("isTimeoutEditing = \(isRefreshEditing)")
                        }
                    )
                    Text("Timeout: \(Int(cfg_httpTimeout)) seconds")
                        .foregroundColor(isTimeoutEditing ? .red : .blue)
                }

                
                Section(header: Text("Connection"),
                        footer: Text("IP or hostname of the KMP Pellet Burner, as shown in the advanced configuration screen on the device. Do not provide protocol (http://) or a URL.")) {
                    
                    TextField("Burner IP or hostname", text: $cfg_burnerHost)
                }
                
                Section(header: Text("TEST"),
                        footer: Text("Use these buttons to test the connection")) {

                    if isTesting {
                        ProgressView("Connecting (can take up to \(Int(cfg_httpTimeout))s)...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .padding()
                    } else {
                        Button {
                                self.isTesting = true
                                testConnection()
                            } label: {
                                Text("Test connection")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(Color.white)
                                    .background(Color.accentColor)
                                    .cornerRadius(10)
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("Connection test"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                    } // Not testing

                    
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
                     
                } // End of "Buttons" Section
                .id(UUID())
                                
                Section(header: Text("Data Refresh"),
                        footer: Text("Interval at which new data will be pulled from the burner")) {
                    
                    Slider(
                        value: $cfg_refreshInterval,
                        in: 3...60, step: 1,
                         onEditingChanged: { editing in
                             isRefreshEditing = editing
                             print("isRefreshEditing = \(isRefreshEditing)")
                         }
                     )
                    
                     Text("\(Int(cfg_refreshInterval)) seconds")
                         .foregroundColor(isRefreshEditing ? .red : .blue)
                }
                
            }
            .navigationTitle("Settings")
        }
    }
    
    // The actual call is a duplicate of that in fetchKMPData, but it is not a lot of code
    // and it is easier to handle it here together with the progressbar and teh alert messages
    func testConnection() {
        let url = getJSONURL()
        
        let urlRequest = URLRequest(url: url, timeoutInterval: cfg_httpTimeout)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                isTesting = false
                guard let data = data else {
                    alertMessage =  "Cannot connect to host, check hostname or network settings"
                    isTesting = false
                    showAlert = true
                    return
                }
                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Test: received Raw JSON Data: \(jsonString)")
                    }
                    let decoder = JSONDecoder()
                    let _ =  try decoder.decode(KMPData.self, from: data)
                    
                    alertMessage =  "Connection tested successfully!"
                    isTesting = false
                    showAlert = true
                } catch {
                    alertMessage = "I can connect to host, but it looks like it is not a KMP Burner"
                    isTesting = false
                    showAlert = true
                }
            }
        }
        task.resume()
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
