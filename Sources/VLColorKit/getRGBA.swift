#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit

extension UIColor
{
 internal func getRGBA(_ red: inout CGFloat,
                       _ green: inout CGFloat,
                       _ blue: inout CGFloat,
                       _ alpha: inout CGFloat) -> Bool
 {
  return self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
 }
}

#elseif os(macOS)

import AppKit

extension NSColor
{
 internal func getRGBA(_ red: inout CGFloat,
                       _ green: inout CGFloat,
                       _ blue: inout CGFloat,
                       _ alpha: inout CGFloat) -> Bool
 {
  let converted = self.usingColorSpace(.deviceRGB)
  guard let rgbColor = converted else { return false }

  rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

  return true
 }
}

#endif
