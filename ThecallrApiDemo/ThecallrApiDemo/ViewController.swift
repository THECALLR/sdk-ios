//
//  ViewController.swift
//  test
//
//  Created by THECALLR on 22/09/14.
//  Copyright (c) 2014 THECALLR. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var button: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		setupUI()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func setupUI() {
		label.text = "THECALLR iOS SDK Demo"
		label.textColor = UIColor.redColor()
		label.textAlignment = NSTextAlignment.Center

		button.setTitle("Send SMS", forState: .Normal)
	}

	@IBAction func buttonAction(sender: AnyObject) {

		var api = ThecallrApi(login: "login", password: "password")

		api.call("sms.send", params: "THECALLR", "+33123456789", "hello world!", ["flash_message": false])
		.success({ (result) -> Void in
			println(result)
		})
		.failure({ (error) -> Void in
			println(error)
		})

		let data: Array<AnyObject> = [
			"THECALLR",
			"+33123456789",
			"hello world!",
			["flash_message": false]
		]

		api.send("sms.send", params: data)
		.success({ (result) -> Void in
			println(result)
		})
		.failure({ (error) -> Void in
			println(error)
		})
	}
}

