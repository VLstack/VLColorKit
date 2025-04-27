import UIKit

extension UIColor
{
 public convenience init?(hex: String)
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

 public var relativeLuminance: CGFloat
 {
  var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
  getRed(&r, green: &g, blue: &b, alpha: &a)

  func adjust(_ value: CGFloat) -> CGFloat
  {
   return (value <= 0.03928) ? (value / 12.92) : pow((value + 0.055) / 1.055, 2.4)
  }

  let rl = adjust(r)
  let gl = adjust(g)
  let bl = adjust(b)

  return 0.2126 * rl + 0.7152 * gl + 0.0722 * bl
 }

 public func contrastRatio(with other: UIColor) -> CGFloat
 {
  let l1 = self.relativeLuminance
  let l2 = other.relativeLuminance

  return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)
 }

 public var isDark: Bool
 {
  let black = UIColor.black
  let white = UIColor.white

  let contrastWithBlack = self.contrastRatio(with: black)
  let contrastWithWhite = self.contrastRatio(with: white)

  if contrastWithBlack >= 7.0
  {
   return false
  }

  if contrastWithWhite >= 7.0
  {
   return true
  }

  return (contrastWithBlack > contrastWithWhite) ? false : true
 }

 public func toHex(prefixed: Bool = false,
                   includeAlpha: Bool = false,
                   fallback: String = "000000") -> String
 {
  guard let components = self.cgColor.components
  else { return prefixed ? "#" + fallback : fallback }

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
