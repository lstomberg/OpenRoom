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

// => enum Picker

struct EnumPicker<T: Hashable & CaseIterable, V: View>: View {
    
    var title: String? = nil
    @Binding var selected: T
    let mapping: (T) -> V
    
    var body: some View {
        Picker(selection: $selected, label: Text(title ?? "")) {
            ForEach(Array(T.allCases), id: \.self) {
                mapping($0).tag($0)
            }
        }
    }
}

extension EnumPicker where T: CustomStringConvertible, V == Text {
    
    init(_ title: String? = nil, selected: Binding<T>) {
        self.init(title: title, selected: selected) {
            Text($0.description)
        }
    }
}

struct MenuEnumPicker<T: Hashable & CaseIterable, V: View>: View {
    
    var title: String
    @Binding var selected: T
    let mapping: (T) -> V
    
    var body: some View {
        HStack {
            Text(title).font(.headline)
            Spacer()
            Picker(selection: $selected, label: mapping(selected)) {
                ForEach(Array(T.allCases), id: \.self) {
                    mapping($0).tag($0)
                }
            }.pickerStyle(MenuPickerStyle())
        }
    }
}

extension MenuEnumPicker where T: CustomStringConvertible, V == Text {
    
    init(_ title: String, selected: Binding<T>) {
        self.init(title: title, selected: selected) {
            Text($0.description)
        }
    }
}





struct EnumPicker_Previews : PreviewProvider {
    static var previews: some View {
        EnumPicker(
            "Bindings",
            selected: Binding.constant(Bindings.redirect))
            .previewLayout(.sizeThatFits)
            .pickerStyle(MenuPickerStyle())
    }
}

// => Collapsable section
//extension Section : View where Parent : View, Content : View, Footer : View {
//
//    public init(header: Parent, footer: Footer, @ViewBuilder content: () -> Content)
struct CollapsableSection<Parent, Content, Footer> : View where Parent: View, Content: View, Footer: View {
    let header: Parent
    let footer: Footer
    let content: () -> Content
    @State private var collapsed: Bool
    
    public init(header: Parent, footer: Footer, collapsed: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.header = header
        self.footer = footer
        self._collapsed = State(initialValue: collapsed)
        self.content = content
    }
    
    var body: some View {
        Section(header: HStack {
                header
                Spacer()
                Button(collapsed ? "Expand" : "Collapse") {
                    collapsed.toggle()
                }
                .textCase(.none)
                .padding(.trailing, 4)
            }, footer: footer) {
            if !collapsed {
                content()
            }
        }
    }
}

extension CollapsableSection where Footer == EmptyView {
    
    init(header: Parent, collapsed: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.init(header: header, footer: EmptyView(), collapsed: collapsed, content: content)
    }
}


// => BorderViewModifier

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
