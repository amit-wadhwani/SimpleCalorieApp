import XCTest
@testable import SimpleCalorie

final class FDCConfigTests: XCTestCase {
    
    func testFDCConfigDoesNotCrashWhenLoading() {
        // Just ensure we can call apiKey and it doesn't crash.
        _ = FDCClientConfig.shared.apiKey
    }
    
    func testFDCConfigHonorsEXPECTFlagForNonNilKey() {
        // Optional stricter assertion for local/dev runs.
        // If EXPECT_FDC_API_KEY=1 in env, assert we have a non-nil key.
        let expectKey = ProcessInfo.processInfo.environment["EXPECT_FDC_API_KEY"] == "1"
        if expectKey {
            let key = FDCClientConfig.shared.apiKey
            XCTAssertNotNil(key, "EXPECT_FDC_API_KEY=1 set but FDC API key is nil.")
        }
    }
}

