//
//  OnTheMapResponse.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 03/11/20.
//

import Foundation

struct OnTheMapResponse: Codable {
	let status: Int
	let error: String
}

extension OnTheMapResponse: LocalizedError {
	var errorDescription: String? {
		return error
	}
}
