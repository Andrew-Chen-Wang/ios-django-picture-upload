//
//  ViewController.swift
//  jwt-ios
//
//  Created by Andrew Chen Wang on 3/2/20.
//  Copyright © 2020 Andrew Chen Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let uploadButton = UIButton()
    let profilePicker = UIImagePickerController()
    let awsButton = UIButton()
    let summaryPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        uploadButton.addTarget(self, action: #selector(uploadPicture), for: .touchUpInside)
        uploadButton.setTitle("Profile Picture", for: .normal)
        uploadButton.backgroundColor = .red
        profilePicker.allowsEditing = true
        profilePicker.sourceType = .savedPhotosAlbum
        profilePicker.mediaTypes = ["public.image"]
        profilePicker.delegate = self
        awsButton.translatesAutoresizingMaskIntoConstraints = false
        awsButton.addTarget(self, action: #selector(uploadPicture), for: .touchUpInside)
        awsButton.setTitle("AWS Summary", for: .normal)
        awsButton.backgroundColor = .orange
        view.addSubview(uploadButton)
        view.addSubview(awsButton)
        NSLayoutConstraint.activate([
            uploadButton.topAnchor.constraint(equalTo: view.topAnchor),
            uploadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            uploadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            awsButton.topAnchor.constraint(equalTo: uploadButton.bottomAnchor),
            awsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            awsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            awsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func uploadPicture(_ sender: UIButton) {
        if UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) != nil {
            switch sender {
            case uploadButton:
                // For the profile picture
                present(profilePicker, animated: true)
            case awsButton:
                break
            default:
                break
            }
        } else {
            print("You need to allow pictures!")
        }
    }
    
    func uploadPictureServer(file: URL) {
        var request = URLRequest(url: URL(string: "http://127.0.0.1:8000/profile/")!)
        request.setValue("Bearer \(getAuthToken(.access))", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.setValue("inline; filename=\"hi.jpg\"", forHTTPHeaderField: "Content-Disposition")
        let task = URLSession.shared.uploadTask(with: request, fromFile: file, completionHandler: { data, response, error in
            if let response = response as? HTTPURLResponse {
                let result = handleNetworkResponse(response, data)
                switch result {
                case .success:
                    print("Successfully updated the profile picture.")
                case .failure(let networkError):
                    print(networkError)
                }
            }
        })
        task.resume()
    }
    
    func uploadToAWS() {}
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        switch picker {
        case profilePicker:
            uploadPictureServer(file: info[.imageURL] as! URL)
        case summaryPicker:
            uploadToAWS()
        default:
            break
        }
        self.dismiss(animated: true)
    }
}

extension ViewController: UINavigationBarDelegate {
    // On sign out, we should revoke all tokens. It's up to you if you also want to delete shared web user credentials. For us, we delete all.
    func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem) {
        navigationController?.signout()
    }
}
