//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 30/10/20.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {

	@IBOutlet weak var locationTextField: UITextField!
	@IBOutlet weak var mediaUrlTextField: UITextField!
	@IBOutlet weak var findLocationButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	override func viewWillAppear(_ animated: Bool) {
		tabBarController?.tabBar.isHidden = true
	}

	@IBAction func findLocation(_ sender: Any) {
		guard let location = locationTextField.text, !location.isEmpty else {
			messageAlert("Please insert a Location")
			locationTextField.becomeFirstResponder()
			return
		}
		guard let mediaUrl = mediaUrlTextField.text, !mediaUrl.isEmpty else {
			messageAlert("Please insert an URL to share")
			mediaUrlTextField.becomeFirstResponder()
			return
		}
		findCoordinate(addressString: location, completionHandler: self.handleGetCoordinate(coordinates:error:))
	}

	func messageAlert(_ message: String) {
		let alertVC = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
		alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alertVC, animated: true)
	}

	func findCoordinate(addressString: String, completionHandler: @escaping (CLLocationCoordinate2D, Error?) -> Void ) {
		activityIndicator.startAnimating()
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(addressString) { (placemarks, error) in
			if error == nil {
				if let placemark = placemarks?[0] {
					let location = placemark.location!
					completionHandler(location.coordinate, nil)
					return
				}
			}
			completionHandler(kCLLocationCoordinate2DInvalid, error)
		}
	}

	func handleGetCoordinate(coordinates: CLLocationCoordinate2D, error: Error?) {
		activityIndicator.stopAnimating()
		if let error = error {
			let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
			alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			show(alertVC, sender: nil)
			return
		}
		if let findLocationVC = self.storyboard!.instantiateViewController(withIdentifier: "findLocationViewController")
				as? FindLocationViewController {
			findLocationVC.mapString = self.locationTextField.text ?? ""
			findLocationVC.coordinates = coordinates
			findLocationVC.mediaUrl = self.mediaUrlTextField.text ?? ""
			self.navigationController!.pushViewController(findLocationVC, animated: true)
		}
	}

}
