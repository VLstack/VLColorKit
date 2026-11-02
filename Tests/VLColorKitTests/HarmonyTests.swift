import Testing
import SwiftUI
@testable import VLColorKit

@Suite("Harmonies")
struct HarmonyTests
{
 @Test("Harmonies of red")
 func harmoniesOfRed()
 {
  let red = pureHue(0)
  #expect(isClose(red.complement, pureHue(180)))
  #expect(isClose(red.splitComplement0, pureHue(150)))
  #expect(isClose(red.splitComplement1, pureHue(210)))
  #expect(isClose(red.triadic0, pureHue(120)))
  #expect(isClose(red.triadic1, pureHue(240)))
  #expect(isClose(red.tetradic0, pureHue(90)))
  #expect(isClose(red.tetradic1, pureHue(180)))
  #expect(isClose(red.tetradic2, pureHue(270)))
  #expect(isClose(red.analogous0, pureHue(330)))
  #expect(isClose(red.analogous1, pureHue(30)))
 }

 @Test("Analogous of a hue close to 0 is not gray")
 func analogousNearZero()
 {
  #expect(isClose(pureHue(10).analogous0, pureHue(340)))
 }

 @Test("Complement of the complement")
 func complementTwice() throws
 {
  let color = try #require(VLColor(hex: "3366CC"))
  #expect(isClose(color.complement.complement, color))
 }

 @Test("Alpha is kept")
 func alphaKept() throws
 {
  let color = try #require(VLColor(hex: "FF000080"))
  #expect(isClose(rgba(color.complement).alpha, 128.0 / 255))
 }

 @Test("SwiftUI color complement")
 func colorComplement()
 {
  #expect(Color(hex: "FF0000").complement.toHex() == "00FFFF")
 }
}
