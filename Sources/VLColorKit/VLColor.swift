#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension VLColor
{
 // MARK: - Private API
 private enum WCAG
 {
  static let AA_small: CGFloat = 4.5
  static let AA_large: CGFloat = 3.0
  static let AAA_small: CGFloat = 7.0
  static let AAA_large: CGFloat = 4.5
 }

 /// Returns a copy of the color with the lightness component adjusted to `newLightness`.
 /// - Parameter newLightness: Desired lightness (0–1).
 /// - Returns: New `VLColor` with modified lightness, or `nil` if conversion to HSL fails.
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
 /// - Parameter offset: Hue offset (0–1), modulo 1 is applied.
 /// - Returns: New `VLColor` with adjusted hue.
 internal func _withHue(offset: CGFloat) -> VLColor
 {
  var color = self
#if os(macOS)
  if let rgb = color.usingColorSpace(.deviceRGB)
  {
   color = rgb
  }
#endif
  var h: CGFloat = 0
  var s: CGFloat = 0
  var b: CGFloat = 0
  var a: CGFloat = 0
  color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

  return VLColor(hue: fmod(h + offset, 1), saturation: s, brightness: b, alpha: a)
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

  if hexString.count == 3
  {
   let r = String(repeating: hexString[hexString.startIndex], count: 2)
   let g = String(repeating: hexString[hexString.index(hexString.startIndex, offsetBy: 1)], count: 2)
   let b = String(repeating: hexString[hexString.index(hexString.startIndex, offsetBy: 2)], count: 2)
   hexString = r + g + b
  }

  let scanner = Scanner(string: hexString)

  var rgbValue: UInt64 = 0
  guard scanner.scanHexInt64(&rgbValue) else { return nil }

  let red, green, blue, alpha: UInt64
  switch hexString.count
  {
   case 6:
    red = (rgbValue >> 16) & 0xFF
    green = (rgbValue >> 8) & 0xFF
    blue = rgbValue & 0xFF
    alpha = 255

   case 8:
    if alphaFirst
    {
     alpha   = (rgbValue >> 24) & 0xFF
     red = (rgbValue >> 16) & 0xFF
     green  = (rgbValue >> 8) & 0xFF
     blue = rgbValue & 0xFF
    }
    else
    {
     red   = (rgbValue >> 24) & 0xFF
     green = (rgbValue >> 16) & 0xFF
     blue  = (rgbValue >> 8) & 0xFF
     alpha = rgbValue & 0xFF
    }

   default:
    return nil
  }

  self.init(red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255)
 }

 /// Initializes a color using HSL (Hue, Saturation, Lightness) components.
 /// - Parameters:
 ///   - hue: Hue value in [0,1].
 ///   - saturation: Saturation value in [0,1].
 ///   - lightness: Lightness value in [0,1].
 ///   - alpha: Alpha value in [0,1].
 public convenience init(hue: CGFloat,
                         saturation: CGFloat,
                         lightness: CGFloat,
                         alpha: CGFloat)
 {
  let h = hue
  let s = saturation
  let l = lightness

  let c = (1 - abs(2 * l - 1)) * s
  let x = c * (1 - abs((h * 6).truncatingRemainder(dividingBy: 2) - 1))
  let m = l - c / 2

  var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0

  switch h * 6
  {
   case 0..<1: (r, g, b) = (c, x, 0)
   case 1..<2: (r, g, b) = (x, c, 0)
   case 2..<3: (r, g, b) = (0, c, x)
   case 3..<4: (r, g, b) = (0, x, c)
   case 4..<5: (r, g, b) = (x, 0, c)
   case 5..<6: (r, g, b) = (c, 0, x)
   default:    (r, g, b) = (0, 0, 0)
  }

  self.init(red: r + m, green: g + m, blue: b + m, alpha: alpha)
 }

 /// Initializes a color using integer HSL values.
 /// - Parameters:
 ///   - hue: Hue in degrees [0,360].
 ///   - saturation: Saturation in percent [0,100].
 ///   - lightness: Lightness in percent [0,100].
 ///   - alpha: Alpha value in [0,1].
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

 /// Computes the relative luminance of the color according to WCAG.
 /// Returns 0 for black and 1 for white.
 /// Uses linearized RGB components.
 public var luminance: CGFloat
 {
  var r: CGFloat = 0
  var g: CGFloat = 0
  var b: CGFloat = 0
  var a: CGFloat = 1

  guard self.getRGBA(&r, &g, &b, &a) else { return 1 }

  func map(_ v: CGFloat) -> CGFloat
  {
   return (v <= 0.03928) ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
  }

  let rl = map(r)
  let gl = map(g)
  let bl = map(b)

  return 0.2126 * rl + 0.7152 * gl + 0.0722 * bl
 }

 /// Returns the contrast ratio between this color and another color according to WCAG.
 /// - Parameter other: The other color to compare.
 /// - Returns: Contrast ratio (1.0 = no contrast, 21.0 = maximum contrast).
 public func contrastRatio(with other: VLColor) -> CGFloat
 {
  let l1 = self.luminance
  let l2 = other.luminance

  return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)
 }

 /// Determines whether the color is "dark" based on contrast with black and white.
 /// Returns true if white text would have better contrast.
 public var isDark: Bool
 {
  let black = VLColor.black
  let white = VLColor.white

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

 /// Returns the hexadecimal string representation of the color.
 /// Supports RGB and monochrome colors. Returns a fallback string if conversion fails.
 /// - Parameters:
 ///   - prefixed: If true, adds a "#" at the beginning.
 ///   - includeAlpha: If true, appends the alpha component to the hex string.
 ///   - fallback: String to return if conversion fails (default "000000").
 /// - Returns: Hexadecimal color string (e.g. "#FF0000" or "#80FF0000").
 public func toHex(prefixed: Bool = false,
                   includeAlpha: Bool = false,
                   fallback: String = "000000") -> String
 {
#if os(macOS)
  guard let rgbColor = self.usingColorSpace(.deviceRGB),
        let components = rgbColor.cgColor.components
  else { return prefixed ? "#" + fallback : fallback }
#else
  guard let components = self.cgColor.components
  else { return prefixed ? "#" + fallback : fallback }
#endif

  let colorSpaceModel = self.cgColor.colorSpace?.model

  var red: Int = 0
  var green: Int = 0
  var blue: Int = 0
  var alpha: Int = 255

  switch colorSpaceModel
  {
   case .monochrome:
    let gray = Int(components[0] * 255.0)
    red = gray
    green = gray
    blue = gray
    if components.count > 1 { alpha = Int(components[1] * 255.0) }

   case .rgb:
    if components.count >= 3
    {
     red = Int(components[0] * 255.0)
     green = Int(components[1] * 255.0)
     blue = Int(components[2] * 255.0)
    }
    if components.count >= 4
    {
     alpha = Int(components[3] * 255.0)
    }

   default:
    return prefixed ? "#" + fallback : fallback
  }

  let hexString: String
  if includeAlpha
  {
   hexString = String(format: "%02X%02X%02X%02X", red, green, blue, alpha)
  }
  else
  {
   hexString = String(format: "%02X%02X%02X", red, green, blue)
  }

  return prefixed ? "#" + hexString : hexString
 }

 /// Converts the color to HSL representation.
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
 public var complement: VLColor { self._withHue(offset: 0.5) }

 /// Returns the first split-complementary color (150° hue offset).
 public var splitComplement0: VLColor { self._withHue(offset: 150 / 360) }

 /// Returns the second split-complementary color (210° hue offset).
 public var splitComplement1: VLColor { self._withHue(offset: 210 / 360) }

 /// Returns the first triadic color (120° hue offset).
 public var triadic0: VLColor { self._withHue(offset: 120 / 360) }

 /// Returns the second triadic color (240° hue offset).
 public var triadic1: VLColor { self._withHue(offset: 240 / 360) }

 /// Returns the first tetradic color (90° hue offset, i.e., 0.25 in 0–1 scale).
 public var tetradic0: VLColor { self._withHue(offset: 0.25) }

 /// Returns the second tetradic color (the complementary color).
 public var tetradic1: VLColor { self.complement }

 /// Returns the third tetradic color (270° hue offset, i.e., 0.75 in 0–1 scale).
 public var tetradic2: VLColor { self._withHue(offset: 0.75) }

 /// Returns the first analogous color (30° counter-clockwise hue offset, i.e., -1/12).
 public var analogous0: VLColor { self._withHue(offset: -1 / 12) }

 /// Returns the second analogous color (30° clockwise hue offset, i.e., 1/12).
 public var analogous1: VLColor { self._withHue(offset: 1 / 12) }

 // MARK: - Deprecated API
 @available(*, deprecated, renamed: "analogous0", message: "Typo, use .analogous0 instead")
 public var analagous0: VLColor { self.analogous0 }

 @available(*, deprecated, renamed: "analogous1", message: "Typo, use .analogous1 instead")
 public var analagous1: VLColor { self.analogous1 }

 @available(*, deprecated, renamed: "luminance", message: "Use .luminance instead")
 public var relativeLuminance: CGFloat
 {
  self.luminance
 }
}
