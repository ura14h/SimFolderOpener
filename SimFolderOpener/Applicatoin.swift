//
//  Application.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/06/03.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Foundation

class Application: CustomStringConvertible {

	let name: String
	let lastModified: Date
	let bundlePath: String
	let dataPath: String?

	init(name: String, bundlePath: String, dataPath: String?) throws {
		let bundlePathAttribute = try FileManager.default.attributesOfItem(atPath: bundlePath)
		guard var lastModified = bundlePathAttribute[FileAttributeKey.modificationDate] as? Date else {
			throw CocoaError(.fileReadUnknown)
		}
		if let dataPath = dataPath {
			let dataPathAttribute = try FileManager.default.attributesOfItem(atPath: dataPath)
			guard let dataLastModified = dataPathAttribute[FileAttributeKey.modificationDate] as? Date else {
				throw CocoaError(.fileReadUnknown)
			}
			if dataLastModified > lastModified {
				lastModified = dataLastModified
			}
		}

		self.name = name
		self.lastModified = lastModified
		self.bundlePath = bundlePath
		self.dataPath = dataPath
	}

	var description: String {
		get {
			let dataPath = self.dataPath == nil ? "(nil)" : "\(self.dataPath!)"
			return "Application {name=\"\(name)\", lastModified=\(lastModified), bundlePath=\"\(bundlePath)\", dataPath=\(dataPath)}"
		}
	}

	static func list(path: String) -> [Application] {
		let bundleFolderList = Application.bundleFolderList(path: path)
		let dataFolderList = Application.dataFolderList(path: path)

		var dataFolderDictionary = [String: String]()
		dataFolderList.forEach { (folder) in
			dataFolderDictionary[folder.name] = folder.path
		}

		var applications = [Application]()
		bundleFolderList.forEach { (folder) in
			let dataPath = dataFolderDictionary[folder.name]
			guard let application = try? Application(name: folder.name, bundlePath: folder.path, dataPath: dataPath) else {
				return
			}
			applications.append(application)
		}
		applications.sort {
			$0.name < $1.name
		}

		return applications
	}

	private typealias Folder = (path: String, name: String)

	private static func bundleFolderList(path: String) -> [Folder] {
		let folderPath = path.appendingPath("data").appendingPath("Containers")
			.appendingPath("Bundle").appendingPath("Application")
		let list = Application.folderList(path: folderPath)
		return list
	}

	private static func dataFolderList(path: String) -> [Folder] {
		let folderPath = path.appendingPath("data").appendingPath("Containers")
			.appendingPath("Data").appendingPath("Application")
		let list = Application.folderList(path: folderPath)
		return list
	}

	private static func folderList(path: String) -> [Folder] {
		guard let contents = try? FileManager.default.contentsOfDirectory(atPath: path) else {
			return []
		}
		var list = [Folder]()
		contents.forEach({ (content) in
			if content.hasPrefix(".") {
				return
			}
			let contentPath = path.appendingPath(content)
			var contentPathIsDirectory = ObjCBool(false)
			let contentPathExists = FileManager.default.fileExists(atPath: contentPath, isDirectory: &contentPathIsDirectory)
			if !contentPathExists || !contentPathIsDirectory.boolValue {
				return
			}

			let plistPath = contentPath.appendingPath(".com.apple.mobile_container_manager.metadata.plist")
			guard let plist = NSDictionary(contentsOfFile: plistPath) as? [String: Any] else {
				return
			}

			guard let contentName = plist["MCMMetadataIdentifier"] as? String else {
				return
			}

			let folder = (path: contentPath, name: contentName)
			list.append(folder)
		})
		return list
	}

}

extension String {

	func appendingPath(_ component: String) -> String {
		return NSString(string: self).appendingPathComponent(component)
	}

}
