#if DEBUG
import SwiftUI

struct FoodRepositoryDiagnosticsView: View {
    let repository: FoodDefinitionRepository
    
    @State private var query: String = "chicken"
    @State private var results: [FoodDefinition] = []
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Food Repository Diagnostics")
                .font(.headline)
                .padding(.bottom, 8)
            
            TextField("Search query", text: $query)
                .textFieldStyle(.roundedBorder)
            
            Button("Run search") {
                Task {
                    isLoading = true
                    do {
                        errorMessage = nil
                        results = try await repository.searchFoods(query: query, limit: 10)
                    } catch {
                        errorMessage = String(describing: error)
                        results = []
                    }
                    isLoading = false
                }
            }
            .disabled(isLoading)
            
            if isLoading {
                ProgressView()
                    .padding()
            }
            
            if let errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }
            
            if !results.isEmpty {
                Text("Results: \(results.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            List(results, id: \.id) { food in
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    if let brand = food.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("\(Int(food.serving.amount))\(food.serving.unit)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .navigationTitle("Food Repository")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif

