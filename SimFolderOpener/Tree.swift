//
//  Tree.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/06/03.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Foundation

class Tree: NSObject {

	let name: String
	let nodes: [Node]

	class Node: NSObject {
		let name: String
		let leafs: [Leaf]

		init(name: String, leafs: [Leaf]) {
			self.name = name
			self.leafs = leafs
		}

		override var description: String {
			get {
				return "Node {name=\"\(name)\", leafs=[\(leafs)]}"
			}
		}
	}

	class Leaf: NSObject {
		let name: String
		let body: Device

		init(name: String, body: Device) {
			self.name = name
			self.body = body
		}

		override var description: String {
			get {
				return "Leaf {name=\"\(name)\", body=[\(body)]}"
			}
		}
	}

	init(name: String, nodes: [Node]) {
		self.name = name
		self.nodes = nodes
	}

	override var description: String {
		get {
			return "Tree {name=\"\(name)\", nodes=[\(nodes)]}"
		}
	}

}
