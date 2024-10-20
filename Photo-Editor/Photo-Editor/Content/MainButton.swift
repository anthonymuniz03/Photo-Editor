import SwiftUI

struct MainButton: View {
    var body: some View {
            Button(action: {
                print("This is my action")
            }, label: {
                Image(systemName: "plus.circle")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundStyle(Color.gray)
                    .padding(120)
            })
            .buttonStyle(.bordered)
            .accessibilityLabel("selectLibraryImage")
    }
}

#Preview {
    MainButton()
}
