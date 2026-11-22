#if os(iOS)
import Foundation
import Testing
import UIKit
@testable import SettingsFeature

@Suite struct AppIconPreviewTests {
    @Test(arguments: AppIconOption.allCases)
    func everyOptionHasAPreviewImage(_ option: AppIconOption) {
        #expect(UIImage(named: option.previewName, in: .module, with: nil) != nil)
    }
}
#endif
