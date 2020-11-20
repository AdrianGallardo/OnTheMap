//
//  OnTheMapClient.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 01/11/20.
//

import Foundation

class OnTheMapClient {
	static var sessionID = ""
	static var uniqueKey = ""

	// MARK: - Auxiliar Functions
	class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
		let body = LoginRequest(udacity: LoginData(username: username, password: password))
		print("username: \(username)")
		print("password: \(password)")
		print(String(reflecting: body))
		taskForPOSTRequest(url: Endpoints.createSessionId.url,
											 response: LoginRequestResponse.self, body: body) { (response, error) in
			if let response = response {
				sessionID = response.session.id
				uniqueKey = response.account.key
				completion(true, nil)
			} else {
				completion(false, error)
			}
		}
	}

	class func logout() {
		guard let url = Endpoints.logout.url else {
			return
		}
		var request = URLRequest(url: url)
		request.httpMethod = "DELETE"

		var xsrfCookie: HTTPCookie?
		let sharedCookieStorage = HTTPCookieStorage.shared
		for cookie in sharedCookieStorage.cookies! {
			if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
		}
		if let xsrfCookie = xsrfCookie {
			request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
		}
		let session = URLSession.shared
		let task = session.dataTask(with: request) { data, _, error in
			if error != nil {
				return
			}
			let newData = data?.subdata(in: 5..<data!.count)
			print(String(data: newData!, encoding: .utf8)!)
		}
		task.resume()
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
		print("client: get user data")
		taskForGETRequest(url: Endpoints.getUserData(sessionID).url, response: UserData.self) { (response, error) in
			if let response = response {
				completion(response, nil)
			} else {
				completion(nil, error)
			}
		}
	}

	class func getStudentInformation(completion: @escaping (StudentInformation?, Error?) -> Void) {
		print("client: getStudentInformation")
		taskForGETRequest(url: Endpoints.getStudentInformation(uniqueKey).url,
											response: StudentLocations.self) { (response, error) in
			if let response = response {
				completion(response.results?[0], nil)
			} else {
				completion(nil, error)
			}
		}
	}

	class func postStudentInformation(body: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
		print("client: postStudentInformation")
		taskForPOSTRequest(url: Endpoints.postStudentInformation.url,
											 response: PostStudentInformationResponse.self, body: body) { (response, error) in
			if response != nil {
				completion(true, nil)
			} else {
				completion(false, error)
			}
		}
	}

	class func updateStudentInformation(body: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
		print("client: updateStudentInformation")
		guard let url = Endpoints.updateStudentInformation(uniqueKey).url else {
			print("error URL update")
			return
		}
		print("client updateStudentInformation: url -> " + String(reflecting: url))
		var request = URLRequest(url: url)

		request.httpMethod = "PUT"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")

		do {
			request.httpBody = try JSONEncoder().encode(body)
			print("client updateStudentInformation: body -> " + String(data: request.httpBody!, encoding: .utf8)!)

			let task = URLSession.shared.dataTask(with: request) { data, _, error in
				print("client updateStudentInformation: data -> " + String(data: data!, encoding: .utf8)!)
				guard data != nil else {
					DispatchQueue.main.async {
						completion(false, error)
					}
					return
				}
				DispatchQueue.main.async {
					completion(true, nil)
				}
			}
			task.resume()

		} catch {
			DispatchQueue.main.async {
				completion(false, error)
			}
		}
	}

// MARK: - POST Task
	class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL?,
																																					 response: ResponseType.Type,
																																					 body: RequestType,
																																					 completion: @escaping (ResponseType?, Error?) -> Void) {
		print("client: taskForPOSTRequest")
		guard let url = url else {
			return
		}
		print("client taskForPOSTRequest: url -> " + String(reflecting: url))
		var request = URLRequest(url: url)

		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")

		do {
			request.httpBody = try JSONEncoder().encode(body)
			print("client taskForPOSTRequest: body -> " + String(data: request.httpBody!, encoding: .utf8)!)

			let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
				print("client taskForPOSTRequest: data -> " + String(data: data!, encoding: .utf8)!)
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
					let responseObject = try decoder.decode(ResponseType.self, from: data)
					print(responseObject)
					DispatchQueue.main.async {
						completion(responseObject, nil)
					}
				} catch {
					print("client taskForPOSTRequest: " +  error.localizedDescription)
					do {
						let responseObject = try decoder.decode(ResponseType.self, from: data.subdata(in: 5..<data.count))
						print("client taskForGETRequest: Data decoded after removing 5 first characters")
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
			}

			task.resume()

		} catch {
			DispatchQueue.main.async {
				completion(nil, error)
			}
		}
	}
	// MARK: - GET Task
	class func taskForGETRequest<ResponseType: Decodable>(url: URL?, response: ResponseType.Type,
																										completion: @escaping (ResponseType?, Error?) -> Void) {
		print("client: taskForGETRequest")
		guard let url = url else {
			return
		}
		print("client taskForGETRequest: url -> " + String(reflecting: url))
		let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
			print("client taskForGETRequest: data -> " + String(data: data!, encoding: .utf8)!)
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
				print("client taskForGETRequest: " +  error.localizedDescription)
				do {
					let responseObject = try decoder.decode(ResponseType.self, from: data.subdata(in: 5..<data.count))
					print("client taskForGETRequest: Data decoded after removing 5 first characters")
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
		case postStudentInformation
		case updateStudentInformation(String)
		case createSessionId
		case logout
		case getUserData(String)
		case getStudentInformation(String)

		var stringValue: String {
			switch self {
			case .getStudentLocations(let limit): return Endpoints.base + "/StudentLocation?limit=\(limit)&order=-updatedAt"
			case .getStudentInformation(let uniqueKey): return Endpoints.base + "/StudentLocation?uniqueKey=\(uniqueKey)"
			case .postStudentInformation: return Endpoints.base + "/StudentLocation"
			case .updateStudentInformation(let objectId): return Endpoints.base + "/StudentLocation/\(objectId)"
			case .createSessionId, .logout: return Endpoints.base + "/session"
			case .getUserData(let userId): return Endpoints.base + "/users/\(userId)"
			}
		}

		var url: URL? {
			return URL(string: stringValue)
		}
	}
}
