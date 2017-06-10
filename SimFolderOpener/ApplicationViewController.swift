//
//  ApplicationViewController.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/06/10.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Cocoa

class ApplicationViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {

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
			let body: Application

			init(name: String, body: Application) {
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

		init(name: String, applicationSet: Applications.ApplicationSet) {
			let deviceList = applicationSet.devices
			var deviceDictionary = [String: [Device]]()
			deviceList.sorted(by: { $0.0.runtimeType < $0.1.runtimeType }).forEach { (device) in
				var runtimes = deviceDictionary[device.deviceType] ?? [Device]()
				runtimes.append(device)
				deviceDictionary[device.deviceType] = runtimes
			}

			var nodes = [Node]()
			deviceDictionary.keys.sorted(by: { $0.0 < $0.1 }).forEach { (deviceType) in
				guard let runtimes = deviceDictionary[deviceType] else {
					return
				}
				var leafs = [Leaf]()
				runtimes.forEach({ (device) in
					let applications = device.applications.filter({
						$0.name == applicationSet.name
					})
					guard let application = applications.first else {
						return
					}
					let leaf = Leaf(name: device.runtimeType, body: application)
					leafs.append(leaf)
				})
				let node = Node(name: deviceType, leafs: leafs)
				nodes.append(node)
			}

			super.init(name: name, nodes: nodes)
		}

	}

	class RuntimeTree: Tree {

		init(name: String, applicationSet: Applications.ApplicationSet) {
			let deviceList = applicationSet.devices
			var runtimeDictionary = [String: [Device]]()
			deviceList.sorted(by: { $0.0.deviceType < $0.1.deviceType }).forEach { (device) in
				var devices = runtimeDictionary[device.runtimeType] ?? [Device]()
				devices.append(device)
				runtimeDictionary[device.runtimeType] = devices
			}

			var nodes = [Node]()
			runtimeDictionary.keys.sorted(by: { $0.0 < $0.1 }).forEach { (runtimeType) in
				guard let devices = runtimeDictionary[runtimeType] else {
					return
				}
				var leafs = [Leaf]()
				devices.forEach({ (device) in
					let applications = device.applications.filter({
						$0.name == applicationSet.name
					})
					guard let application = applications.first else {
						return
					}
					let leaf = Leaf(name: device.deviceType, body: application)
					leafs.append(leaf)
				})
				let node = Node(name: runtimeType, leafs: leafs)
				nodes.append(node)
			}

			super.init(name: name, nodes: nodes)
		}

	}

	enum TreeType: Int {
		case devices = 0
		case runtimes = 1

		func tree(applicationSet: Applications.ApplicationSet?) -> Tree? {
			guard let applicationSet = applicationSet else {
				return nil
			}
			switch self {
			case .devices:
				return DeviceTree(name: "Devices", applicationSet: applicationSet)
			case .runtimes:
				return RuntimeTree(name: "Runtimes", applicationSet: applicationSet)
			}
		}
	}

	@IBOutlet weak var segmentedControl: NSSegmentedControl!
	@IBOutlet weak var nothingView: NSView!
	@IBOutlet weak var nothingLabel: NSTextField!
	@IBOutlet weak var outlineView: NSOutlineView!
	@IBOutlet weak var applicationTitleLabel: NSTextField!
	@IBOutlet weak var applicationOpenButton: NSButton!

	var applicationSet: Applications.ApplicationSet? {
		didSet {
			outlineViewTree = outlineViewTreeType.tree(applicationSet: applicationSet)
		}
	}

	private var outlineViewTreeType = TreeType.devices {
		didSet {
			outlineViewTree = outlineViewTreeType.tree(applicationSet: applicationSet)
		}
	}

	private var outlineViewTree: Tree? {
		didSet {
			if let applicationSet = applicationSet {
				if applicationSet.devices.count > 0 {
					nothingView.isHidden = true
					nothingLabel.stringValue = ""
				} else {
					nothingView.isHidden = false
					nothingLabel.stringValue = NSLocalizedString("No devices", comment: "")
				}
			} else {
				nothingView.isHidden = false
				nothingLabel.stringValue = NSLocalizedString("Select an application", comment: "")
			}
			applicationTitleLabel.stringValue = ""
			applicationOpenButton.isEnabled = false

			outlineView.usesAlternatingRowBackgroundColors = nothingView.isHidden
			outlineView.reloadData()
			outlineView.expandItem(nil, expandChildren: true)
			outlineView.sizeToFit()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		segmentedControl.selectedSegment = outlineViewTreeType.rawValue
		nothingView.isHidden = false
		nothingLabel.stringValue = NSLocalizedString("Select an aplication", comment: "")
		applicationTitleLabel.stringValue = ""
		applicationOpenButton.isEnabled = false

		outlineView.usesAlternatingRowBackgroundColors = nothingView.isHidden
		outlineView.sizeToFit()
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
		guard let identifier = tableColumn?.identifier else {
			return nil
		}
		let view = outlineView.make(withIdentifier: identifier, owner: self) as! NSTableCellView

		if let node = item as? Tree.Node {
			let text: String
			switch identifier {
			case "DeviceDataCell":
				text = node.name
			case "LastModifiedDataCell":
				text = ""
			default:
				text = ""
			}
			view.textField!.stringValue = text
		} else if let leaf = item as? Tree.Leaf {
			let text: String
			switch identifier {
			case "DeviceDataCell":
				text = leaf.name
			case "LastModifiedDataCell":
				let formatter = DateFormatter()
				formatter.dateFormat = "yyyy-MM-dd HH:mm"
				text = formatter.string(from: leaf.body.lastModified)
			default:
				text = ""
			}
			view.textField!.stringValue = text
		}

		return view
	}

	func outlineViewSelectionDidChange(_ notification: Notification) {
		if outlineView.selectedRow < 0 {
			applicationTitleLabel.stringValue = ""
			applicationOpenButton.isEnabled = false
		} else {
			if let item = outlineView.item(atRow: outlineView.selectedRow) as? Tree.Leaf {
				if let dataPath = item.body.dataPath {
					applicationTitleLabel.stringValue = NSString(string: dataPath).lastPathComponent
					applicationOpenButton.isEnabled = true
				} else {
					applicationTitleLabel.stringValue = ""
					applicationOpenButton.isEnabled = false
				}
			} else {
				applicationTitleLabel.stringValue = ""
				applicationOpenButton.isEnabled = false
			}
		}
	}
	
	@IBAction func didChangeSegmentedControlValue(_ sender: NSSegmentedControl) {
		outlineViewTreeType = TreeType(rawValue: segmentedControl.selectedSegment)!
	}

	@IBAction func didDoubleClickDataCell(_ sender: NSTableView) {
		if outlineView.selectedRow < 0 {
			return
		}
		if let item = outlineView.item(atRow: outlineView.selectedRow) as? Tree.Node {
			if outlineView.isItemExpanded(item) {
				outlineView.collapseItem(item)
			} else {
				outlineView.expandItem(item)
			}
		} else if let item = outlineView.item(atRow: outlineView.selectedRow) as? Tree.Leaf {
			openApplicationFolder(item.body)
		}
	}

	@IBAction func didClickApplicationOpenButton(_ sender: NSButton) {
		if let item = outlineView.item(atRow: outlineView.selectedRow) as? Tree.Leaf {
			openApplicationFolder(item.body)
		}
	}
	
	private func openApplicationFolder(_ application: Application) {
		guard let dataPath = application.dataPath else {
			return
		}
		NSWorkspace.shared().selectFile(nil, inFileViewerRootedAtPath: dataPath)
	}

}
