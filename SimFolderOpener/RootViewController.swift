//
//  RootViewController.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/05/27.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Cocoa

class RootViewController: NSViewController {

	@IBOutlet weak var refreshOpenButton: NSButton!
	@IBOutlet weak var segmentedControl: NSSegmentedControl!
	@IBOutlet weak var rootOpenButton: NSButton!
	@IBOutlet weak var nothingLabel: NSTextField!
	@IBOutlet weak var devicesContainerView: NSView!
	@IBOutlet weak var applicationsContainerView: NSView!

	private var devicesSplitViewController: DevicesSplitViewController!
	private var applicationsSplitViewController: ApplicationsSplitViewController!
	private var devices: Devices?
	private var applications: Applications?

	override func viewDidLoad() {
		super.viewDidLoad()

		segmentedControl.isEnabled = false
		segmentedControl.selectedSegment = -1
		rootOpenButton.isEnabled = false
		didChangeSegmentedControlValue(segmentedControl)
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		didClickRefreshButton(refreshOpenButton)
	}

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier else {
			return
		}
		switch identifier.rawValue {
		case "EmbedDevicesSplitView":
			guard let controller = segue.destinationController as? DevicesSplitViewController else {
				return
			}
			devicesSplitViewController = controller
		case "EmbedApplicationsSplitView":
			guard let controller = segue.destinationController as? ApplicationsSplitViewController else {
				return
			}
			applicationsSplitViewController = controller
		default:
			break
		}
	}

	@IBAction func didClickRefreshButton(_ sender: NSButton) {
		do {
			devices = try Devices()
			applications = try Applications(devices: devices)

			devicesSplitViewController.devices = devices
			applicationsSplitViewController.applications = applications

			segmentedControl.isEnabled = true
			segmentedControl.selectedSegment = 0
			rootOpenButton.isEnabled = true
			nothingLabel.isHidden = true
		} catch {
			print("error occurred: \(error)")

			segmentedControl.isEnabled = false
			segmentedControl.selectedSegment = -1
			rootOpenButton.isEnabled = false
			nothingLabel.isHidden = false
		}
		didChangeSegmentedControlValue(segmentedControl)
	}

	@IBAction func didChangeSegmentedControlValue(_ sender: NSSegmentedControl) {
		let segment = segmentedControl.selectedSegment
		nothingLabel.isHidden = (segment != -1)
		devicesContainerView.isHidden = (segment != 0)
		applicationsContainerView.isHidden = (segment != 1)
	}

	@IBAction func didClickRootOpenButton(_ sender: NSButton) {
		guard let devices = devices else {
			return
		}
		NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: devices.path)
	}

}

