//
//  UserData.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 09/11/20.
//

import Foundation

struct UserData: Codable {
	let firstName: String
	let lastName: String
	let imageUrl: String

	enum CodingKeys: String, CodingKey {
		case firstName = "first_name"
		case lastName = "last_name"
		case imageUrl = "_image_url"
	}
}
