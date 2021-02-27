//
//  File.swift
//  
//
//  Created by Lucas Stomberg on 2/26/21.
//

import Foundation
import SwiftUI

public struct FormTextField : View {
    private let title: String
    private let placeholder: String?
    @Binding private var text: String
    
    init(_ title: String, placeholder: String? = nil, text: Binding<String>) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            TextField(placeholder ?? title, text: $text)
                .modifier(ClearButton(text: $text))
        }
    }
}

public struct ClearButton: ViewModifier {
    @Binding public var text: String
   
    public func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }, label: {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                        .background(Color.white)
                })
            }
        }
    }
}
