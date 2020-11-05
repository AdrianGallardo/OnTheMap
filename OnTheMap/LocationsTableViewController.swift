//
//  LocationsTableViewController.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 30/10/20.
//

import UIKit

class LocationsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	var locations: StudentLocations?

	override func viewWillAppear(_ animated: Bool) {
		tabBarController?.tabBar.isHidden = false
	}

	override func viewDidLoad() {
		loadData()
	}

	func loadData() {
		OnTheMapClient.getStudentLocations(limit: 100) { (studentLocations, error) in
			guard let studentLocations = studentLocations else {
				return
			}
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
		return self.locations?.results.count ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "locationViewCell")!
		if let studentLocat = locations?.results[indexPath.row] {
			cell.textLabel?.text = "\(studentLocat.firstName) \(studentLocat.lastName)"
			cell.detailTextLabel?.text = "\(studentLocat.mediaURL)"
		}
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	}
}
