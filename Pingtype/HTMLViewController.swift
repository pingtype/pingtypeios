//
//  HTMLViewController.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 11/11/23.
//

import Foundation
import UIKit
import WebKit

class HTMLViewController: UIViewController, UIGestureRecognizerDelegate {
 
    @IBOutlet var thisView: UIView!
    
    @IBOutlet weak var htmlView: WKWebView!
    var selectedItemPath: String?

    @objc func sceneViewPannedTwoFingers(sender: UIPanGestureRecognizer) {
        
        if (sender.state.rawValue == 3)
        {
            //print("two finger pan")
            
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Handle two-finger pans
        let twoFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneViewPannedTwoFingers))
        thisView.addGestureRecognizer(twoFingerPanRecognizer)
        
        if (selectedItemPath != nil)
        {
            let htmlFileContents = FileManager.default.contents(atPath: selectedItemPath ?? "")
            let htmlFileContentsAsString = String(bytes: htmlFileContents!, encoding: .utf8)
            htmlView.loadHTMLString(htmlFileContentsAsString ?? "", baseURL: nil)
            
            //textArea.text = textFileContentsAsString
        }
        //print(textFileContentsAsString)
        

    }

    
}
