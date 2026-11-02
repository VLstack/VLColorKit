#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension VLColor
{
 // MARK: - Private API
 @usableFromInline
 internal enum WCAG
 {
  @usableFromInline static let AA_small: CGFloat = 4.5
  @usableFromInline static let AA_large: CGFloat = 3.0
  @usableFromInline static let AAA_small: CGFloat = 7.0
  @usableFromInline static let AAA_large: CGFloat = 4.5
 }

 /// Brings a hue back into [0, 1), whatever its sign.
 /// - Parameter hue: Hue value, possibly negative or greater than 1.
 /// - Returns: Equivalent hue in [0, 1).
 @usableFromInline
 internal static func _normalizedHue(_ hue: CGFloat) -> CGFloat
 {
  var h = hue.truncatingRemainder(dividingBy: 1)
  if h < 0 { h += 1 }

  // A tiny negative hue plus 1 can round to exactly 1
  return h < 1 ? h : 0
 }

 /// Returns a copy of the color with the lightness component adjusted to `newLightness`.
 /// - Parameter newLightness: Desired lightness (0–1).
 /// - Returns: New `VLColor` with modified lightness, or `nil` if conversion to HSL fails.
 @usableFromInline
 internal func _adjustedLightness(to newLightness: CGFloat) -> VLColor?
 {
  guard let hsl = self.toHSL() else { return nil }

  return VLColor(hue: hsl.hue,
                 saturation: hsl.saturation,
                 lightness: newLightness,
                 alpha: hsl.alpha)
 }

 /// Returns the color with the best contrast above a threshold.
 /// - Parameters:
 ///   - threshold: Minimum contrast ratio to satisfy.
 ///   - colors: Candidate colors.
 /// - Returns: The color that meets or exceeds the threshold, or nil.
 @usableFromInline
 internal func _bestContrast(threshold: CGFloat,
                             colors: [ VLColor ]) -> VLColor?
 {
  self._findBest(threshold: threshold,
                 predicate: { contrastRatio(with: $0) },
                 colors: colors)
 }

 /// Returns the color with the maximum luminance difference from self above a threshold.
 /// - Parameters:
 ///   - threshold: Minimum luminance difference.
 ///   - colors: Candidate colors.
 /// - Returns: The color that meets or exceeds the luminance threshold, or nil.
 @usableFromInline
 internal func _bestLuminance(threshold: CGFloat,
                              colors: [ VLColor ]) -> VLColor?
 {
  let baseLuminance = self.luminance

  return self._findBest(threshold: threshold,
                        predicate: { abs($0.luminance - baseLuminance) },
                        colors: colors)
 }

 /// Finds the color that maximizes a given metric above a threshold.
 /// - Parameters:
 ///   - threshold: The minimum value required.
 ///   - predicate: Closure that computes the metric for a color.
 ///   - colors: Candidate colors.
 /// - Returns: The color with the best value above threshold, or nil.
 @usableFromInline
 internal func _findBest(threshold: CGFloat,
                         predicate: (VLColor) -> CGFloat,
                         colors: [ VLColor ]) -> VLColor?
 {
  var result: VLColor?
  var currentThreshold = threshold

  for color in colors
  {
   let value = predicate(color)
   if value >= currentThreshold
   {
    currentThreshold = value
    result = color
   }
  }

  return result
 }

 /// Returns a copy of the color with its hue shifted by `offset`.
 /// The hue is read from the sRGB components, and the result is brought back into [0, 1).
 /// - Parameter offset: Hue offset (0–1), may be negative.
 /// - Returns: New `VLColor` with adjusted hue, or the color itself if its components cannot be read.
 @usableFromInline
 internal func _withHue(offset: CGFloat) -> VLColor
 {
  var r: CGFloat = 0
  var g: CGFloat = 0
  var b: CGFloat = 0
  var a: CGFloat = 1

  guard self.getRGBA(&r, &g, &b, &a) else { return self }

  var h: CGFloat = 0
  var s: CGFloat = 0
  var v: CGFloat = 0
  var alpha: CGFloat = 1
  VLColor(red: r, green: g, blue: b, alpha: a).getHue(&h, saturation: &s, brightness: &v, alpha: &alpha)

  return VLColor(hue: VLColor._normalizedHue(h + offset), saturation: s, brightness: v, alpha: a)
 }


 // MARK: - Public API
 /// Initializes a color from a hex string.
 /// Supports 3, 6, or 8 character formats, with optional alpha first.
 /// - Parameters:
 ///   - hex: The hex string representation of the color (e.g. "#FF0000", "F00", "80FF0000").
 ///   - alphaFirst: If true and hex has 8 characters, the first byte is treated as alpha.
 /// - Returns: A VLColor instance, or nil if the string is invalid.
 public convenience init?(hex: String,
                          alphaFirst: Bool = false)
 {
  var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
  if hexString.hasPrefix("#") { hexString.removeFirst() }

  guard hexString.allSatisfy(\.isHexDigit) else { return nil }

  if hexString.count == 3
  {
   hexString = hexString.map { "\($0)\($0)" }.joined()
  }

  guard hexString.count == 6 || hexString.count == 8,
        let rgbValue = UInt64(hexString, radix: 16)
  else { return nil }

  let red, green, blue, alpha: UInt64
  if hexString.count == 6
  {
   red = (rgbValue >> 16) & 0xFF
   green = (rgbValue >> 8) & 0xFF
   blue = rgbValue & 0xFF
   alpha = 255
  }
  else if alphaFirst
  {
   alpha = (rgbValue >> 24) & 0xFF
   red = (rgbValue >> 16) & 0xFF
   green = (rgbValue >> 8) & 0xFF
   blue = rgbValue & 0xFF
  }
  else
  {
   red = (rgbValue >> 24) & 0xFF
   green = (rgbValue >> 16) & 0xFF
   blue = (rgbValue >> 8) & 0xFF
   alpha = rgbValue & 0xFF
  }

  self.init(red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255)
 }

 /// Initializes a color using HSL (Hue, Saturation, Lightness) components.
 /// - Parameters:
 ///   - hue: Hue value in [0,1]. Values outside this range, negative included, wrap around.
 ///   - saturation: Saturation value in [0,1].
 ///   - lightness: Lightness value in [0,1].
 ///   - alpha: Alpha value in [0,1].
 @inlinable
 public convenience init(hue: CGFloat,
                         saturation: CGFloat,
                         lightness: CGFloat,
                         alpha: CGFloat)
 {
  let h = VLColor._normalizedHue(hue)
  let s = max(0, min(saturation, 1))
  let l = max(0, min(lightness, 1))

  let c = (1 - abs(2 * l - 1)) * s
  let x = c * (1 - abs((h * 6).truncatingRemainder(dividingBy: 2) - 1))
  let m = l - c / 2

  let sector = h * 6
  var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
  if sector < 1 { (r, g, b) = (c, x, 0) }
  else if sector < 2 { (r, g, b) = (x, c, 0) }
  else if sector < 3 { (r, g, b) = (0, c, x) }
  else if sector < 4 { (r, g, b) = (0, x, c) }
  else if sector < 5 { (r, g, b) = (x, 0, c) }
  else { (r, g, b) = (c, 0, x) }

  self.init(red: r + m, green: g + m, blue: b + m, alpha: alpha)
 }

 /// Initializes a color using integer HSL values.
 /// - Parameters:
 ///   - hue: Hue in degrees [0,360]. Values outside this range, negative included, wrap around.
 ///   - saturation: Saturation in percent [0,100].
 ///   - lightness: Lightness in percent [0,100].
 ///   - alpha: Alpha value in [0,1].
 @inlinable
 public convenience init(hue: Int,
                         saturation: Int,
                         lightness: Int,
                         alpha: CGFloat)
 {
  self.init(hue: CGFloat(hue) / 360,
            saturation: CGFloat(saturation) / 100,
            lightness: CGFloat(lightness) / 100,
            alpha: alpha)
 }

 /// Returns a color suitable for text drawn on this color.
 /// Chooses the variant that provides the best contrast according to WCAG AAA.
 /// Falls back to black or white if no variant meets thresholds.
 @inlinable
 public var bestTextColor: VLColor
 {
  let variants = [
                  _adjustedLightness(to: 0.98),
                  _adjustedLightness(to: 0.25)
                 ].compactMap { $0 }

  return    _bestContrast(threshold: WCAG.AAA_small, colors: variants)
         ?? _bestContrast(threshold: WCAG.AAA_large, colors: variants)
         ?? _bestLuminance(threshold: 0.5, colors: variants)
         ?? _bestLuminance(threshold: 0.5, colors: [ .white, .black ])
         ?? .black
 }

 /// Returns the contrast ratio between this color and another color according to WCAG.
 /// - Parameter other: The other color to compare.
 /// - Returns: Contrast ratio (1.0 = no contrast, 21.0 = maximum contrast).
 @inlinable
 public func contrastRatio(with other: VLColor) -> CGFloat
 {
  let l1 = self.luminance
  let l2 = other.luminance

  return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)
 }

 /// Determines whether the color is "dark" based on contrast with black and white.
 /// Returns true if white text would have at least as much contrast as black text.
 @inlinable
 public var isDark: Bool
 {
  self.contrastRatio(with: .white) >= self.contrastRatio(with: .black)
 }

 /// Computes the relative luminance of the color according to WCAG, from its sRGB components.
 /// Returns 0 for black and 1 for white.
 /// Returns 1 if the components cannot be read (pattern colors, for example).
 @inlinable
 public var luminance: CGFloat
 {
  var r: CGFloat = 0
  var g: CGFloat = 0
  var b: CGFloat = 0
  var a: CGFloat = 1

  guard self.getRGBA(&r, &g, &b, &a) else { return 1 }

  func map(_ v: CGFloat) -> CGFloat
  {
   return (v <= 0.04045) ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
  }

  let rl = map(r)
  let gl = map(g)
  let bl = map(b)

  return 0.2126 * rl + 0.7152 * gl + 0.0722 * bl
 }

 /// Returns the hexadecimal string representation of the color, in the sRGB color space.
 /// Display P3 or extended sRGB colors are converted to sRGB first.
 /// Returns a fallback string if conversion fails.
 /// - Parameters:
 ///   - prefixed: If true, adds a "#" at the beginning.
 ///   - includeAlpha: If true, appends the alpha component to the hex string.
 ///   - fallback: String to return if conversion fails (default "000000").
 /// - Returns: Hexadecimal color string (e.g. "#FF0000" or "#FF000080").
 @inlinable
 public func toHex(prefixed: Bool = false,
                   includeAlpha: Bool = false,
                   fallback: String = "000000") -> String
 {
  var r: CGFloat = 0
  var g: CGFloat = 0
  var b: CGFloat = 0
  var a: CGFloat = 1

  guard self.getRGBA(&r, &g, &b, &a)
  else { return prefixed ? "#" + fallback : fallback }

  func byte(_ value: CGFloat) -> Int
  {
   Int((value * 255).rounded())
  }

  let hexString: String
  if includeAlpha
  {
   hexString = String(format: "%02X%02X%02X%02X", byte(r), byte(g), byte(b), byte(a))
  }
  else
  {
   hexString = String(format: "%02X%02X%02X", byte(r), byte(g), byte(b))
  }

  return prefixed ? "#" + hexString : hexString
 }

 /// Converts the color to HSL representation, from its sRGB components.
 /// - Returns: A tuple containing hue (0–1), saturation (0–1), lightness (0–1), and alpha (0–1),
 ///            or `nil` if the color cannot provide RGBA components.
 public func toHSL() -> (hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat)?
 {
  var r: CGFloat = 0
  var g: CGFloat = 0
  var b: CGFloat = 0
  var a: CGFloat = 0

  guard self.getRGBA(&r, &g, &b, &a)
  else { return nil }

  let maxVal = max(r, g, b)
  let minVal = min(r, g, b)
  let delta = maxVal - minVal

  var h: CGFloat = 0
  var s: CGFloat = 0
  let l: CGFloat = (maxVal + minVal) / 2

  if delta != 0
  {
   s = delta / (1 - abs(2 * l - 1))

   if maxVal == r
   {
    h = (g - b) / delta
    if g < b { h += 6 }
   }
   else if maxVal == g
   {
    h = (b - r) / delta + 2
   }
   else
   {
    h = (r - g) / delta + 4
   }

   h /= 6
  }

  return (hue: h, saturation: s, lightness: l, alpha: a)
 }

 /// Returns the complementary color (opposite hue).
 @inlinable
 public var complement: VLColor { self._withHue(offset: 0.5) }

 /// Returns the first split-complementary color (150° hue offset).
 @inlinable
 public var splitComplement0: VLColor { self._withHue(offset: 150 / 360) }

 /// Returns the second split-complementary color (210° hue offset).
 @inlinable
 public var splitComplement1: VLColor { self._withHue(offset: 210 / 360) }

 /// Returns the first triadic color (120° hue offset).
 @inlinable
 public var triadic0: VLColor { self._withHue(offset: 120 / 360) }

 /// Returns the second triadic color (240° hue offset).
 @inlinable
 public var triadic1: VLColor { self._withHue(offset: 240 / 360) }

 /// Returns the first tetradic color (90° hue offset, i.e., 0.25 in 0–1 scale).
 @inlinable
 public var tetradic0: VLColor { self._withHue(offset: 0.25) }

 /// Returns the second tetradic color (the complementary color).
 @inlinable
 public var tetradic1: VLColor { self.complement }

 /// Returns the third tetradic color (270° hue offset, i.e., 0.75 in 0–1 scale).
 @inlinable
 public var tetradic2: VLColor { self._withHue(offset: 0.75) }

 /// Returns the first analogous color (30° counter-clockwise hue offset, i.e., -1/12).
 @inlinable
 public var analogous0: VLColor { self._withHue(offset: -1 / 12) }

 /// Returns the second analogous color (30° clockwise hue offset, i.e., 1/12).
 @inlinable
 public var analogous1: VLColor { self._withHue(offset: 1 / 12) }
}
