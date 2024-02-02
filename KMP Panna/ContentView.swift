//
//  ContentView.swift
//  KMP Panna
//
//  Created by Mauro Boffardi on 30.01.24.
//

import SwiftUI

struct ContentView: View {
    @State private var isAppLoading = true // State variable to track APP loading state
    
    var body: some View {
                TabView {
                    MonitorView()
                        .tabItem {
                            Image(systemName: "flame.fill")
                            Text("Status")
                        }
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gearshape")
                            Text("Settings")
                        }
                }
    }  // enf of view
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
