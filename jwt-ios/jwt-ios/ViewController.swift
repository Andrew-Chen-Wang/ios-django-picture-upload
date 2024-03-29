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
        
        summaryPicker.allowsEditing = true
        summaryPicker.sourceType = .savedPhotosAlbum
        summaryPicker.mediaTypes = ["public.image"]
        summaryPicker.delegate = self
        
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
                present(summaryPicker, animated: true)
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
    
    func uploadToAWS(image: UIImage) {
        AuthNetworkManager().uploadToServer() { response, error in
            if error != nil {
                print(error ?? "")
            } else {
                DispatchQueue.main.async {
                    self.uploadImageToAWS(image: image, response: response!)
                }
            }
        }
    }
    
    private func uploadImageToAWS(image: UIImage, response: AWSApiResponse) {
        let photo = image.resizeWithWidth(width: 400)!
        var request = URLRequest(url: response.url)
        request.httpMethod = "POST"
        let boundary = "Boundary-HGUYABHSB"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createFormBody(params: response.fields, boundary: boundary, imageData: photo.jpegData(compressionQuality: 0.5)!)
        NetworkLogger.log(request: request)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                NetworkLogger.log(response: response)
                let result = handleNetworkResponse(response, data)
                switch result {
                case .success:
                    print("Successfully updated profile.")
                case .failure(let networkError):
                    let data = data!
                    if let responseString = String(bytes: data, encoding: .utf8) {
                        print(responseString)
                    } else {
                        print(networkError)
                    }
                }
            }
        }
        task.resume()
    }
    
    func createFormBody(params: [String: String], boundary: String, imageData: Data) -> Data {
        let lineBreak = "\r\n"
        var body = Data()

        for (key, value) in params {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
            if value.last == "=" {
                body.append("\(value + "=" + lineBreak)")
            } else {
                body.append("\(value + lineBreak)")
            }
        }
        
        // Photo
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"hi.jpg\"\(lineBreak)")
        body.append("Content-Type: image/jpg \(lineBreak + lineBreak)")
        body.append(imageData)
        body.append(lineBreak)
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        switch picker {
        case profilePicker:
            uploadPictureServer(file: info[.imageURL] as! URL)
        case summaryPicker:
            uploadToAWS(image: info[.editedImage] as! UIImage)
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

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
