//
//  RootViewController.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/05/27.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Cocoa

class RootViewController: NSViewController {

	private var devicesSplitViewController: DevicesSplitViewController!
	private var devices: Devices? {
		didSet {
			devicesSplitViewController.devices = devices
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		do {
			devices = try Devices()
		} catch {
			print("error occurred: \(error)")
		}
	}

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier else {
			return
		}
		switch identifier {
		case "EmbedDevicesSplitView":
			guard let controller = segue.destinationController as? DevicesSplitViewController else {
				return
			}
			devicesSplitViewController = controller
		default:
			break
		}
	}

}

