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
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Connection"),
                        footer: Text("IP or hostname of the KMP Pellet Burner, as displayed in the configuration. Do not provide protocol (http://) or a URL")) {
                    
                    TextField("Burner IP or hostname", text: $cfg_burnerHost)
                    

                    Button {
                        UIApplication.shared.open(getKMPUXURL(host: cfg_burnerHost))
                    } label: {
                        Text("Test")
                            .frame(maxWidth: .infinity)
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
                
                
                Button {
                        print ("savebutton")
                } label: {
                        Text("Save")
                        .frame(maxWidth: .infinity)
                } .buttonStyle(.borderedProminent)
                
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
