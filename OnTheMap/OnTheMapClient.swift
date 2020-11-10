//
//  OnTheMapClient.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 01/11/20.
//

import Foundation

class OnTheMapClient {
	static var sessionID = ""

	class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
		let body = LoginRequest(udacity: LoginData(username: username, password: password))
		print("username: \(username)")
		print("password: \(password)")
		print(String(reflecting: body))
		taskForPOSTRequest(url: Endpoints.createSessionId.url,
											 response: LoginRequestResponse.self, body: body) { (response, error) in
			if let response = response {
				sessionID = response.session.id
				completion(true, nil)
			} else {
				completion(false, error)
			}
		}
	}

	class func getStudentLocations(limit: Int, completion: @escaping (StudentLocations?, Error?) -> Void) {
		taskForGETRequest(url: Endpoints.getStudentLocations(limit).url,
										response: StudentLocations.self) { (response, error) in
			if let response = response {
				completion(response, nil)
			} else {
				completion(nil, error)
			}
		}
	}

	class func getUserData(completion: @escaping (UserData?, Error?) -> Void) {
		taskForGETRequest(url: Endpoints.getUserData(sessionID).url, response: UserData.self) { (response, error) in
			if let response = response {
				completion(response, nil)
			} else {
				completion(nil, error)
			}
		}
	}

// MARK: - Tasks
	class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL?,
																																					 response: ResponseType.Type,
																																					 body: RequestType,
																																					 completion: @escaping (ResponseType?, Error?) -> Void) {
		guard let url = url else {
			return
		}
		print(String(reflecting: url))
		var request = URLRequest(url: url)

		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")

		do {
			request.httpBody = try JSONEncoder().encode(body)
			print(String(data: request.httpBody!, encoding: .utf8)!)

			let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
				guard let data = data else {
					print("error data")
					DispatchQueue.main.async {
						completion(nil, error)
					}
					return
				}
				print(String(data: data, encoding: .utf8)!)
				let decoder = JSONDecoder()
				do {
					let responseObject = try decoder.decode(ResponseType.self, from: data.subdata(in: 5..<data.count))
					print(responseObject)
					DispatchQueue.main.async {
						completion(responseObject, nil)
					}
				} catch {
					do {
						let errorResponse = try decoder.decode(OnTheMapResponse.self, from: data.subdata(in: 5..<data.count))
						DispatchQueue.main.async {
							completion(nil, errorResponse)
						}
					} catch {
						DispatchQueue.main.async {
							completion(nil, error)
						}
					}
				}
			}

			task.resume()

		} catch {
			DispatchQueue.main.async {
				completion(nil, error)
			}
		}
	}

	class func taskForGETRequest<ResponseType: Decodable>(url: URL?, response: ResponseType.Type,
																										completion: @escaping (ResponseType?, Error?) -> Void){
		guard let url = url else {
			return
		}
		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard let data = data else {
				DispatchQueue.main.async {
					completion(nil, error)
				}
				return
			}

			let decoder = JSONDecoder()
			do {
				let responseObject = try decoder.decode(ResponseType.self, from: data)
				DispatchQueue.main.async {
					completion(responseObject, nil)
				}
			} catch {
				print("taskForGETRequest: " +  error.localizedDescription)
        //Try to decode the data removing the first 5 characters
				do {
					let responseObject = try decoder.decode(ResponseType.self, from: data.subdata(in: 5..<data.count))
					DispatchQueue.main.async {
						completion(responseObject, nil)
					}
				} catch {
					DispatchQueue.main.async {
						completion(nil, error)
					}
				}

			}
		}
		task.resume()
	}
}
// MARK: - Endpoints
extension OnTheMapClient {
	enum Endpoints {
		static let base = "https://onthemap-api.udacity.com/v1"

		case getStudentLocations(Int)
		case postStudentLocation
		case updateStudentLocation(String)
		case createSessionId
		case logout
		case getUserData(String)

		var stringValue: String {
			switch self {
			case .getStudentLocations(let limit): return Endpoints.base + "/StudentLocation?limit=\(limit)"
			case .postStudentLocation: return Endpoints.base + "/StudentLocation"
			case .updateStudentLocation(let objectId): return Endpoints.base + "/StudentLocation/\(objectId)"
			case .createSessionId, .logout: return Endpoints.base + "/session"
			case .getUserData(let userId): return Endpoints.base + "/users/\(userId)"
			}
		}

		var url: URL? {
			return URL(string: stringValue)
		}
	}
}
