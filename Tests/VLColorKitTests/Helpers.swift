import Testing
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
@testable import VLColorKit

/// Returns the sRGB components of a color, as read by the package.
func rgba(_ color: VLColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
{
 var r: CGFloat = -1
 var g: CGFloat = -1
 var b: CGFloat = -1
 var a: CGFloat = -1

 #expect(color.getRGBA(&r, &g, &b, &a))

 return (red: r, green: g, blue: b, alpha: a)
}

/// Compares two values with a tolerance.
func isClose(_ lhs: CGFloat,
             _ rhs: CGFloat,
             tolerance: CGFloat = 1e-6) -> Bool
{
 abs(lhs - rhs) <= tolerance
}

/// Compares the sRGB components of two colors, with a tolerance of about one unit out of 255.
func isClose(_ lhs: VLColor,
             _ rhs: VLColor,
             tolerance: CGFloat = 1.01 / 255) -> Bool
{
 let l = rgba(lhs)
 let r = rgba(rhs)

 return    isClose(l.red, r.red, tolerance: tolerance)
        && isClose(l.green, r.green, tolerance: tolerance)
        && isClose(l.blue, r.blue, tolerance: tolerance)
        && isClose(l.alpha, r.alpha, tolerance: tolerance)
}

/// Returns a fully saturated color of the given hue (HSL lightness 50 %, i.e. HSB brightness 100 %).
func pureHue(_ degrees: Int) -> VLColor
{
 VLColor(hue: degrees, saturation: 100, lightness: 50, alpha: 1)
}
