import UIKit

public extension UIColor
{
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
    
 /// Provides a contrasting color based on the current color's brightness.
 ///
 /// - Returns: A contrasting color (`UIColor.white` or `UIColor.black`) based on the brightness of the current color.
 var contrastingColor: UIColor
 {
  self.isDarkColor ? .white : .black
 }
}
