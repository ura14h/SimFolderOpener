//
//  DeviceViewController.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/05/27.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Cocoa

class DeviceViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

	@IBOutlet weak var deviveTitleLabel: NSTextField!
	@IBOutlet weak var deviceOpenButton: NSButton!
	@IBOutlet weak var nothingView: NSView!
	@IBOutlet weak var nothingLabel: NSTextField!
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var applicationTitleLabel: NSTextField!
	@IBOutlet weak var applicationOpenButton: NSButton!

	var device: Device? {
		didSet {
			if let device = device {
				deviveTitleLabel.stringValue = NSString(string: device.path).lastPathComponent
				deviceOpenButton.isEnabled = true
				applications = device.applications
			} else {
				deviveTitleLabel.stringValue = ""
				deviceOpenButton.isEnabled = false
				applications = []
			}
		}
	}

	private var applications = [Application]() {
		didSet {
			if device != nil {
				if applications.count > 0 {
					nothingView.isHidden = true
					nothingLabel.stringValue = ""
				} else {
					nothingView.isHidden = false
					nothingLabel.stringValue = NSLocalizedString("No applications", comment: "")
				}
			} else {
				nothingView.isHidden = false
				nothingLabel.stringValue = NSLocalizedString("Select a device", comment: "")
			}
			applicationTitleLabel.stringValue = ""
			applicationOpenButton.isEnabled = false

			tableView.usesAlternatingRowBackgroundColors = nothingView.isHidden
			tableView.reloadData()
			tableView.sizeToFit()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		deviveTitleLabel.stringValue = ""
		deviceOpenButton.isEnabled = false
		nothingView.isHidden = false
		nothingLabel.stringValue = NSLocalizedString("Select a device", comment: "")
		applicationTitleLabel.stringValue = ""
		applicationOpenButton.isEnabled = false

		tableView.usesAlternatingRowBackgroundColors = nothingView.isHidden
		tableView.sizeToFit()
}

	func numberOfRows(in tableView: NSTableView) -> Int {
		return applications.count
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let identifier = tableColumn?.identifier else {
			return nil
		}
		let view = tableView.make(withIdentifier: identifier, owner: self) as! NSTableCellView

		guard let device = device else {
			return nil
		}
		let application = device.applications[row]
		switch identifier {
		case "BundleIdDataCell":
			view.textField!.stringValue = application.name
		case "LastModifiedDataCell":
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd HH:mm"
			let lastModified = formatter.string(from: application.lastModified)
			view.textField!.stringValue = lastModified
		default:
			return nil
		}
		
		return view
	}

	func tableViewSelectionDidChange(_ notification: Notification) {
		if tableView.selectedRow < 0 {
			applicationTitleLabel.stringValue = ""
			applicationOpenButton.isEnabled = false
		} else {
			let application = applications[tableView.selectedRow]
			if let dataPath = application.dataPath {
				applicationTitleLabel.stringValue = NSString(string: dataPath).lastPathComponent
				applicationOpenButton.isEnabled = true
			} else {
				applicationTitleLabel.stringValue = ""
				applicationOpenButton.isEnabled = false
			}
		}
	}

	@IBAction func didDoubleClickDataCell(_ sender: NSTableView) {
		if tableView.selectedRow < 0 {
			return
		}
		let application = applications[tableView.selectedRow]
		openApplicationFolder(application)
	}

	@IBAction func didClickDeviceOpenButton(_ sender: NSButton) {
		guard let device = device else {
			return
		}
		NSWorkspace.shared().selectFile(nil, inFileViewerRootedAtPath: device.path)
	}

	@IBAction func didClickApplicationOpenButton(_ sender: NSButton) {
		let application = applications[tableView.selectedRow]
		openApplicationFolder(application)
	}

	private func openApplicationFolder(_ application: Application) {
		guard let dataPath = application.dataPath else {
			return
		}
		NSWorkspace.shared().selectFile(nil, inFileViewerRootedAtPath: dataPath)
	}

}
