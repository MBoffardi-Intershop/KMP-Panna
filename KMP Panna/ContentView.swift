//
//  ContentView.swift
//  KMP Panna
//
//  Created by Mauro Boffardi on 30.01.24.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = TABS.MONITORING
    
    var body: some View {
                TabView(selection: $selectedTab) {
                    MonitorView(selectedTab: $selectedTab)
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
    }  // enf of view
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
