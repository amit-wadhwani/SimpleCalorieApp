import SwiftUI

enum AppFont {
    static func title(_ size: CGFloat = 20) -> Font { .system(size: size, weight: .semibold) }      // token: global/typography/title
    static func titleSm(_ size: CGFloat = 16) -> Font { .system(size: size, weight: .semibold) }    // token: global/typography/titleSm
    static func bodySm(_ size: CGFloat = 13) -> Font { .system(size: size, weight: .regular) }      // token: global/typography/bodySm
    static func bodySmSmall(_ size: CGFloat = 12) -> Font { .system(size: size, weight: .regular) } // token: global/typography/bodySm
    static func label(_ size: CGFloat = 16) -> Font { .system(size: size, weight: .semibold) }      // token: global/typography/label
    static func labelCapsSm(_ size: CGFloat = 11) -> Font { .system(size: size, weight: .medium) }  // token: global/typography/labelCapsSm
    static func captionXs(_ size: CGFloat = 10) -> Font { .system(size: size, weight: .regular) }   // token: global/typography/captionXs
    static func section(_ size: CGFloat = 13) -> Font { .system(size: size, weight: .medium) }      // token: global/typography/label
    static func value(_ size: CGFloat = 14) -> Font { .system(size: size, weight: .semibold) }       // token: global/typography/value
}

