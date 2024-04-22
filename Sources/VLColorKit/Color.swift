import SwiftUI
import UIKit

public extension Color
{
 /// Initializes a color object from a hexadecimal string representation.
 ///
 /// - Parameter hex: A hexadecimal string representing the color.
 init(hex: String)
 {
  let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
  var int: UInt64 = 0
  Scanner(string: hex).scanHexInt64(&int)
  let a, r, g, b: UInt64
 
  switch hex.count
  {
   case 3:
    (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
   case 6:
    (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
   case 8:
    (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
   default:
    (a, r, g, b) = (0, 0, 0, 255)
  }

  self.init(.sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255)
 }
 
 /// Converts the color to a hexadecimal string representation.
 ///
 /// - Returns: A hexadecimal string representation of the color.
 var toHex: String
 {
  let fallback: String = "000000"
  let uic = UIColor(self)
  guard let components = uic.cgColor.components, components.count >= 3
  else { return fallback }

  let r = Float(components[0])
  let g = Float(components[1])
  let b = Float(components[2])
  var a = Float(1.0)

  if components.count >= 4 { a = Float(components[3]) }

  if a != Float(1.0)
  {
   return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
  }

  return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
 }
 
 // TODO: check if it is correct and better than current implement
 var toHexOptimizedToCheck: String
 {
  let components = UIColor(self).cgColor.components ?? []
  let red = UInt8(components.count > 0 ? components[0] * 255 : 0)
  let green = UInt8(components.count > 1 ? components[1] * 255 : 0)
  let blue = UInt8(components.count > 2 ? components[2] * 255 : 0)
  let alpha = UInt8(components.count > 3 ? components[3] * 255 : 255)
      
  if alpha == 255
  {
   return String(format: "%02X%02X%02X", red, green, blue)
  }
  
  return String(format: "%02X%02X%02X%02X", red, green, blue, alpha)
 }
 
 /// Converts the color to a hexadecimal string representation with a prefixed '#'.
 ///
 /// - Returns: A hexadecimal string representation of the color with a '#' prefix.
 // TODO: find a better name
 var toHexPrefixed: String
 {
  "#" + toHex
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
