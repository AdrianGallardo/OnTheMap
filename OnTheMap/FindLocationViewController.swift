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
	var coordinates: CLLocationCoordinate2D?
	var mediaUrl: String?

	override func viewWillAppear(_ animated: Bool) {
		tabBarController?.tabBar.isHidden = true

		if let coordinates = coordinates {
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinates
			annotation.title = "HOLA MUNDO"
			annotation.subtitle = self.mediaUrl
			mapView.addAnnotation(annotation)
		}
	}

	@IBAction func finish(_ sender: Any) {

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
