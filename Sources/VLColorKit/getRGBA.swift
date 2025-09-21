#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

import UIKit

extension UIColor
{
 /// Extracts the RGBA components of the color.
 /// - Parameters:
 ///   - red: Output red component (0–1)
 ///   - green: Output green component (0–1)
 ///   - blue: Output blue component (0–1)
 ///   - alpha: Output alpha component (0–1)
 /// - Returns: True if extraction succeeded, false otherwise.
 @discardableResult
 @usableFromInline
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
 /// Extracts the RGBA components of the color.
 /// - Parameters:
 ///   - red: Output red component (0–1)
 ///   - green: Output green component (0–1)
 ///   - blue: Output blue component (0–1)
 ///   - alpha: Output alpha component (0–1)
 /// - Returns: True if extraction succeeded, false otherwise.
 @discardableResult
 @usableFromInline
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
