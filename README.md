# SwiftUIToolKit

This is my personal SwiftUI Toolkit. This is a growing library that will contain custo components, modifiers, etc.,
that I will write as needed.

# Components

## TextFieldBindless

This control wraps a `TextField` so that, instead of a binding to the text,
you pass to it the text value, plua a `onCommit` callback with the result
of the edited text. You can then use this value to update the text's value.

The edited string is stored in the control's state. When the user has
finished editing, either by submitting (e.g., pressing the return key on macOS),
or by the TextField losing its focus, the new value is passed to the `onCommit`
callback.

Additionaly, if the activates the "exit command" (e.g., pressing the ESC key on macOS),
the editted value is discarded. This can be configured by using the `discardOnExitCommand`
modifier. The default behavior is equivalet to `.discardOnExitCommand(true)`.

The focus of the `TextFieldBindless` can additionally be controlled via the `focused` modifier.

Example usage:

```swift
struct Example: View {

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
           "Indiana Jones"
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
```
