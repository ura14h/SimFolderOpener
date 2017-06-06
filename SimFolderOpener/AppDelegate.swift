//
//  AppDelegate.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/05/27.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

}

