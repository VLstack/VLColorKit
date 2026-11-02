#if os(iOS)

import Testing
import UIKit
@testable import VLColorKit

@Suite("Color spaces (iOS)")
struct ColorSpaceTests
{
 @Test("Extended sRGB components are clamped")
 func extendedSRGB()
 {
  let color = UIColor(red: 1.2, green: -0.1, blue: 0.5, alpha: 1)
  let c = rgba(color)
  #expect([ c.red, c.green, c.blue, c.alpha ].allSatisfy { (0...1).contains($0) })
  #expect(!color.luminance.isNaN)
  #expect((0...1).contains(color.luminance))
  #expect(VLColor(hex: color.toHex()) != nil)
 }

 @Test("Display P3 red outside sRGB stays usable")
 func displayP3OutOfGamut() throws
 {
  let color = UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 1)
  let c = rgba(color)
  #expect([ c.red, c.green, c.blue, c.alpha ].allSatisfy { (0...1).contains($0) })
  #expect(!color.luminance.isNaN)
  #expect(!color.contrastRatio(with: .white).isNaN)
  #expect(color.toHex().count == 6)
  #expect(VLColor(hex: color.toHex()) != nil)
 }

 @Test("Display P3 color inside sRGB gives the sRGB hex")
 func displayP3InGamut() throws
 {
  let sRGB = try #require(CGColorSpace(name: CGColorSpace.sRGB))
  let displayP3 = try #require(CGColorSpace(name: CGColorSpace.displayP3))
  let source = try #require(CGColor(colorSpace: sRGB, components: [ 0.2, 0.4, 0.6, 1 ]))
  let converted = try #require(source.converted(to: displayP3, intent: .relativeColorimetric, options: nil))

  #expect(converted.colorSpace?.name == CGColorSpace.displayP3)
  #expect(UIColor(cgColor: converted).toHex() == "336699")
 }
}

#endif
