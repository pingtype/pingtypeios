//
//  WebViewController.swift
//  lyrics
//
//  Created by Peter Burkimsher on 30/10/23.
//

import UIKit
import WebKit

class BibleWebViewController: UIViewController {

    var translationName: String?
    var book: String?
    var chapter: Int?
    var chapterFile: String?

    @IBOutlet weak var bibleWebView: WKWebView!
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
        print("webview loaded")
        print("chapterFile: " + chapterFile!)
        print("Book:\(book ?? "") & chapter: \(chapter ?? 0)")
        //var htmlString = "<html><body>book: " + (book ?? "") + "/" + chapterFile! + "</body></html>"
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathString = "/" + translationName! + "/" + book! + "/" + chapterFile!
        let chapterFilePath = documentsPath.path + pathString

        let chapterFileContents = FileManager.default.contents(atPath: chapterFilePath)
        var chapterFileContentsAsString = String(bytes: chapterFileContents!, encoding: .utf8)
                
        chapterFileContentsAsString = chapterFileContentsAsString!.replacingOccurrences(of: "\n", with: "<br></br>")
        chapterFileContentsAsString = chapterFileContentsAsString!.replacingOccurrences(of: "\r", with: "<br></br>")

        var headers = "\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n         \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\">\n<head>\n  <title>Bible</title>\n<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">\n</head>\n\n<body><font face=sans-serif size=70pt>"
        
        for verse in 1..<177 {
            if (chapterFileContentsAsString!.contains(String(verse)))
            {
                headers = headers + "<a href=#" + String(verse) + ">" + String(verse) + "</a> "
                
                if let range = chapterFileContentsAsString!.range(of:"</br>" + String(verse)) {
                    chapterFileContentsAsString = chapterFileContentsAsString!.replacingCharacters(in: range, with:"</br><div id=" + String(verse) + ">" + String(verse) + "</div>")
                }
                
            }
        }
        
        chapterFileContentsAsString = headers + "<br></br>" + chapterFileContentsAsString! + "</font></body></html>"
        
        bibleWebView.loadHTMLString(chapterFileContentsAsString!, baseURL: URL(string:""))
        
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Handle two-finger pans
        let twoFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneViewPannedTwoFingers))
        thisView.addGestureRecognizer(twoFingerPanRecognizer)

    }


}
