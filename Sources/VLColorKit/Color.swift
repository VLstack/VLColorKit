import SwiftUI

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

import UIKit
extension Color
{
 /// Initializes a SwiftUI Color from a VLColor (UIKit UIColor variant).
 /// - Parameter color: The VLColor (alias for UIColor on iOS/tvOS/watchOS/visionOS) to convert.
 @inlinable
 public init(vlColor color: UIColor)
 {
  self.init(uiColor: color)
 }
}

#elseif os(macOS)

import AppKit
extension Color
{
 /// Initializes a SwiftUI Color from a VLColor (AppKit NSColor variant).
 /// - Parameter color: The VLColor (alias for NSColor on macOS) to convert.
 @inlinable
 public init(vlColor color: NSColor)
 {
  self.init(nsColor: color)
 }
}

#endif

extension Color
{
 // MARK: - Public API
 /// Initializes a SwiftUI Color from a hex string.
 /// Supports 3, 6, or 8 character formats.
 /// - Parameters:
 ///   - hex: Hexadecimal string representing the color (e.g. "#FF0000", "F00", "80FF0000").
 ///   - alphaFirst: If true and hex has 8 characters, the first byte is interpreted as alpha.
 ///   - fallback: Color to use if the hex string is invalid (default: black).
 @inlinable
 public init(hex: String,
             alphaFirst: Bool = false,
             fallback: VLColor = .black)
 {
  self.init(vlColor: VLColor(hex: hex, alphaFirst: alphaFirst) ?? fallback)
 }

 /// Returns the color that provides the best contrast for text drawn on this background.
 /// Uses the VLColor.bestTextColor logic (WCAG AAA standard).
 /// - Returns: A Color suitable for text on this background.
 @inlinable
 public var bestTextColor: Color
 {
  Color(vlColor: VLColor(self).bestTextColor)
 }

 /// Returns the color that provides the best contrast for text drawn on this background.
 /// Uses the VLColor.bestTextColor logic (WCAG AAA standard).
 /// - Returns: A Color suitable for text on this background.
 @inlinable
 public var luminance: CGFloat
 {
  VLColor(self).luminance
 }

 /// Returns a hexadecimal string representing this color.
 /// - Parameters:
 ///   - prefixed: If true, adds "#" at the beginning (default: false).
 ///   - includeAlpha: If true, includes alpha component (default: false).
 ///   - fallback: String to return if conversion fails (default: "000000").
 /// - Returns: Hex string of the color (e.g. "#FF0000" or "#80FF0000").
 @inlinable
 public func toHex(prefixed: Bool = false,
                   includeAlpha: Bool = false,
                   fallback: String = "000000") -> String
 {
  VLColor(self).toHex(prefixed: prefixed,
                      includeAlpha: includeAlpha,
                      fallback: fallback)
 }

 /// Converts the color to HSL representation.
 /// - Returns: Tuple with hue (0–1), saturation (0–1), lightness (0–1), alpha (0–1), or nil if conversion fails.
 @inlinable
 public func toHSL() -> (hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat)?
 {
  VLColor(self).toHSL()
 }

 /// Determines whether this color is considered "dark".
 /// Returns true if white text would provide better contrast.
 @inlinable
 public var isDark: Bool
 {
  VLColor(self).isDark
 }

 /// Returns the complementary color (opposite hue).
 @inlinable
 public var complement: Color { Color(vlColor: VLColor(self).complement) }

 /// Returns the first split-complementary color (150° hue offset).
 @inlinable
 public var splitComplement0: Color { Color(vlColor: VLColor(self).splitComplement0) }

 /// Returns the second split-complementary color (210° hue offset).
 @inlinable
 public var splitComplement1: Color { Color(vlColor: VLColor(self).splitComplement1) }

 /// Returns the first triadic color (120° hue offset).
 @inlinable
 public var triadic0: Color { Color(vlColor: VLColor(self).triadic0) }

 /// Returns the second triadic color (240° hue offset).
 @inlinable
 public var triadic1: Color { Color(vlColor: VLColor(self).triadic1) }

 /// Returns the first tetradic color (90° hue offset, i.e., 0.25 in 0–1 scale).
 @inlinable
 public var tetradic0: Color { Color(vlColor: VLColor(self).tetradic0) }

 /// Returns the second tetradic color (the complementary color).
 @inlinable
 public var tetradic1: Color { Color(vlColor: VLColor(self).tetradic1) }

 /// Returns the third tetradic color (270° hue offset, i.e., 0.75 in 0–1 scale).
 @inlinable
 public var tetradic2: Color { Color(vlColor: VLColor(self).tetradic2) }

 /// Returns the first analogous color (30° counter-clockwise hue offset, i.e., -1/12).
 @inlinable
 public var analogous0: Color { Color(vlColor: VLColor(self).analogous0) }

 /// Returns the second analogous color (30° clockwise hue offset, i.e., 1/12).
 @inlinable
 public var analogous1: Color { Color(vlColor: VLColor(self).analogous1) }

 // MARK: - Deprecated API
 @available(*, deprecated, renamed: "analogous0", message: "Typo, use .analogous0 instead")
 public var analagous0: Color { self.analogous0 }

 @available(*, deprecated, renamed: "analogous1", message: "Typo, use .analogous1 instead")
 public var analagous1: Color { self.analogous1 }
}
