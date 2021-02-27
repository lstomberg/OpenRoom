//
//  File.swift
//  
//
//  Created by Lucas Stomberg on 2/26/21.
//

import Foundation
import SwiftUI

// just some convenience functions
// Swift proposal here for 'with': https://gist.github.com/erica/96d9c5bb4eaa3ed3b2ff82dc35aa8dae

// These functions allow a developer to make inline, scoped property adjustments to variables without
//  resorting to inline closures.

// For example:
//     let x = { $0.priority = .defaultLow }(leftAnchor.constraint(equalTo: otherLeftAnchor))
// Can be better understandable as:
//     with(leftAnchor.constraint(equalTo: otherLeftAnchor) { $0.priority = .defaultLow }
// Because the order of operations reads from left to right, which is typical for most languages.

// a replacement for inline closures
// convenience for inline, composed constructors without creating additional helper methods or inits
@discardableResult
public func with<T>(_ item: T, update: (inout T) throws -> Void) rethrows -> T {
    var this = item
    try update(&this)
    return this
}

//
// MARK: SwiftUI
//

public struct BorderedViewModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
      content
        .padding(EdgeInsets(top: 8, leading: 16,
                            bottom: 8, trailing: 16))
        .background(Color.white)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(lineWidth: 2)
            .foregroundColor(.blue)
        )
        .shadow(color: Color.gray.opacity(0.4),
                radius: 3, x: 1, y: 2)
    }
}

extension View {
    
  func bordered() -> some View {
    modifier(BorderedViewModifier())
  }
}
