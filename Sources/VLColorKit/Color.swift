import SwiftUI
import UIKit

extension Color
{
 public init(hex: String,
             fallback: UIColor = .black)
 {
  self.init(uiColor: UIColor(hex: hex) ?? fallback)
 }

 public var bestTextColor: Color
 {
  Color(uiColor: UIColor(self).bestTextColor)
 }

 public var luminance: CGFloat
 {
  UIColor(self).luminance
 }

 public func toHex(prefixed: Bool = false,
                   includeAlpha: Bool = false,
                   fallback: String = "000000") -> String
 {
  UIColor(self).toHex(prefixed: prefixed,
                      includeAlpha: includeAlpha,
                      fallback: fallback)
 }

 public func toHSL() -> (hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat)?
 {
  UIColor(self).toHSL()
 }

 public var isDark: Bool
 {
  UIColor(self).isDark
 }

 public var complement: Color { Color(uiColor: UIColor(self).complement) }
 public var splitComplement0: Color { Color(uiColor: UIColor(self).splitComplement0) }
 public var splitComplement1: Color { Color(uiColor: UIColor(self).splitComplement1) }
 public var triadic0: Color { Color(uiColor: UIColor(self).triadic0) }
 public var triadic1: Color { Color(uiColor: UIColor(self).triadic1) }
 public var tetradic0: Color { Color(uiColor: UIColor(self).tetradic0) }
 public var tetradic1: Color { Color(uiColor: UIColor(self).tetradic1) }
 public var tetradic2: Color { Color(uiColor: UIColor(self).tetradic2) }
 public var analagous0: Color { Color(uiColor: UIColor(self).analagous0) }
 public var analagous1: Color { Color(uiColor: UIColor(self).analagous0) }
}
