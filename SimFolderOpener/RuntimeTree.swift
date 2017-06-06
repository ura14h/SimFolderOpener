//
//  RuntimeTree.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/06/03.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Foundation

class RuntimeTree: Tree {

	init(name: String, devices: Devices) {
		let deviceList = devices.list
		var deviceDictionary = [String: [Leaf]]()
		deviceList.sorted(by: { $0.0.deviceType < $0.1.deviceType }).forEach { (device) in
			var leafs = deviceDictionary[device.runtimeType] ?? [Leaf]()
			leafs.append(Leaf(name: device.deviceType, body: device))
			deviceDictionary[device.runtimeType] = leafs
		}

		var nodes = [Node]()
		deviceDictionary.keys.sorted(by: { $0.0 < $0.1 }).forEach { (runtimeType) in
			guard let leafs = deviceDictionary[runtimeType] else {
				return
			}
			let name = leafs.first!.body.runtimeType
			let node = Node(name: name, leafs: leafs)
			nodes.append(node)
		}

		super.init(name: name, nodes: nodes)
	}

}
