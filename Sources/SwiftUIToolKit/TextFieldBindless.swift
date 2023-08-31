//
//  SwiftUIView.swift
//
//
//  Created by Daniel Fortes on 31/08/23.
//

import SwiftUI

public struct TextFieldBindless<Label: View>: View {
    var label: () -> Label
    var text: String
    var onCommit: (String) -> ()
    
    @FocusState private var focus: Bool
    @State private var editingText: String = ""
    @State private var isEditing = false
    
    public init(label: @escaping () -> Label, text: String, onCommit: @escaping (String) -> ()) {
        self.label = label
        self.text = text
        self.onCommit = onCommit
    }
    
    public init<S: StringProtocol>(_ labelText: S, text: String, onCommit: @escaping (String) -> ()) where Label == Text {
        self.label = { Text(labelText) }
        self.text = text
        self.onCommit = onCommit
    }
}
 
extension TextFieldBindless {
    public var body: some View {
        TextField(text: isEditing ? $editingText : .constant(text), label: label)
            .focused($focus, equals: true)
#if canImport(AppKit)
            .onExitCommand { escKeyHandler() }
#endif
            .onAppear {
#if canImport(AppKit)
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { evt in
                    if evt.keyCode == 53 {
                        escKeyHandler()
                    }
                    return evt
                }
#endif
            }
            .onChange(of: focus) { value in
                if value {
                    editingText = text
                    isEditing = true
                } else if isEditing == true {
                    self.onCommit(editingText)
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        isEditing = false
                    }
                }
            }
    }
    
    func escKeyHandler() {
        focus = false
        isEditing = false
    }
}

struct TextFieldBindless_Previews: PreviewProvider {
    struct Inner: View {
        @State var first = "Hello,"
        @State var second = "World!"
        var body: some View {
            List {
                TextFieldBindless("Hello", text: first) { first = $0 }
                    .tag(0)
                
                TextFieldBindless("Hello", text: second) { second = $0 }
                    .tag(1)
            }
            .listStyle(.sidebar)
        }
    }
    
    static var previews: some View {
        Inner()
    }
}
