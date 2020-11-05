//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 04/11/20.
//

import Foundation

struct StudentLocat: Codable {
	let createdAt: String
	let firstName: String
	let lastName: String
	let latitude: Double
	let longitude: Double
	let mapString: String
	let mediaURL: String
	let objectId: String
	let uniqueKey: String
	let updatedAt: String
}

struct StudentLocations: Codable {
	let results: [StudentLocat]
}
