import SwiftUI

// Structs for Device Selection (Gadget -> Brand -> Model -> Problem)
struct SelectionViews: View {
    var title: String
    var items: [String]
    @Binding var selection: String?
    var onNext: () -> Void
    
    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Button(action: { selection = item; onNext() }) {
                    Text(item)
                }
            }
        }.navigationTitle(title)
    }
}
