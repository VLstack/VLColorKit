import Testing
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
@testable import VLColorKit

@Suite("HSL")
struct HSLTests
{
 @Test("Known colors",
       arguments: [
                   (0, 100, 50, "FF0000"),
                   (120, 100, 50, "00FF00"),
                   (240, 100, 50, "0000FF"),
                   (60, 100, 50, "FFFF00"),
                   (0, 0, 0, "000000"),
                   (0, 0, 100, "FFFFFF"),
                   (0, 0, 50, "808080")
                  ])
 func knownColors(hue: Int, saturation: Int, lightness: Int, expected: String)
 {
  let color = VLColor(hue: hue, saturation: saturation, lightness: lightness, alpha: 1)
  #expect(color.toHex() == expected)
 }

 @Test("Hues wrap around",
       arguments: [ (-30, 330), (360, 0), (390, 30), (-360, 0), (720, 0), (-390, 330) ])
 func hueWrap(hue: Int, equivalent: Int)
 {
  #expect(isClose(pureHue(hue), pureHue(equivalent)))
 }

 @Test("A tiny negative hue gives red, not gray")
 func tinyNegativeHue()
 {
  let color = VLColor(hue: -1e-17, saturation: 1, lightness: 0.5, alpha: 1)
  #expect(color.toHex() == "FF0000")
 }

 @Test("Red in HSL")
 func redInHSL() throws
 {
  let hsl = try #require(VLColor(red: 1, green: 0, blue: 0, alpha: 1).toHSL())
  #expect(isClose(hsl.hue, 0))
  #expect(isClose(hsl.saturation, 1))
  #expect(isClose(hsl.lightness, 0.5))
  #expect(isClose(hsl.alpha, 1))
 }

 @Test("HSL round trip",
       arguments: [ "FF0000", "3366CC", "808080", "C0FFEE", "123456", "FEDCBA", "FF00FF", "000000", "FFFFFF" ])
 func roundTrip(hex: String) throws
 {
  let color = try #require(VLColor(hex: hex))
  let hsl = try #require(color.toHSL())
  #expect(hsl.hue >= 0 && hsl.hue < 1)

  let back = VLColor(hue: hsl.hue, saturation: hsl.saturation, lightness: hsl.lightness, alpha: hsl.alpha)
  #expect(back.toHex() == hex)
 }
}
