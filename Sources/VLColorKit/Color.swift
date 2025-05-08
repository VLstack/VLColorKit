import SwiftUI
import UIKit

extension Color
{
 public init(hex: String,
             fallback: UIColor = .black)
 {
  self.init(uiColor: UIColor(hex: hex) ?? fallback)
 }

 public func toHex(prefixed: Bool = false,
                   includeAlpha: Bool = false,
                   fallback: String = "000000") -> String
 {
  UIColor(self).toHex(prefixed: prefixed,
                      includeAlpha: includeAlpha,
                      fallback: fallback)
 }

 public var isDark: Bool
 {
  UIColor(self).isDark
 }

 var complement: Color { Color(uiColor: UIColor(self).complement) }
 var splitComplement0: Color { Color(uiColor: UIColor(self).splitComplement0) }
 var splitComplement1: Color { Color(uiColor: UIColor(self).splitComplement1) }
 var triadic0: Color { Color(uiColor: UIColor(self).triadic0) }
 var triadic1: Color { Color(uiColor: UIColor(self).triadic1) }
 var tetradic0: Color { Color(uiColor: UIColor(self).tetradic0) }
 var tetradic1: Color { Color(uiColor: UIColor(self).tetradic1) }
 var tetradic2: Color { Color(uiColor: UIColor(self).tetradic2) }
 var analagous0: Color { Color(uiColor: UIColor(self).analagous0) }
 var analagous1: Color { Color(uiColor: UIColor(self).analagous0) }
}
