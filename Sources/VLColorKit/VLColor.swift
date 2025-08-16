#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension VLColor
{
 private enum WCAG
 {
  static let AA_small: CGFloat = 4.5
  static let AA_large: CGFloat = 3.0
  static let AAA_small: CGFloat = 7.0
  static let AAA_large: CGFloat = 4.5
 }

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

 public var bestTextColor: VLColor
 {
  let variants = [ adjustedLightness(to: 0.98), adjustedLightness(to: 0.25) ].compactMap { $0 }

  return bestContrast(threshold: WCAG.AAA_small, colors: variants)
         ?? bestContrast(threshold: WCAG.AAA_large, colors: variants)
         ?? bestLuminance(threshold: 0.5, colors: variants)
         ?? bestLuminance(threshold: 0.5, colors: [ .white, .black ])
         ?? .black
 }

 internal func bestContrast(threshold: CGFloat,
                           colors: [ VLColor ]) -> VLColor?
 {
  findBest(threshold: threshold,
           predicate: { contrastRatio(with: $0) },
           colors: colors)
 }

 internal func bestLuminance(threshold: CGFloat,
                             colors: [ VLColor ]) -> VLColor?
 {
  let baseLuminance = luminance

  return findBest(threshold: threshold,
                  predicate: { abs($0.luminance - baseLuminance) },
                  colors: colors)
 }

 internal func findBest(threshold: CGFloat,
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

 @available(*, deprecated, renamed: "luminance", message: "Use .luminance instead")
 public var relativeLuminance: CGFloat
 {
  self.luminance
 }

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

 public func contrastRatio(with other: VLColor) -> CGFloat
 {
  let l1 = self.luminance
  let l2 = other.luminance

  return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)
 }

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

 public func toHex(prefixed: Bool = false,
                   includeAlpha: Bool = false,
                   fallback: String = "000000") -> String
 {
  #if os(macOS)
  guard let rgbColor = self.usingColorSpace(.deviceRGB),
        let components = rgbColor.cgColor.components else { return prefixed ? "#" + fallback : fallback }
  #else
  guard let components = self.cgColor.components else { return prefixed ? "#" + fallback : fallback }
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

 internal func adjustedLightness(to newLightness: CGFloat) -> VLColor?
 {
  guard let hsl = toHSL() else { return nil }

  return VLColor(hue: hsl.hue,
                 saturation: hsl.saturation,
                 lightness: newLightness,
                 alpha: hsl.alpha)
 }

 public var complement: VLColor { self.withHue(offset: 0.5) }
 public var splitComplement0: VLColor { self.withHue(offset: 150 / 360) }
 public var splitComplement1: VLColor { self.withHue(offset: 210 / 360) }
 public var triadic0: VLColor { self.withHue(offset: 120 / 360) }
 public var triadic1: VLColor { self.withHue(offset: 240 / 360) }
 public var tetradic0: VLColor { self.withHue(offset: 0.25) }
 public var tetradic1: VLColor { self.complement }
 public var tetradic2: VLColor { self.withHue(offset: 0.75) }
 public var analagous0: VLColor { self.withHue(offset: -1 / 12) }
 public var analagous1: VLColor { self.withHue(offset: 1 / 12) }

 internal func withHue(offset: CGFloat) -> VLColor
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
}
