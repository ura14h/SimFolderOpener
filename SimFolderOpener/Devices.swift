//
//  Devices.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/05/27.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Foundation

class Devices: CustomStringConvertible {

	let path: String
	let list: [Device]

	convenience init() throws {
		let path = "~/Library/Developer/CoreSimulator/Devices"
		let absolutePath = NSString(string: path).expandingTildeInPath

		try self.init(path: absolutePath)
	}

	init(path: String) throws {
		guard let contents = try? FileManager.default.contentsOfDirectory(atPath: path) else {
			throw CocoaError(.fileReadNoSuchFile)
		}
		
		var list = [Device]()
		contents.forEach({ (content) in
			if content.hasPrefix(".") {
				return
			}
			let devicePath = path.appendingPath(content)
			var devicePathIsDirectory = ObjCBool(false)
			let devicePathExists = FileManager.default.fileExists(atPath: devicePath, isDirectory: &devicePathIsDirectory)
			if !devicePathExists || !devicePathIsDirectory.boolValue {
				return
			}
			do {
				let device = try Device(path: devicePath)
				list.append(device)
			} catch {
				// print("ignore a folder: \(devicePath) by error: \(error)")
			}
		})

		self.path = path
		self.list = list
	}

	var description: String {
		get {
			return "Devices {path=\"\(path)\", list=\(list)}"
		}
	}
	
}
