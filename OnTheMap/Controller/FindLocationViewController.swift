//
//  FindLocation.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 30/10/20.
//

import UIKit
import MapKit

class FindLocationViewController: UIViewController, MKMapViewDelegate {
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var activityIndicatorView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	var mapString: String?
	var coordinates: CLLocationCoordinate2D?
	var mediaUrl: String?
	var userData: UserData?

	override func viewWillAppear(_ animated: Bool) {
		tabBarController?.tabBar.isHidden = true
		loadUserData()
	}

	func loadUserData() {
		print("FindLocationVC: load user data")
		showNetworkActivity(true)
		OnTheMapClient.getUserData(completion: self.handleGetUserData(userData:error:))
	}

	@IBAction func finish(_ sender: Any) {
		showNetworkActivity(true)
		OnTheMapClient.getStudentInformation(completion: self.handleStudentInformation(studentInformation:error:))
	}

	func showNetworkActivity(_ isNetworking: Bool) {
		if isNetworking {
			self.activityIndicator.startAnimating()
		} else {
			self.activityIndicator.stopAnimating()
		}
		self.activityIndicatorView.isHidden = !isNetworking
	}

	func messageAlert(_ message: String) {
		let alertVC = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
		alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alertVC, animated: true)
	}

	// MARK: - Handlers
	func handleGetUserData(userData: UserData?, error: Error?) {
		guard let userData = userData else {
			print(String(reflecting: error))
			return
		}

		self.userData = userData

		if let coordinates = self.coordinates {
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinates
			annotation.title = "\(userData.firstName) \(userData.lastName)"
			annotation.subtitle = self.mediaUrl
			let region = MKCoordinateRegion(center: annotation.coordinate,
																		span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
			mapView.setRegion(region, animated: true)
			self.mapView.addAnnotation(annotation)
		}

		showNetworkActivity(false)
		print("FindLocationVC: user data loaded")
	}

	func handleStudentInformation(studentInformation: StudentInformation?, error: Error?) {
		print("FindLocationVC: handle student information")
		print("FindLocationVC: student information -> " + String(reflecting: studentInformation))
		guard let studentInformation = studentInformation else {
			postStudentInformation()
			return
		}

		updateStudentInformation(studentInformation: studentInformation)
	}

	func handlePostStudentInformation(success: Bool, error: Error?) {
		print("FindLocationVC: handle post student information")
		if success {
			self.messageAlert("Location Posted Correctly!")
		} else {
			print(String(reflecting: error))
			self.messageAlert(error?.localizedDescription ?? "")
		}
		showNetworkActivity(false)
	}

	func handleUpdateStudentInformation(success: Bool, error: Error?) {
		print("FindLocationVC: handle update student information")
		if success {
			self.messageAlert("Location Updated Correctly!")
		} else {
			print(String(reflecting: error))
			self.messageAlert(error?.localizedDescription ?? "")
		}
		showNetworkActivity(false)
	}

	func postStudentInformation() {
		print("FindLocationVC: post student information")
		guard let userData = self.userData else {
			return
		}
		guard let coordinates = self.coordinates else {
			return
		}
		guard let mapString = self.mapString else {
			return
		}
		guard let mediaUrl = self.mediaUrl else {
			return
		}
		let body = StudentInformation(firstName: userData.firstName, lastName: userData.lastName, latitude: coordinates.latitude, longitude: coordinates.longitude,
																	mapString: mapString, mediaURL: mediaUrl, uniqueKey: OnTheMapClient.uniqueKey)
		OnTheMapClient.postStudentInformation(body: body, completion: self.handlePostStudentInformation(success:error:))
	}

	func updateStudentInformation(studentInformation: StudentInformation) {
		print("FindLocationVC: update student information")
		OnTheMapClient.updateStudentInformation(body: studentInformation, completion: self.handleUpdateStudentInformation(success:error:))
	}

	// MARK: - MKMapViewDelegate
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let reuseId = "pin"
		var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView!.canShowCallout = true
			pinView!.pinTintColor = .red
			pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
		} else {
			pinView!.annotation = annotation
		}

		return pinView
	}

	// This delegate method is implemented to respond to taps. It opens the system browser
	// to the URL specified in the annotationViews subtitle property.
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
							 calloutAccessoryControlTapped control: UIControl) {
		print("tap")
		if control == view.rightCalloutAccessoryView {
			guard let subtitle = view.annotation?.subtitle else {
				return
			}
			guard let mediaString = subtitle else {
				return
			}
			guard let mediaUrl = URL(string: mediaString) else {
				return
			}
			UIApplication.shared.open(mediaUrl)
		}
	}
}
