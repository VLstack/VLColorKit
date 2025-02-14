import SwiftUI
import UIKit

public extension Color
{
 /// Initializes a color object from a hexadecimal string representation.
 ///
 /// - Parameter hex: A hexadecimal string representing the color.
 init(hex: String,
      fallback: UIColor = .black)
 {
  self.init(uiColor: UIColor(hex: hex) ?? fallback)
 }

 func toHex(prefixed: Bool = false,
            includeAlpha: Bool = false) -> String?
 {
  UIColor(self).toHex(prefixed: prefixed,
                      includeAlpha: includeAlpha)
 }

 /// Determines if the color is dark or light.
 ///
 /// - Returns: `true` if the color is considered dark, `false` otherwise.
 var isDarkColor: Bool
 {
  UIColor(self).isDarkColor
 }
 
 /// Provides a contrasting color based on the current color's brightness.
 ///
 /// If the current color is dark, returns a light color. If the current color is light, returns a dark color.
 ///
 /// - Returns: A contrasting color based on the brightness of the current color.
 var contrastingColor: Color
 {
  Color(uiColor: UIColor(self).contrastingColor)
 }
}
