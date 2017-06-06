//
//  SplitViewController.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/05/27.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {

	private var devicesViewController: DevicesViewController!
	private var deviceViewController: DeviceViewController!
	private var devices: Devices? {
		didSet {
			devicesViewController.devices = devices
			deviceViewController.device = nil
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		devicesViewController = splitViewItems[0].viewController as! DevicesViewController
		deviceViewController = splitViewItems[1].viewController as! DeviceViewController
		devicesViewController.deviceViewController = deviceViewController
    }
    
	override func viewDidAppear() {
		super.viewDidAppear()

		let path = "~/Library/Developer/CoreSimulator/Devices"
		let absolutePath = NSString(string: path).expandingTildeInPath
		do {
			devices = try Devices(path: absolutePath)
		} catch {
			print("error occurred: \(error)")
		}
	}

}
