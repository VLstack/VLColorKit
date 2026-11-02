import Testing
import SwiftUI
@testable import VLColorKit

@Suite("Hexadecimal")
struct HexTests
{
 @Test("Valid strings are read",
       arguments: [
                   ("FF0000", "FF0000"),
                   ("#FF0000", "FF0000"),
                   ("  ff0000\n", "FF0000"),
                   ("F00", "FF0000"),
                   ("#abc", "AABBCC"),
                   ("FF000080", "FF0000")
                  ])
 func validStrings(input: String, expected: String) throws
 {
  let color = try #require(VLColor(hex: input))
  #expect(color.toHex() == expected)
 }

 @Test("Invalid strings are rejected",
       arguments: [ "", "#", "12345G", "GGG", "GG0000", "12345", "1234", "1234567", "123456789", "+12345", "FF 000", "0xFF00" ])
 func invalidStrings(input: String)
 {
  #expect(VLColor(hex: input) == nil)
 }

 @Test("Alpha last")
 func alphaLast() throws
 {
  let color = try #require(VLColor(hex: "FF000080"))
  #expect(color.toHex(includeAlpha: true) == "FF000080")
  #expect(isClose(rgba(color).alpha, 128.0 / 255))
 }

 @Test("Alpha first")
 func alphaFirst() throws
 {
  let color = try #require(VLColor(hex: "80FF0000", alphaFirst: true))
  #expect(color.toHex(includeAlpha: true) == "FF000080")
 }

 @Test("Alpha first has no effect on 6 characters")
 func alphaFirstSixCharacters() throws
 {
  let color = try #require(VLColor(hex: "FF0000", alphaFirst: true))
  #expect(color.toHex(includeAlpha: true) == "FF0000FF")
 }

 @Test("Prefix")
 func prefix() throws
 {
  let color = try #require(VLColor(hex: "00FF00"))
  #expect(color.toHex(prefixed: true) == "#00FF00")
 }

 @Test("Every byte survives a round trip", arguments: 0...255)
 func roundTrip(value: Int) throws
 {
  let hex = String(format: "%02X%02X%02X%02X", value, 255 - value, (value * 7) % 256, (value * 13) % 256)
  let color = try #require(VLColor(hex: hex))
  #expect(color.toHex(includeAlpha: true) == hex)
 }

 @Test("SwiftUI color round trip")
 func colorRoundTrip()
 {
  #expect(Color(hex: "#3366CC").toHex() == "3366CC")
 }

 @Test("SwiftUI color falls back on an invalid string")
 func colorFallback()
 {
  let red = VLColor(red: 1, green: 0, blue: 0, alpha: 1)
  #expect(Color(hex: "zzz", fallback: red).toHex() == "FF0000")
 }
}
