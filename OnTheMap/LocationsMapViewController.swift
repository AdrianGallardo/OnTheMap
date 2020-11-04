//
//  LocationsMapViewController.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 30/10/20.
//

import UIKit

class LocationsMapViewController: UIViewController {
	
	override func viewWillAppear(_ animated: Bool) {
		tabBarController?.tabBar.isHidden = false
	}

 @IBAction func logout(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func refresh(_ sender: Any) {
	}
}
