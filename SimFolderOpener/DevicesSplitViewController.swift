//
//  DevicesSplitViewController.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/05/27.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Cocoa

class DevicesSplitViewController: NSSplitViewController {

	var devices: Devices? {
		didSet {
			devicesViewController.devices = devices
			deviceViewController.device = nil
		}
	}

	private var devicesViewController: DevicesViewController!
	private var deviceViewController: DeviceViewController!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		devicesViewController = splitViewItems[0].viewController as! DevicesViewController
		deviceViewController = splitViewItems[1].viewController as! DeviceViewController
		devicesViewController.deviceViewController = deviceViewController
    }
    
}
