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
}
