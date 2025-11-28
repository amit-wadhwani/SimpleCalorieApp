import Foundation

/// Configuration for FDC API client, loading API key from secure sources
struct FDCClientConfig {
    static let shared = FDCClientConfig()
    
    /// Returns the FDC API key if available in Debug.secrets.plist or env var.
    var apiKey: String? {
        // 1) Allow override via environment variable (for CI or local experiments)
        if let envKey = ProcessInfo.processInfo.environment["FDC_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        
        // 2) Load from Debug.secrets.plist if present
        guard let url = Bundle.main.url(forResource: "Debug.secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else {
            return nil
        }
        
        guard let key = dict["FDC_API_KEY"] as? String, !key.isEmpty else {
            return nil
        }
        
        return key
    }
}

