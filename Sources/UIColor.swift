import UIKit

public extension UIColor
{
 convenience init?(hex: String)
 {
  var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
  if hexString.hasPrefix("#") { hexString.removeFirst() }

  let scanner = Scanner(string: hexString)

  var rgbValue: UInt64 = 0
  guard scanner.scanHexInt64(&rgbValue) else { return nil }

  var red, green, blue, alpha: UInt64
  switch hexString.count
  {
   case 6:
    red = (rgbValue >> 16)
    green = (rgbValue >> 8 & 0xFF)
    blue = (rgbValue & 0xFF)
    alpha = 255

   case 8:
    red = (rgbValue >> 16)
    green = (rgbValue >> 8 & 0xFF)
    blue = (rgbValue & 0xFF)
    alpha = rgbValue >> 24

   default:
    return nil
  }

  self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(alpha) / 255)
 }

 /// Provides a contrasting color based on the current color's brightness.
 ///
 /// - Returns: A contrasting color (`UIColor.white` or `UIColor.black`) based on the brightness of the current color.
 var contrastingColor: UIColor
 {
  self.isDarkColor ? .white : .black
 }

 /// Determines if the color is dark or light based on its luminance.
 ///
 /// - Returns: `true` if the color is considered dark, `false` otherwise.
 var isDarkColor: Bool
 {
  var r, g, b, a: CGFloat
  (r, g, b, a) = (0, 0, 0, 0)
  self.getRed(&r, green: &g, blue: &b, alpha: &a)
  let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b

  return lum < 0.5
 }

 func toHex(prefixed: Bool = false,
            includeAlpha: Bool = false) -> String?
 {
  guard let components = self.cgColor.components else { return nil }

  let red = Int(components[0] * 255.0)
  let green = Int(components[1] * 255.0)
  let blue = Int(components[2] * 255.0)

  let hexString: String
  if includeAlpha,
     let alpha = components.last
  {
   let alphaValue = Int(alpha * 255.0)
   hexString = String(format: "%02X%02X%02X%02X", red, green, blue, alphaValue)
  }
  else
  {
   hexString = String(format: "%02X%02X%02X", red, green, blue)
  }

  return prefixed ? "#" + hexString : hexString
 }
}
