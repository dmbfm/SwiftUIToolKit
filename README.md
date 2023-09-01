# SwiftUIToolKit

This is my personal SwiftUI Toolkit. This is a growing library that will contain custo components, modifiers, etc., 
that I will write as needed.

# Components 

## TextFieldBindless

A bindless `TextField`. Its a wrapper around the regular `TextField` that uses a callback closure to 
modify the input value instead of a binding. 

The default behavior of this component is to discard an edit on exit command (i.e., when the ESC key is pressed on macOS).
To disable this, use the `disableDiscardOnExitCommand` modifier.

Example usage:

```swift
struct Example: View {
    @State var first = "Hello,"
    @State var second = "World!"
    var body: some View {
        List {
            TextFieldBindless("Hello", text: first) { first = $0 }                
            TextFieldBindless("World", text: second) { second = $0 }
                .disableDiscardOnExitCommand()
        }
    }
}
```

