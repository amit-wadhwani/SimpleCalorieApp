import SwiftUI

struct CopyFromDateIcon: View {
    let baseColor: Color
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "calendar")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(baseColor)
            
            Circle()
                .fill(Color(uiColor: .systemBackground))
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .stroke(Color(uiColor: .systemBackground).opacity(0.8), lineWidth: 0.5)
                )
                .overlay(
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 7, weight: .semibold))
                        .foregroundColor(baseColor)
                )
                .offset(x: 2, y: 2)
        }
    }
}

#if DEBUG
struct CopyFromDateIcon_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            CopyFromDateIcon(baseColor: .orange)
            CopyFromDateIcon(baseColor: .blue)
            CopyFromDateIcon(baseColor: .green)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
#endif

