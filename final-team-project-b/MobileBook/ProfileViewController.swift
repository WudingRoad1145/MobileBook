//
//  ProfileViewController.swift
//  Mobilebooklogindemo
//
//  Created by Yan on 4/16/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var userId = Auth.auth().currentUser?.uid
    var reviews = [String]()
    //set up storage reference
    private let storage = Storage.storage().reference()
    
    let db = Firestore.firestore()
    let realtimedb = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var motto: UITextField!
    @IBOutlet weak var location: UITextField!

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var edit: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePic.layer.cornerRadius = profilePic.frame.size.width/2
        profilePic.clipsToBounds = true
        setupProfile()
        
        guard let urlString = UserDefaults.standard.value(forKey: "url") as? String,
              let url=URL(string: urlString) else{
                  return
              }
        
        // download data
        let task = URLSession.shared.dataTask(with: url,completionHandler: {data, _, error in
            guard let data = data, error == nil else{
                return
            }
            DispatchQueue.main.async{
                let image = UIImage(data: data)
                self.profilePic.image = image
            }
        })
        task.resume()
        // Do any additional setup after loading the view.
        db.collection("users").document(userId!).collection("reviews").getDocuments() { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents : \(err)")
            }
            else {
                for document in QuerySnapshot!.documents {
                    let dbReview = document.get("review") as? String ?? ""
                    let dbTime = document.get("book") as? String ?? ""
                    //let dbUser = document.get("author") as? String ?? ""
                    print(dbReview)
                    self.reviews.append(dbReview)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // show the stored text by default
    // if click edit your profile then become text box and edit
    // turn button into update?
    // click update to store data to FireStore
    // show the new text from fireStore
    @IBAction func uploadImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(picker, animated: true, completion: nil)
    }
    @IBAction func editProfileTapped(_ sender: Any) {
        //create cleaned versions of the data
        //let profilepicFiled = profilePic.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameField = userName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let mottoField = motto.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let locationField = location.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //modify user
        //let db = Firestore.firestore()
        //db.collection("users").addDocument(data: ["name":nameField,"motto":mottoField,"location":locationField,"uid": SignUpViewController.userID])
        if Constants.UserData.userId != "" {
            db.collection("users").document(Constants.UserData.userId)
                .setData( ["name":nameField,"motto":mottoField,"location":locationField,"uid": Constants.UserData.userId],merge: true)
        }
        else{
            print("user doesn't exist")
        }
    }
    
    
    func setupProfile(){
        let userDB = db.collection("users").document(uid!)
        userDB.addSnapshotListener{ [weak self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else{
                print("Error fetching document: \(error!)")
                return
            }
            guard let nameText = data["name"] as? String else{
                return
            }
            guard let mottoText = data["motto"] as? String else{
                return
            }
            guard let locText = data["location"] as? String else{
                return
            }
            DispatchQueue.main.async{
                self?.userName.text = nameText
                self?.motto.text = mottoText
                self?.location.text = locText
            }
            
            print("Current data: \(data)")
                    
        }

        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey:Any]){
        picker.dismiss(animated:true,completion:nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        /*
        guard let imageData = image.pngData() else{
            return
        }
        */
        guard let imageData = image.pngData() else{
            return
        }
        
        //upload image
        storage.child(self.uid!).putData(imageData, metadata: nil, completion: {_,error in
            guard error == nil else{
                print("Failed to upload")
                return
            }
            //get the url
            self.storage.child(self.uid!).downloadURL(completion:{url, error in
                guard let url = url, error == nil else{
                    return
                }
                let urlString = url.absoluteString
                DispatchQueue.main.async{
                    self.profilePic.image = image
                }
                print("Download URL: \(urlString)")
                UserDefaults.standard.set(urlString, forKey:"url")
            })
        })
        
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(reviews)
        return reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = reviews[indexPath.row]
        print("testing")
        print(reviews[indexPath.row])

        return cell
    }

    // MARK: - Table view delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // etc
    }
}
    
