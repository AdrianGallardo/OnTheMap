//
//  ViewController.swift
//  OnTheMap
//
//  Created by Adrian Gallardo on 28/10/20.
//

import UIKit

class LoginViewController: UIViewController {

	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var signUpButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
//MARK:- Actions
	@IBAction func loginTapped(_ sender: Any) {
		setLoginIn(true)
		OnTheMapClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLoginResponse(success:error:))
	}
//MARK:- Handlers
	func handleLoginResponse(success: Bool, error: Error?) {
		setLoginIn(false)
		if success {
			self.performSegue(withIdentifier: "completeLogin", sender: nil)
		} else {
			showLoginFailure(message: error?.localizedDescription ?? "")
		}
	}
//MARK:- LoginIn helper methods
	func setLoginIn(_ loginIn: Bool) {
		if loginIn {
			activityIndicator.startAnimating()
		} else {
			activityIndicator.stopAnimating()
		}
		emailTextField.isEnabled = !loginIn
		passwordTextField.isEnabled = !loginIn
		loginButton.isEnabled = !loginIn
		signUpButton.isEnabled = !loginIn
	}

	func showLoginFailure(message: String) {
		let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
		alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		show(alertVC, sender: nil)
	}

}
