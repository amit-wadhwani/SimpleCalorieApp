#if DEBUG
import SwiftUI

struct FDCKeyWarningBanner: View {
    let apiKeyPresent: Bool
    
    var body: some View {
        if !apiKeyPresent {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                Text("FDC API key missing. Remote FoodRepository (FDC) will not work.")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.8))
        } else {
            EmptyView()
        }
    }
}
#endif

