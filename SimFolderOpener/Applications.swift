//
//  Applications.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/06/10.
//  Copyright © 2017年 Hiroki Ishiura. All rights reserved.
//

import Foundation

class Applications: CustomStringConvertible {

	typealias ApplicationSet = (name: String, devices: [Device])

	var list: [ApplicationSet]

	init(devices: Devices?) throws {
		guard let devices = devices else {
			throw CocoaError(.fileReadNoSuchFile)
		}

		var deviceDictionary = [String: [Device]]()
		devices.list.forEach { (device) in
			device.applications.forEach({ (application) in
				var devices = deviceDictionary[application.name] ?? [Device]()
				devices.append(device)
				deviceDictionary[application.name] = devices
			})
		}

		list = []
		deviceDictionary.keys.sorted().forEach { (name) in
			let set = (name: name, devices: deviceDictionary[name]!)
			list.append(set)
		}
	}

	var description: String {
		get {
			return "Applications {list=\(list)}"
		}
	}

}
