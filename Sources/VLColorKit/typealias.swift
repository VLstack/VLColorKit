#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
public typealias VLColor = UIColor
#elseif os(macOS)
import AppKit
public typealias VLColor = NSColor
#endif
