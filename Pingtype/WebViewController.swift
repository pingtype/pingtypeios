//
//  WebViewController.swift
//  Lyrics
//
//  Created by Peter Burkimsher on 31/10/23.
//

import UIKit
import WebKit

class WebViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var lyricsFile: String?
    
    @IBOutlet weak var lyricsWebView: WKWebView!
    @IBOutlet var thisView: UIView!
    
    @objc func sceneViewPannedTwoFingers(sender: UIPanGestureRecognizer) {
        
        if (sender.state.rawValue == 3)
        {
            //print("two finger pan")
            
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        //print("webview loaded")

        lyricsFile = lyricsFile!.replacingOccurrences(of: ".txt", with: ".html")
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathString = "/Cache/" + lyricsFile!
        let lyricsFilePath = documentsPath.path + pathString

        print(lyricsFilePath)
        
        let lyricsFileContents = FileManager.default.contents(atPath: lyricsFilePath)
        let lyricsFileContentsAsString = String(bytes: lyricsFileContents!, encoding: .utf8)

        lyricsWebView.loadHTMLString(lyricsFileContentsAsString!, baseURL: URL(string:""))
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Handle two-finger pans
        let twoFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneViewPannedTwoFingers))
        thisView.addGestureRecognizer(twoFingerPanRecognizer)
        
    }

    
}
