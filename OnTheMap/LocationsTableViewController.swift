//
//  LocationsTableViewController.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 30/10/20.
//

import UIKit

class LocationsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var activityIndicatorView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	var locations: StudentLocations?

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
				print(String(reflecting: error))
				return
			}

			self.activityIndicator.stopAnimating()
			self.activityIndicatorView.isHidden = true

			self.locations = studentLocations
			self.tableView.reloadData()
		}
	}

	@IBAction func logout(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func refresh(_ sender: Any) {
		loadData()
	}

	// MARK: - TableViewDelegate
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.locations?.results?.count ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "locationViewCell")!
		if let studentLocat = locations?.results?[indexPath.row] {
			cell.textLabel?.text = "\(studentLocat.firstName) \(studentLocat.lastName)"
			cell.detailTextLabel?.text = "\(studentLocat.mediaURL)"
		}
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let mediaString = locations?.results?[indexPath.row].mediaURL else {
			return
		}
		guard let mediaUrl = URL(string: mediaString) else {
			return
		}
		UIApplication.shared.open(mediaUrl)
	}
}
