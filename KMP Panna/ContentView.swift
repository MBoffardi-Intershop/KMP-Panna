//
//  ContentView.swift
//  KMP Panna
//
//  Created by Mauro Boffardi on 30.01.24.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = TABS.MONITORING
    @AppStorage("cfg_isNotificationEnabled") private var cfg_isNotificationEnabled: Bool = false
    
    var body: some View {
                TabView(selection: $selectedTab) {
                    MonitorView()
                        .tabItem {
                            Image(systemName: "flame.fill")
                            Text("Status")
                        }
                        .tag(TABS.MONITORING)
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gearshape")
                            Text("Settings")
                        }
                        .tag(TABS.SETTINGS)

                }
                .onAppear() {
                    if cfg_isNotificationEnabled {
                        print ("Notifications are enabled, registering the Background Task")
                        BackgroundTask().registerBackgroundTask()
                    }
                }
    }  // enf of view
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
