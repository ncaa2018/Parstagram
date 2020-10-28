//
//  CameraViewController.swift
//  Parstagram
//
//  Created by loan on 10/28/20.
//  Copyright © 2020 naomia2022@hotmail.com. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
           super.viewDidLoad()

           // Do any additional setup after loading the view.
       }
       
    @IBAction func onSumitButton(_ sender: Any) {
        let post = PFObject(className: "Posts") //like a dictionary
        
        post["caption"] = commentField.text
        post["author"] = PFUser.current()! //logged in owner --> owner is a pointer in the table to the current user
        
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(data: imageData!) //binary values of image to be saved in table
        
        post["photo"] = file
        
        post.saveInBackground { (success,error) in
            if success {
                print("Saved!")
                self.dismiss(animated: true, completion: nil)
            }
            else{
                print("error!")
            }
            
        }
    }
   
    @IBAction func onCameraButton(_ sender: Any) {
        //launch the camera
        let picker = UIImagePickerController() //special built-in view controller
        picker.delegate = self //let me know what user took, call me back
        picker.allowsEditing = true //allows user to tweak edit
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) { //if the camera is available. this is an enum
            picker.sourceType = .camera
        }
        else{
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil) 
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        //resize image
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
        
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
