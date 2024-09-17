//
//  TextFileViewController.swift
//  Lyrics
//
//  Created by Peter Burkimsher on 5/11/23.
//

import Foundation
import UIKit

class TextFileViewController: UIViewController, UIGestureRecognizerDelegate {
 
    @IBOutlet var thisView: UIView!
    @IBOutlet weak var textArea: UITextView!
    
    var selectedItemPath: String?
    var text: String?

    @IBAction func cancelButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pingtypeButtonClicked(_ sender: Any) {
        let fileTextSender: [String: Any?] = ["text": textArea.text ?? ""]
        
        self.performSegue(withIdentifier: "TextFileToPingtype", sender: fileTextSender)

    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
    
        let rawData: Data? = textArea.text.data(using: .utf8)
        
        if (selectedItemPath == nil)
        {
            
            
            
            let thisAlertController = UIAlertController(title: "Filename", message: nil, preferredStyle: .alert)
            thisAlertController.addTextField()

            let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned thisAlertController] _ in
                let answer = thisAlertController.textFields![0]
                // do something interesting with "answer" here
                
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let selectedItemPath = documentsPath.appendingPathComponent(answer.text ?? "")
                FileManager.default.createFile(atPath: selectedItemPath.path, contents: rawData, attributes: nil)
                
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)

            }

            thisAlertController.addAction(submitAction)

            present(thisAlertController, animated: true)

            
            
            
            
        } else {
            FileManager.default.createFile(atPath: selectedItemPath!, contents: rawData, attributes: nil)

            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "TextFileToPingtype") {
           let secondView = segue.destination as! InteractiveWebViewController
           let object = sender as! [String: Any?]
           secondView.text = object["text"] as? String
        }
        
    }

    func registerForKeyboardNotifications()
    {
        let notificationCenter = NotificationCenter.default
          
        notificationCenter.addObserver( self,
                                        selector: #selector(TextFileViewController.keyboardWillShow(_:)),
                                        name: UIResponder.keyboardWillShowNotification,
                                        object: nil )
          
        notificationCenter.addObserver( self,
                                        selector: #selector(TextFileViewController.keyboardWillBeHidden(_:)),
                                        name: UIResponder.keyboardWillHideNotification,
                                        object: nil)
    }
      

    func unregisterForKeyboardNotifications()
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(  self,
                                            name: UIResponder.keyboardWillShowNotification,
                                            object: nil)
          
        notificationCenter.removeObserver(  self,
                                            name: UIResponder.keyboardWillHideNotification,
                                            object: nil)
    }

    
    @objc func keyboardWillShow(_ notification: Notification)
    {
        //print("keyboardWillShow")
        let keyboardFrame: NSValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!
        let keyboardHeight = keyboardFrame.cgRectValue.height
        textArea.frame = CGRect(x: textArea.frame.minX,
                                y: textArea.frame.minY,
                                       width: textArea.frame.width,
                                       height: textArea.frame.height - keyboardHeight)
    }


    @objc func keyboardWillBeHidden(_ notification : NSNotification)
    {
        //print("keyboardWillBeHidden")
        let keyboardFrame: NSValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!
        let keyboardHeight = keyboardFrame.cgRectValue.height
        textArea.frame = CGRect(x: textArea.frame.minX,
                                y: textArea.frame.minY,
                                       width: textArea.frame.width,
                                       height: textArea.frame.height + keyboardHeight)

    }
    
    
    @objc func sceneViewPannedTwoFingers(sender: UIPanGestureRecognizer) {
        
        if (sender.state.rawValue == 3)
        {
            //print("two finger pan")
            
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    func clearKeyboard() {
        view.endEditing(true)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Handle two-finger pans
        let twoFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneViewPannedTwoFingers))
        thisView.addGestureRecognizer(twoFingerPanRecognizer)
        
        if (selectedItemPath == nil)
        {
            textArea.text = text
        } else {
            let textFileContents = FileManager.default.contents(atPath: selectedItemPath ?? "")
            let textFileContentsAsString = String(bytes: textFileContents!, encoding: .utf8)
            textArea.text = textFileContentsAsString
        }
        //print(textFileContentsAsString)
        
        registerForKeyboardNotifications()

    }

    
}
