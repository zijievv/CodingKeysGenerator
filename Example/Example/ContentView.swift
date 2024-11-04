import CodingKeysGenerator
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

@CodingKeys(style: .kebabCased)
struct Entity {
    @CodingKey(custom: "entity_id")
    let id: String
    let currentValue: Int
    let count: Int
    let `protocol`: String
    @CodingKeyIgnored
    let foo: Bool
}
