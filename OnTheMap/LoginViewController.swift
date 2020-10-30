//
//  ViewController.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 28/10/20.
//

import UIKit

class LoginViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}

	@IBAction func loginTapped(_ sender: Any) {
		performSegue(withIdentifier: "completeLogin", sender: nil)
	}

}

