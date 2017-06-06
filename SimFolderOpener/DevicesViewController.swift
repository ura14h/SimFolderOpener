//
//  DevicesViewController.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/05/27.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Cocoa

class DevicesViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {

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
	var outlineViewTreeType = TreeType.devices {
		didSet {
			outlineViewTree = outlineViewTreeType.tree(devices: devices)
		}
	}
	var outlineViewTree: Tree? {
		didSet {
			outlineView.reloadData()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		syncSegmentedControlValue()
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
		guard let view = outlineView.make(withIdentifier: "DataCell", owner: self) as? NSTableCellView else {
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

	private func syncSegmentedControlValue() {
		segmentedControl.selectedSegment = outlineViewTreeType.rawValue
	}

	private func openDeviceFolder(_ device: Device) {
		NSWorkspace.shared().selectFile(nil, inFileViewerRootedAtPath: device.path)
	}

	private func openDeviceView(_ device: Device) {
		deviceViewController.device = device
	}

	private func closeDeviceView() {
		deviceViewController.device = nil
	}
	
}
