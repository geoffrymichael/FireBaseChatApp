//
//  LoginController.swift
//  VoonChatApp
//
//  Created by Geoffry Gambling on 9/10/19.
//  Copyright © 2019 Geoffry Gambling. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    var messageController: MessagesViewController?
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    
    @objc func handleLoginRegister() {
        if loginRegisterSegementedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (User, error) in
            if error != nil {
                print(error as Any)
                return
                
            }
            
            self.messageController?.saveUserAndUpdateNavTitle()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (User, error) in
            
            
            if error != nil {
                print(error as Any, "👩‍👧‍👦")
                return
            }
            
            
            guard let uid = User?.user.uid else {
                return
            }
            
            //Successfully registered new user
            
            //Creates a unique userid using a timestamp
            let imageName = NSUUID().uuidString
            
            let storage = Storage.storage().reference().child("profileImages").child("\(imageName).png")
            
            if let uploadData = self.logo.image {
                if let data = uploadData.jpegData(compressionQuality: 0.1) {
                    storage.putData(data, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            print(error as Any)
                            return
                        }
                        
                        storage.downloadURL(completion: { (url, error) in
                            if error != nil {
                                print(error as Any)
                                return
                            }
                            
                            if let profileUrl = url?.absoluteString {
                                let values = ["name": name, "email": email, "profileImageUrl": profileUrl] as [String : Any]
                                
                                self.saveUserToDatabase(uid: uid, values: values as [String : AnyObject])

                            }
                            
                        })
                        
                    })

                }

            }

        }
        
    }
    
    private func saveUserToDatabase(uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                print(error as Any)
                return
            }
            
            
            let user = User()
            user.name = values["name"] as? String
            user.email = values["email"] as? String
            user.profiliImageUrl = values["profileImageUrl"] as? String
            
            self.messageController?.setTitleView(user: user)
            
//            self.messageController?.saveUserAndUpdateNavTitle()
//            self.navigationItem.title = values["name"] as? String
            self.dismiss(animated: true, completion: nil)
            print("User saved succesfully")
        })
    }
    
   lazy var logo: UIImageView = {
        let logoView = UIImageView()
        logoView.image = UIImage(named: "magnum")
    
        logoView.translatesAutoresizingMaskIntoConstraints = false
        
        
        logoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogoTap)))
        
        logoView.contentMode = .scaleAspectFill
        
        logoView.isUserInteractionEnabled = true

        
        
        
        return logoView
    }()
    
    
    
    
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()

    let nameSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let emailSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    
    let loginRegisterSegementedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        
        return sc
    }()
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegementedControl.titleForSegment(at: loginRegisterSegementedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        
        //This is a convention to toggle configuration depending on which button is clicked
        //In this sense, we are selecting if the login button is hit at segement 0 then it is shrunk otherwise if the only other button, the register is clicked, it grows
        inputFieldHeightConstraint?.constant = loginRegisterSegementedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        
        // I am not exactly sure how this works, but it allows for some adjusting of ourlayout by using conditionals
        nameInputHeightConstraint?.isActive = false
        nameInputHeightConstraint? = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegementedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameInputHeightConstraint?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor? = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegementedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextHeightAnchor?.isActive = false
        passwordTextHeightAnchor? = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegementedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextHeightAnchor?.isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        // Do any additional setup after loading the view.
     
        view.addSubview(logo)
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(loginRegisterSegementedControl)
        
        setupLogo()
        
        setupInputsContainerView()
        setupLoginregisterButton()
        
        setupLoginToggle()
        
        
    }
    
    func setupLogo() {
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.bottomAnchor.constraint(equalTo: loginRegisterSegementedControl.topAnchor, constant: -12).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 100).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    func setupLoginToggle() {
        loginRegisterSegementedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegementedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegementedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    loginRegisterSegementedControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    var nameInputHeightConstraint: NSLayoutConstraint?
    var inputFieldHeightConstraint: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView() {
        //Add constraints for container view
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
//        inputsContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        //This is allowing our constraint to change height depending on whether login button is clicked.
        inputFieldHeightConstraint = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputFieldHeightConstraint?.isActive = true
        
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeperatorView)
        
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeperatorView)
        
        inputsContainerView.addSubview(passwordTextField)
        
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        nameInputHeightConstraint = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameInputHeightConstraint?.isActive = true
        
        nameSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeperatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeperatorView.widthAnchor.constraint(lessThanOrEqualTo: inputsContainerView.widthAnchor).isActive = true
        nameSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameSeperatorView.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
//        emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        
        emailTextFieldHeightAnchor?.isActive = true
        
        emailSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeperatorView.widthAnchor.constraint(lessThanOrEqualTo: inputsContainerView.widthAnchor).isActive = true
        emailSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailSeperatorView.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        passwordTextHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextHeightAnchor?.isActive = true
    }

    func setupLoginregisterButton() {
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive  = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginRegisterButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
