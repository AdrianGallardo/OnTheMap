//
//  LocationsMapViewController.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 30/10/20.
//

import UIKit
import MapKit

class LocationsMapViewController: UIViewController, MKMapViewDelegate {

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var activityIndicatorView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	override func viewWillAppear(_ animated: Bool) {
		tabBarController?.tabBar.isHidden = false
	}

	override func viewDidLoad() {
		loadData()
	}

	func loadData() {
		self.activityIndicator.startAnimating()
		self.activityIndicatorView.isHidden = false

		OnTheMapClient.getStudentLocations(limit: 100) { (studentLocations, error) in
			guard let studentLocations = studentLocations else {
				self.activityIndicator.stopAnimating()
				self.activityIndicatorView.isHidden = true
				print(String(reflecting:error))
				return
			}
			var annotations = [MKPointAnnotation]()

			for location in studentLocations.results {
				let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(location.latitude),
																								longitude: CLLocationDegrees(location.longitude))
				let annotation = MKPointAnnotation()
				annotation.coordinate = coordinate
				annotation.title = "\(location.firstName) \(location.lastName)"
				annotation.subtitle = location.mediaURL
				annotations.append(annotation)
			}

			self.activityIndicator.stopAnimating()
			self.activityIndicatorView.isHidden = true

			self.mapView.addAnnotations(annotations)
		}
	}

	@IBAction func logout(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func refresh(_ sender: Any) {
		loadData()
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
			if let toOpen = view.annotation?.subtitle! {
				print(String(reflecting: toOpen))
				UIApplication.shared.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
			}
		}
	}
}
