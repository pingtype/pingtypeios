//
//  JPEGViewController.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 11/11/23.
//

import Foundation

import Foundation
import UIKit

class JPEGViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    @IBOutlet var thisView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var jpegImageView: UIImageView!
    
    var selectedItemPath: String?
    
    @objc func sceneViewPannedTwoFingers(sender: UIPanGestureRecognizer) {
        
        if (sender.state.rawValue == 3)
        {
            //print("two finger pan")
            
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
       
        return jpegImageView
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        // Handle two-finger pans
        let twoFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneViewPannedTwoFingers))
        thisView.addGestureRecognizer(twoFingerPanRecognizer)
        
        if (selectedItemPath != nil)
        {
            jpegImageView.image = UIImage(contentsOfFile: selectedItemPath ?? "")
            
        }

    }

}
