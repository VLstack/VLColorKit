import Testing
import SwiftUI
@testable import VLColorKit

@Suite("Luminance and contrast")
struct ContrastTests
{
 @Test("Luminance of black, white and gray")
 func luminance() throws
 {
  #expect(isClose(VLColor.black.luminance, 0))
  #expect(isClose(VLColor.white.luminance, 1))

  let gray = try #require(VLColor(hex: "808080"))
  #expect(isClose(gray.luminance, 0.2159, tolerance: 1e-4))
 }

 @Test("Black on white is 21")
 func blackOnWhite()
 {
  #expect(isClose(VLColor.black.contrastRatio(with: .white), 21, tolerance: 1e-4))
  #expect(isClose(VLColor.white.contrastRatio(with: .black), 21, tolerance: 1e-4))
 }

 @Test("A color against itself is 1")
 func sameColor() throws
 {
  let color = try #require(VLColor(hex: "3366CC"))
  #expect(isClose(color.contrastRatio(with: color), 1))
 }

 @Test("SwiftUI color contrast")
 func colorContrast()
 {
  #expect(isClose(Color.black.contrastRatio(with: Color.white), 21, tolerance: 1e-4))
 }

 @Test("Dark colors",
       arguments: [
                   ("000000", true),
                   ("FFFFFF", false),
                   ("000080", true),
                   ("0000FF", true),
                   ("FFFF00", false),
                   ("FF0000", false)
                  ])
 func isDark(hex: String, expected: Bool) throws
 {
  let color = try #require(VLColor(hex: hex))
  #expect(color.isDark == expected)
  #expect(Color(hex: hex).isDark == expected)
 }

 @Test("Best text color is readable",
       arguments: [ "000000", "FFFFFF", "000080", "FFFF00", "FF0000", "808080" ])
 func bestTextColor(hex: String) throws
 {
  let color = try #require(VLColor(hex: hex))
  #expect(color.contrastRatio(with: color.bestTextColor) >= 3)
 }
}
