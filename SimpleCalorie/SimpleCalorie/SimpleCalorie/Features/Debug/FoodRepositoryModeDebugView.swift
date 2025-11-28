#if DEBUG
import SwiftUI

struct FoodRepositoryModeDebugView: View {
    @State private var selectedMode: FoodRepositoryMode = FoodRepositoryModeSetting.current()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Food Repository Mode")) {
                Text("Choose how the app fetches food data. Changes require app restart to take full effect.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Picker("Mode", selection: $selectedMode) {
                    Text("Local only").tag(FoodRepositoryMode.localOnly)
                    Text("Remote only (FDC)").tag(FoodRepositoryMode.remoteOnly)
                    Text("Caching (Local + Remote)").tag(FoodRepositoryMode.caching)
                }
                .pickerStyle(.inline)
            }
            
            Section {
                Button("Save") {
                    FoodRepositoryModeSetting.set(mode: selectedMode)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
            }
            
            Section(header: Text("Current Mode")) {
                Text(currentModeDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Food Repo Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var currentModeDescription: String {
        switch FoodRepositoryModeSetting.current() {
        case .localOnly:
            return "Using local seed data only (offline-friendly)"
        case .remoteOnly:
            return "Using FDC API only (requires network)"
        case .caching:
            return "Using local + FDC with in-memory cache"
        }
    }
}
#endif

