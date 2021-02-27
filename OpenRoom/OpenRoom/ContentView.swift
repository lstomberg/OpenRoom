//
//  ContentView.swift
//  OpenRoom
//
//  Created by Lucas Stomberg on 2/26/21.
//

import SwiftUI
import Code

struct ContentView: View {
    let testCode = Code()
    
    var body: some View {
        Text(testCode.text)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
