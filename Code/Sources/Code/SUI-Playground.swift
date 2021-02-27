//
//  File.swift
//  
//
//  Created by Lucas Stomberg on 2/26/21.
//

import Foundation
import SwiftUI

struct SomeView : View {
    var body: some View {
        Image(systemName: "table")
          .resizable()
          .frame(width: 30, height: 30)
          .overlay(Circle().stroke(Color.gray, lineWidth: 1))
          .background(Color(white: 0.9))
          .clipShape(Circle())
          .foregroundColor(.red)
    }
}

struct Previews : PreviewProvider {
    
    static var previews: some View {
        SomeView()
            .previewLayout(.sizeThatFits)
    }
}
