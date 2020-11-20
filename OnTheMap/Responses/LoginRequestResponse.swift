//
//  LoginRequestResponse.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 03/11/20.
//

import Foundation

struct Account: Codable {
	let registered: Bool
	let key: String
}

struct Session: Codable {
	let id: String
	let expiration: String
}

struct LoginRequestResponse: Codable {
	let account: Account
	let session: Session
}
