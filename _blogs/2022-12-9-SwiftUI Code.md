---
layout: article
category: SwiftUI
---
```swift
import SwiftUI
//This is comment
struct ContentView: View {
    var a: Int = 1
    let str: String = "This is text." 
    var body: some View {
        VStack {
            Text(UIDevice.current.systemName)
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

```