#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension VLColor
{
 /// Extracts the RGBA components of the color, converted to the sRGB color space.
 /// Display P3 or extended sRGB colors are converted, then each component is clamped to 0–1.
 /// - Parameters:
 ///   - red: Output red component (0–1)
 ///   - green: Output green component (0–1)
 ///   - blue: Output blue component (0–1)
 ///   - alpha: Output alpha component (0–1)
 /// - Returns: True if extraction succeeded, false otherwise (pattern colors, for example).
 @discardableResult
 @usableFromInline
 internal func getRGBA(_ red: inout CGFloat,
                       _ green: inout CGFloat,
                       _ blue: inout CGFloat,
                       _ alpha: inout CGFloat) -> Bool
 {
  guard let sRGB = CGColorSpace(name: CGColorSpace.sRGB),
        let converted = self.cgColor.converted(to: sRGB, intent: .relativeColorimetric, options: nil),
        let components = converted.components,
        components.count == 4
  else { return false }

  func clamped(_ value: CGFloat) -> CGFloat
  {
   min(max(value, 0), 1)
  }

  red = clamped(components[0])
  green = clamped(components[1])
  blue = clamped(components[2])
  alpha = clamped(components[3])

  return true
 }
}
