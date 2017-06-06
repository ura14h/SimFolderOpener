//
//  Device.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/05/27.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Foundation

class Device: CustomStringConvertible {

	let path: String
	let name: String
	let deviceType: String
	let runtimeType: String
	let enabled: Bool
	lazy var applications: [Application] = self.listApplications()

	init(path: String) throws {
		let plistPath = NSString(string: path).appendingPathComponent("device.plist")
		guard let plist = NSDictionary(contentsOfFile: plistPath) as? [String: Any] else {
			throw CocoaError(.fileReadNoSuchFile)
		}

		guard let name = plist["name"] as? String else {
			throw CocoaError(.propertyListReadCorrupt)
		}
		guard let deviceType = plist["deviceType"] as? String else {
			throw CocoaError(.propertyListReadCorrupt)
		}
		guard let runtimeType = plist["runtime"] as? String else {
			throw CocoaError(.propertyListReadCorrupt)
		}
		let enabled: Bool
		if plist["status"] == nil {
			enabled = false
		} else {
			enabled = plist["status"] as! Bool
		}

		self.path = path
		self.name = name
		self.deviceType = Device.frendlyName(name: deviceType)
		self.runtimeType = Device.frendlyName(name: runtimeType)
		self.enabled = enabled
	}

	var description: String {
		get {
			return "Device {path=\"\(path)\", name=\"\(name)\", deviceType=\"\(deviceType)\", runtimeType=\"\(runtimeType)\", enabled=\(enabled)}"
		}
	}

	private static func frendlyName(name: String) -> String {
		// e.g. "com.apple.CoreSimulator.SimDeviceType.iPhone-5s" -> "iPhone-5s"
		let lastComponent = NSString(string: name).pathExtension

		// e.g. "iPad-Pro-9-7-inch" -> "iPad-Pro-9.7 inch"
		let unitPattern = "([0-9]+)-([0-9]+)-(inch)"
		let unitFormat = "$1.$2 $3"
		let unitReplaced = lastComponent.replacingOccurrences(of: unitPattern, with: unitFormat, options: .regularExpression, range: nil)

		// e.g. "iOS-10-1" -> "iOS-10.1"
		let versionPattern = "([0-9]+)-([0-9]+)$"
		let versionFormat = "$1.$2"
		let vesionReplaced = unitReplaced.replacingOccurrences(of: versionPattern, with: versionFormat, options: .regularExpression, range: nil)

		// e.g. "iPhone-6-Plus" -> "iPhone 6 Plus"
		let hyphenPattern = "-"
		let hyphenFormat = " "
		let hyphenReplaced = vesionReplaced.replacingOccurrences(of: hyphenPattern, with: hyphenFormat, options: .regularExpression, range: nil)

		return hyphenReplaced
	}

	private func listApplications() -> [Application] {
		return Application.list(path: path)
	}

}
