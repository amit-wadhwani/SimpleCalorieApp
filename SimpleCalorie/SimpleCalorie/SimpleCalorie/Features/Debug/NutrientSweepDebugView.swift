#if DEBUG
import SwiftUI

struct NutrientSweepDebugView: View {
    @State private var isRunning = false
    @State private var statusMessage = ""
    @State private var result: NutrientNameSweepResult?
    
    private let repository: FoodDefinitionRepository
    
    init(repository: FoodDefinitionRepository) {
        self.repository = repository
    }
    
    var body: some View {
        Form {
            Section(header: Text("Provider Nutrient Sweep")) {
                Text("Sweeps FDC search and detail responses to collect all unique nutrient names. Results are saved to DebugOutput/Seed_NutrientNames_fdc.json")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Button(action: runSweep) {
                    HStack {
                        if isRunning {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isRunning ? "Running sweep..." : "Run Provider Nutrient Sweep (FDC)")
                    }
                }
                .disabled(isRunning)
                
                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundStyle(isRunning ? .secondary : .primary)
                }
            }
            
            if let result = result {
                Section(header: Text("Last Sweep Results")) {
                    LabeledContent("Provider", value: result.provider)
                    LabeledContent("Search Count", value: "\(result.searchCount)")
                    LabeledContent("Detail Count", value: "\(result.detailCount)")
                    LabeledContent("Unique Nutrients", value: "\(result.uniqueNutrientNames.count)")
                    LabeledContent("Date", value: result.dateGenerated.formatted(date: .abbreviated, time: .shortened))
                }
                
                Section(header: Text("Nutrient Names")) {
                    ForEach(result.uniqueNutrientNames.prefix(20), id: \.self) { name in
                        Text(name)
                            .font(.caption)
                    }
                    if result.uniqueNutrientNames.count > 20 {
                        Text("... and \(result.uniqueNutrientNames.count - 20) more")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Nutrient Sweep")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func runSweep() {
        isRunning = true
        statusMessage = "Starting sweep..."
        
        Task {
            do {
                let sweeper = NutrientNameSweeper(repository: repository)
                let sweepResult = try await sweeper.sweepFDC()
                
                await MainActor.run {
                    self.result = sweepResult
                    self.statusMessage = "✅ Sweep complete! Found \(sweepResult.uniqueNutrientNames.count) unique nutrient names."
                    self.isRunning = false
                }
            } catch {
                await MainActor.run {
                    self.statusMessage = "❌ Sweep failed: \(error.localizedDescription)"
                    self.isRunning = false
                }
            }
        }
    }
}
#endif

