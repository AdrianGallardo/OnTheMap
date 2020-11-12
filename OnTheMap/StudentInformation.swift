//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 04/11/20.
//

import Foundation

struct StudentInformation: Codable {
	let firstName: String
	let lastName: String
	let latitude: Double
	let longitude: Double
	let mapString: String
	let mediaURL: String
	let uniqueKey: String
}
