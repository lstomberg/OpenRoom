//
//  ContentView.swift
//  OpenRoom
//
//  Created by Lucas Stomberg on 2/26/21.
//

import SwiftUI
import Code

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            WebViewAuthenticationTesting()
                .navigationTitle("SAML Testing")
        }.accentColor(.purple)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
