//
//  TextFieldBindless.swift
//
//
//  Created by Daniel Fortes on 31/08/23.
//

import SwiftUI

///  This control wraps a `TextField` so that, instead of a binding to the text,
///  you pass to it the text value, plua a `onCommit` callback with the result
///  of the edited text. You can then use this value to update the text's value.
///
///  The edited string is stored in the control's state. When the user has
///  finished editing, either by submitting (e.g., pressing the return key on macOS),
///  or by the TextField losing its focus, the new value is passed to the `onCommit`
///  callback.
///
///  Additionaly, if the activates the "exit command" (e.g., pressing the ESC key on macOS),
///  the editted value is discarded. This can be configured by using the `discardOnExitCommand`
///  modifier. The default behavior is equivalet to `.discardOnExitCommand(true)`.
///
///  The focus of the `TextFieldBindless` can additionally be controlled via the `focused` modifier.
///
///  Example usage:
///
///  ```swift
/// struct Example: View {
///
///         struct Item: Identifiable {
///             var id = UUID()
///             var name: String
///         }
///
///         @State var items: [Item] = [
///             "Arya Stark",
///             "Frodo Baggins",
///             "Harry Potter",
///             "Bilbo Baggins",
///             "Hermione Granger",
///             "Luke Skywalker",
///             "Katniss Everdeen",
///             "Sherlock Holmes",
///             "Elizabeth Bennet",
///             "Darth Vader",
///             "Gandalf",
///             "Jon Snow",
///             "Lara Croft",
///             "Frodo Baggins",
///             "Marty McFly",
///             "Elsa",
///             "James Bond",
///             "Walter White",
///             "Daenerys Targaryen",
///             "Indiana Jones"
///         ].map { Item(name: $0) }
///
///         @State var focusedItem: UUID?
///         @State var selectedItem: UUID?
///
///         var body: some View {
///             VStack {
///                 List(selection: $selectedItem) {
///                     ForEach($items) { $item in
///                         TextFieldBindless("", text: item.name, onCommit: { item.name = $0 })
///                             .discardOnExitCommand(true)
///                             .focused(focus: $focusedItem, equal: item.id)
///                     }
///                 }
///                 Button("Random Focus") {
///                     if let randomItem = items.randomElement() {
///                         print("Item = \(randomItem.name)")
///                         self.focusedItem = randomItem.id
///                     }
///
///                 }
///             }
///         }
///     }
///  ```
///
public struct TextFieldBindless<Label: View>: View {
    var label: () -> Label
    var text: String
    var onCommit: (String) -> Void

    var externalFocus: Binding<Bool>?

    var discardOnExitCommandFlag = true

    @FocusState private var focus: Bool
    @State private var editingText: String = ""
    @State private var isEditing = false

    public init(label: @escaping () -> Label, text: String, onCommit: @escaping (String) -> Void) {
        self.label = label
        self.text = text
        self.onCommit = onCommit
    }

    public init<S: StringProtocol>(_ labelText: S, text: String, onCommit: @escaping (String) -> Void) where Label == Text {
        label = { Text(labelText) }
        self.text = text
        self.onCommit = onCommit
    }
}

public extension TextFieldBindless {
    var body: some View {
        TextField(text: isEditing ? $editingText : .constant(text), label: { Text("\(focus.description)") })
            .focused($focus, equals: true)
        #if canImport(AppKit)
            .onExitCommand { escKeyHandler() }
        #endif
            .onAppear {
                if let externalFocus = externalFocus {
                    self.focus = externalFocus.wrappedValue
                }
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
                    // If we don't do this we get a flicker of the
                    // old value of `text` after the commit. This is
                    // because the value will only be updated after
                    // the focus has been updated, causing a small delay.
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        isEditing = false
                    }
                }
            }
            .onChange(of: externalFocus?.wrappedValue ?? false) {
                focus = $0
            }
            .onChange(of: focus) {
                if let externalFocus = externalFocus {
                    externalFocus.wrappedValue = $0
                }
            }
    }

    func escKeyHandler() {
        if discardOnExitCommandFlag {
            focus = false
            isEditing = false
        }
    }
}

public extension TextFieldBindless {
    /// Controls the focus of the `TextFieldBindless` control.
    func focused<FocusValueType: Hashable>(focus: Binding<FocusValueType?>, equal: FocusValueType) -> some View {
        TextFieldBindlessFocusable(content: self, focusValue: focus, focusEqual: equal)
    }
}

public extension TextFieldBindless {
    /// If called with `false`, will disable the default behavior of cancelling the current edit when the user
    /// issues an exit comment (e.g., by pressing the escape key on macOS).
    func discardOnExitCommand(_ value: Bool) -> Self {
        var result = self
        result.discardOnExitCommandFlag = value
        return result
    }
}

private struct TextFieldBindlessFocusable<Label: View, FocusValueType: Hashable>: View {
    let content: TextFieldBindless<Label>

    @Binding var focusValue: FocusValueType?
    var focusEqual: FocusValueType

    @State var isFocused = false

    public var body: some View {
        var result = content
        result.externalFocus = $isFocused
        return result
            .onAppear {
                isFocused = (focusValue == focusEqual)
            }
            .onChange(of: isFocused) {
                if $0 {
                    focusValue = focusEqual
                } else {
                    focusValue = nil
                }
            }
            .onChange(of: focusValue) {
                isFocused = ($0 == focusEqual)
            }
    }
}

struct TextFieldBindless_Previews: PreviewProvider {
    struct Inner: View {
        @State var first = "Hello,"
        @State var second = "World!"
        @State var firstFocus = true
        @State var secondFocus = true

        struct Item: Identifiable {
            var id = UUID()
            var name: String
        }

        @State var items: [Item] = [
            "Arya Stark",
            "Frodo Baggins",
            "Harry Potter",
            "Bilbo Baggins",
            "Hermione Granger",
            "Luke Skywalker",
            "Katniss Everdeen",
            "Sherlock Holmes",
            "Elizabeth Bennet",
            "Darth Vader",
            "Gandalf",
            "Jon Snow",
            "Lara Croft",
            "Frodo Baggins",
            "Marty McFly",
            "Elsa",
            "James Bond",
            "Walter White",
            "Daenerys Targaryen",
            "Indiana Jones",
        ].map { Item(name: $0) }

        @State var focusedItem: UUID?
        @State var selectedItem: UUID?

        var body: some View {
            VStack {
                List(selection: $selectedItem) {
                    ForEach($items) { $item in
                        TextFieldBindless("", text: item.name, onCommit: { item.name = $0 })
                            .discardOnExitCommand(true)
                            .focused(focus: $focusedItem, equal: item.id)
                    }
                }
                Button("Random Focus") {
                    if let randomItem = items.randomElement() {
                        print("Item = \(randomItem.name)")
                        self.focusedItem = randomItem.id
                    }
                }
            }
        }
    }

    static var previews: some View {
        Inner()
    }
}
