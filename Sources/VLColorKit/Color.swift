import SwiftUI

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

import UIKit
extension Color
{
 public init(vlColor color: UIColor)
 {
  self.init(uiColor: color)
 }
}

#elseif os(macOS)

import AppKit
extension Color
{
 public init(vlColor color: NSColor)
 {
  self.init(nsColor: color)
 }
}

#endif

extension Color
{
 public init(hex: String,
             alphaFirst: Bool = false,
             fallback: VLColor = .black)
 {
  self.init(vlColor: VLColor(hex: hex, alphaFirst: alphaFirst) ?? fallback)
 }

 public var bestTextColor: Color
 {
  Color(vlColor: VLColor(self).bestTextColor)
 }

 public var luminance: CGFloat
 {
  VLColor(self).luminance
 }

 public func toHex(prefixed: Bool = false,
                   includeAlpha: Bool = false,
                   fallback: String = "000000") -> String
 {
  VLColor(self).toHex(prefixed: prefixed,
                      includeAlpha: includeAlpha,
                      fallback: fallback)
 }

 public func toHSL() -> (hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat)?
 {
  VLColor(self).toHSL()
 }

 public var isDark: Bool
 {
  VLColor(self).isDark
 }

 public var complement: Color { Color(vlColor: VLColor(self).complement) }
 public var splitComplement0: Color { Color(vlColor: VLColor(self).splitComplement0) }
 public var splitComplement1: Color { Color(vlColor: VLColor(self).splitComplement1) }
 public var triadic0: Color { Color(vlColor: VLColor(self).triadic0) }
 public var triadic1: Color { Color(vlColor: VLColor(self).triadic1) }
 public var tetradic0: Color { Color(vlColor: VLColor(self).tetradic0) }
 public var tetradic1: Color { Color(vlColor: VLColor(self).tetradic1) }
 public var tetradic2: Color { Color(vlColor: VLColor(self).tetradic2) }
 public var analagous0: Color { Color(vlColor: VLColor(self).analagous0) }
 public var analagous1: Color { Color(vlColor: VLColor(self).analagous1) }
}
