//
//  DeviceTree.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/06/01.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Foundation

class DeviceTree: Tree {

	init(name: String, devices: Devices) {
		let deviceList = devices.list
		var deviceDictionary = [String: [Leaf]]()
		deviceList.sorted(by: { $0.0.runtimeType < $0.1.runtimeType }).forEach { (device) in
			var leafs = deviceDictionary[device.deviceType] ?? [Leaf]()
			leafs.append(Leaf(name: device.runtimeType, body: device))
			deviceDictionary[device.deviceType] = leafs
		}

		var nodes = [Node]()
		deviceDictionary.keys.sorted(by: { $0.0 < $0.1 }).forEach { (deviceType) in
			guard let leafs = deviceDictionary[deviceType] else {
				return
			}
			let name = leafs.first!.body.deviceType
			let node = Node(name: name, leafs: leafs)
			nodes.append(node)
		}

		super.init(name: name, nodes: nodes)
	}

}
