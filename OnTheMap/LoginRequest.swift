//
//  LoginRequest.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 03/11/20.
//

import Foundation

struct LoginData: Codable {
	let username: String
	let password: String
}

struct LoginRequest: Codable {
	let udacity: LoginData
}
