//
//  DevicesViewController.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/05/27.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Cocoa

class DevicesViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {

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

	class DeviceTree: Tree {

		init(name: String, devices: Devices) {
			let deviceList = devices.list
			var deviceDictionary = [String: [Leaf]]()
			deviceList.sorted(by: { $0.runtimeType < $1.runtimeType }).forEach { (device) in
				var leafs = deviceDictionary[device.deviceType] ?? [Leaf]()
				leafs.append(Leaf(name: device.runtimeType, body: device))
				deviceDictionary[device.deviceType] = leafs
			}

			var nodes = [Node]()
			deviceDictionary.keys.sorted(by: { $0 < $1 }).forEach { (deviceType) in
				guard let leafs = deviceDictionary[deviceType] else {
					return
				}
				let node = Node(name: deviceType, leafs: leafs)
				nodes.append(node)
			}

			super.init(name: name, nodes: nodes)
		}
		
	}

	class RuntimeTree: Tree {

		init(name: String, devices: Devices) {
			let deviceList = devices.list
			var deviceDictionary = [String: [Leaf]]()
			deviceList.sorted(by: { $0.deviceType < $1.deviceType }).forEach { (device) in
				var leafs = deviceDictionary[device.runtimeType] ?? [Leaf]()
				leafs.append(Leaf(name: device.deviceType, body: device))
				deviceDictionary[device.runtimeType] = leafs
			}

			var nodes = [Node]()
			deviceDictionary.keys.sorted(by: { $0 < $1 }).forEach { (runtimeType) in
				guard let leafs = deviceDictionary[runtimeType] else {
					return
				}
				let node = Node(name: runtimeType, leafs: leafs)
				nodes.append(node)
			}

			super.init(name: name, nodes: nodes)
		}
		
	}

	enum TreeType: Int {
		case devices = 0
		case runtimes = 1

		func tree(devices: Devices?) -> Tree? {
			guard let devices = devices else {
				return nil
			}
			switch self {
			case .devices:
				return DeviceTree(name: "Devices", devices: devices)
			case .runtimes:
				return RuntimeTree(name: "Runtimes", devices: devices)
			}
		}
	}

	@IBOutlet weak var segmentedControl: NSSegmentedControl!
	@IBOutlet weak var outlineView: NSOutlineView!
	
	weak var deviceViewController: DeviceViewController!

	var devices: Devices? {
		didSet {
			outlineViewTree = outlineViewTreeType.tree(devices: devices)
		}
	}

	private var outlineViewTreeType = TreeType.devices {
		didSet {
			outlineViewTree = outlineViewTreeType.tree(devices: devices)
		}
	}

	private var outlineViewTree: Tree? {
		didSet {
			outlineView.reloadData()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		segmentedControl.selectedSegment = outlineViewTreeType.rawValue
    }

	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil, let tree = outlineViewTree {
			return tree.nodes.count
		} else if let node = item as? Tree.Node {
			return node.leafs.count
		} else if item is Tree.Leaf {
			return 0
		}
		return 0
	}

	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if item is Tree.Node {
			return true
		} else if item is Tree.Leaf {
			return false
		} else {
			return false
		}
	}

	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil, let tree = outlineViewTree {
			return tree.nodes[index]
		} else if let node = item as? Tree.Node {
			return node.leafs[index]
		} else {
			assertionFailure("some program error occurred")
			return self
		}
	}

	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DeviceDataCell"), owner: self) as? NSTableCellView else {
			return nil
		}

		if let node = item as? Tree.Node {
			view.textField!.stringValue = node.name
			view.textField!.toolTip = nil
		} else if let leaf = item as? Tree.Leaf {
			view.textField!.stringValue = leaf.name
		}
		
		return view
	}

	func outlineViewSelectionDidChange(_ notification: Notification) {
		if outlineView.item(atRow: outlineView.selectedRow) is Tree.Node {
			closeDeviceView()
		} else if let item = outlineView.item(atRow: outlineView.selectedRow) as? Tree.Leaf {
			openDeviceView(item.body)
		}
	}

	@IBAction func didDoubleClickDataCell(_ sender: NSOutlineView) {
		if outlineView.clickedRow < 0 {
			return
		}
		if let item = outlineView.item(atRow: outlineView.clickedRow) as? Tree.Node {
			if outlineView.isItemExpanded(item) {
				outlineView.collapseItem(item)
			} else {
				outlineView.expandItem(item)
			}
		} else if let item = outlineView.item(atRow: outlineView.clickedRow) as? Tree.Leaf {
			openDeviceFolder(item.body)
		}
	}

	@IBAction func didChangeSegmentedControlValue(_ sender: NSSegmentedControl) {
		outlineViewTreeType = TreeType(rawValue: segmentedControl.selectedSegment)!
	}

	private func openDeviceFolder(_ device: Device) {
		NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: device.path)
	}

	private func openDeviceView(_ device: Device) {
		deviceViewController.device = device
	}

	private func closeDeviceView() {
		deviceViewController.device = nil
	}
	
}
