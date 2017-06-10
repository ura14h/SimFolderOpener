//
//  ApplicationsSplitViewController.swift
//  SimFolderOpener
//
//  Created by Hiroki Ishiura on 2017/06/10.
//  Copyright © 2017 Hiroki Ishiura. All rights reserved.
//

import Cocoa

class ApplicationsSplitViewController: NSSplitViewController {
	
	var applications: Applications? {
		didSet {
			applicationsViewController.applications = applications
//			applicationViewController.application = nil
		}
	}

	private var applicationsViewController: ApplicationsViewController!
	private var applicationViewController: ApplicationViewController!

	override func viewDidLoad() {
		super.viewDidLoad()

		applicationsViewController = splitViewItems[0].viewController as! ApplicationsViewController
		applicationViewController = splitViewItems[1].viewController as! ApplicationViewController
		applicationsViewController.applicationViewController = applicationViewController
	}

}
