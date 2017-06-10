//
//  ApplicationsViewController.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/06/10.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Cocoa

class ApplicationsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

	@IBOutlet weak var tableView: NSTableView!
	
	weak var applicationViewController: ApplicationViewController!
	
	var applications: Applications? {
		didSet {
			tableView.reloadData()
			tableView.sizeToFit()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.sizeToFit()
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		guard let applications = applications else {
			return 0
		}
		return applications.list.count
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let identifier = tableColumn?.identifier else {
			return nil
		}
		let view = tableView.make(withIdentifier: identifier, owner: self) as! NSTableCellView

		guard let applications = applications else {
			return nil
		}
		switch identifier {
		case "BundleIdDataCell":
			view.textField!.stringValue = applications.list[row].name
		default:
			return nil
		}

		return view
	}

	func tableViewSelectionDidChange(_ notification: Notification) {
		if tableView.selectedRow < 0 {
			closeApplicationView()
		} else {
			guard let applications = applications else {
				assertionFailure("some program error occurred")
				return
			}
			openApplicationView(applications.list[tableView.selectedRow])
		}
	}


	@IBAction func didDoubleClickDataCell(_ sender: NSTableView) {
	}

	private func openApplicationView(_ applicationSet: Applications.ApplicationSet?) {
		applicationViewController.applicationSet = applicationSet
	}

	private func closeApplicationView() {
		applicationViewController.applicationSet = nil
	}

}
