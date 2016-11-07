//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by David  on 29/10/2016.
//
//

import UIKit

protocol MemeEditorDelegate {
    func appendMeme(meme: Meme)
}

class MemeEditorViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    
//    var sentMemes = [Meme]()
    var memeEditorDelegate: MemeEditorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        topTextField.delegate = self
        bottomTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = isCameraAvailable()
        
        // default text
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.black,
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3.0
            ] as [String : Any]

        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.text = "TOP"
        topTextField.textAlignment = NSTextAlignment.center
        
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.text = "BOTTOM"
        bottomTextField.textAlignment = NSTextAlignment.center
        
        subscribeToKeyboardNotifcations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifcations()
    }

    func isCameraAvailable() -> Bool {
       return UIImagePickerController.isSourceTypeAvailable(_:UIImagePickerControllerSourceType.camera)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let existingText = textField.text
        if existingText == "TOP" || existingText == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func subscribeToKeyboardNotifcations() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifcations() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        view.frame.origin.y -= getKeyboardHeight(notification: notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y += getKeyboardHeight(notification: notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    // TODO: test with real device
    @IBAction func launchCamera(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func presentImagePicker(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // value is optional and is conditionally downcasted
        if let value = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = value
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // TODO: test with real device
    @IBAction func share(_ sender: UIBarButtonItem) {
        
        let meme = renderMeme()
        let objectsToShare = [meme] as [Any]
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
        activityVC.completionWithItemsHandler = {
            
            (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            
            if completed {
                self.save(memeImage: meme)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
        // TODO: consider iPad
    }
    
    func renderMeme() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO:  Show toolbar and navbar
        
        return memedImage
    }
    
    func save(memeImage: UIImage) {
        let sentMeme = Meme(textTop: topTextField.text!, textBottom: bottomTextField.text!, originalImage: imageView.image!, memeImage: memeImage)
        if let delegate = memeEditorDelegate {
            delegate.appendMeme(meme: sentMeme)
        }
//        let parentVC = self.parent
//        if let sentMemesVC = self.parent as? SentMemesViewController  {
//            sentMemesVC.sentMemes.append(sentMeme)
//        }
    }
    
}

