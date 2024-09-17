//
//  RPlanViewController.swift
//  Lyrics
//
//  Created by Peter Burkimsher on 4/11/23.
//

import WebKit

class RPlanViewController: UIViewController, UIGestureRecognizerDelegate, WKNavigationDelegate {
 
    @IBOutlet weak var rplanWebView: WKWebView!
    @IBOutlet var thisView: UIView!
    
    @objc func sceneViewPannedTwoFingers(sender: UIPanGestureRecognizer) {
        
        if (sender.state.rawValue == 3)
        {
            //print("two finger pan")
            
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        guard let redirectURL = (navigationAction.request.url) else {
            decisionHandler(.cancel)
            return
        }
        
        print(redirectURL)
        
        UIApplication.shared.open(redirectURL, options: [:], completionHandler: nil)
//
//        if (redirectURL.absoluteString.contains("whatsapp") ) {
//            UIApplication.shared.open(redirectURL, options: [:], completionHandler: nil)
//        }
        
        decisionHandler(.allow)
    }
    
    override func viewDidLoad() {
        //print("webview loaded")

        rplanWebView.navigationDelegate = self
        rplanWebView.allowsBackForwardNavigationGestures = true
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let prefsFilePath = documentsPath.path + "/RPlan/" + "prefs.txt"

        let prefsFileContents = FileManager.default.contents(atPath: prefsFilePath)
        let prefsFileContentsAsString = String(bytes: prefsFileContents!, encoding: .utf8)
        
        let rpage = prefsFileContentsAsString!.textBetween("\nRPAGE=\"", and: "\"")
        
        let prefsLines = prefsFileContentsAsString!.components(separatedBy: "\n")
        
        let date = Date() // now
        let cal = Calendar.current
        let day = cal.ordinality(of: .day, in: .year, for: date)
        print("day = " + String(describing: day!))
        
        let book = prefsLines[0]
        let chapter = Int(prefsLines[1])! + day!
        let chapterString = String(describing: chapter)
        
        //let readingPlanFilePath = documentsPath.path + "/Laptop Bible/Other/" + "Bible Reading Plan.txt"
        let readingPlanFilePath = documentsPath.path + "/RPlan/" + "Bible Reading Plan.txt"

        let readingPlanContents = FileManager.default.contents(atPath: readingPlanFilePath)
        let readingPlanContentsAsString = String(bytes: readingPlanContents!, encoding: .macOSRoman)
        //let readingPlanContentsAsString = String(bytes: readingPlanContents!, encoding: .utf8)
        let readingPlanLines = readingPlanContentsAsString!.components(separatedBy: "\n")
        
        let readingPlanOffset = (Int(prefsLines[3])! + day! + 4) * 2
        
        let readingPlanQuestion = readingPlanLines[readingPlanOffset] + "</p><p>" + readingPlanLines[readingPlanOffset + 1]
        //let readingPlanQuestion = "Reading Plan"
        
        let homeDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "dd MMM YYYY"

        // Convert Date to String
        let dateString = dateFormatter.string(from: date)
        
        do {
            try FileManager.default.removeItem(atPath: homeDirectory.path + "/" + dateString)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        do {
            try FileManager.default.createDirectory(atPath: homeDirectory.path + "/" + dateString, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }

        let bookFolders = try! FileManager.default.contentsOfDirectory(atPath: homeDirectory.path + "/RPlan/Laptop Bible")
                
        if bookFolders.count > 0
        {
            for bookFolder in bookFolders
            {
                if (bookFolder.debugDescription.contains(book))
                {
                    let chapterFiles = try! FileManager.default.contentsOfDirectory(atPath: homeDirectory.path + "/RPlan/Laptop Bible/" + bookFolder)
                    
                    if chapterFiles.count > 0
                    {
                        for chapterFile in chapterFiles
                        {
                            if (chapterFile.debugDescription.contains(chapterString + ",") || chapterFile.debugDescription.contains(chapterString + "_"))
                            {
                                let originPath = homeDirectory.path + "/RPlan/Laptop Bible/" + bookFolder + "/" + chapterFile
                                let destinationPath = homeDirectory.path + "/" + dateString + "/1. " + chapterFile
                                try! FileManager.default.copyItem(atPath: originPath, toPath: destinationPath)
                                
                            }
                        }
                    }
                }
            }
        }
        
        
        
        let originPath = homeDirectory.path + "/RPlan/Laptop Bible/68. Outro/" + rpage
        let destinationPath = homeDirectory.path + "/" + dateString + "/1. " + rpage
        try! FileManager.default.copyItem(atPath: originPath, toPath: destinationPath)

        let readingPlanQuestionLines = readingPlanQuestion.components(separatedBy: "\n")
        let readingPlanFirstLine = readingPlanQuestionLines[0]
        let readingPlanFirstLineSegments = readingPlanFirstLine.components(separatedBy: ":")
        let readingPlanBookChapter = readingPlanFirstLineSegments[0]
        let readingPlanBookChapterSegments = readingPlanBookChapter.components(separatedBy: " ")
        let readingPlanBook = readingPlanBookChapterSegments[0]
        let readingPlanChapter = readingPlanBookChapterSegments[1]
        
        if bookFolders.count > 0
        {
            for bookFolder in bookFolders
            {
                if (bookFolder.debugDescription.contains(readingPlanBook))
                {
                    let chapterFiles = try! FileManager.default.contentsOfDirectory(atPath: homeDirectory.path + "/RPlan/Laptop Bible/" + bookFolder)
                    
                    if chapterFiles.count > 0
                    {
                        for chapterFile in chapterFiles
                        {
                            if (chapterFile.debugDescription.contains(readingPlanChapter + ",") || chapterFile.debugDescription.contains(readingPlanChapter + "_"))
                            {
                                let originPath = homeDirectory.path + "/RPlan/Laptop Bible/" + bookFolder + "/" + chapterFile
                                let destinationPath = homeDirectory.path + "/" + dateString + "/2. " + chapterFile
                                try! FileManager.default.copyItem(atPath: originPath, toPath: destinationPath)
                                
                            }
                        }
                    }
                }
            }
        }

        let originPathRPlan = homeDirectory.path + "/RPlan/Laptop Bible/68. Outro/" + rpage
        let destinationPathRPlan = homeDirectory.path + "/" + dateString + "/2. " + rpage
        try! FileManager.default.copyItem(atPath: originPathRPlan, toPath: destinationPathRPlan)
        
        //let path = "shareddocuments://" + (homeDirectory.path) + "/" + dateString
        
        let headers = "\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n         \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\">\n<head>\n  <title>Bible</title>\n<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">\n</head>\n\n<body><font face=sans-serif size=70pt>"
        
        let friendsFilePath = documentsPath.path + "/RPlan/" + "names.html"

        let friendsContents = FileManager.default.contents(atPath: friendsFilePath)
        let friendsContentsAsString = String(bytes: friendsContents!, encoding: .utf8)
        let friendsLines = friendsContentsAsString!.components(separatedBy: "\n")
        
        let friendsOffsetEnd = (Int(prefsLines[7])! + day!) * 20 + 1
        let friendsOffsetStart = friendsOffsetEnd - 21
        var friendsString = ""
        for currentFriend in friendsOffsetStart..<friendsOffsetEnd {
            let friendLine = friendsLines[currentFriend]
            friendsString.append("<tr><td>" + friendLine + "</td></tr>")
        }
        
        rplanWebView.loadHTMLString(headers + book + " " + chapterString + "</p><p>" + readingPlanQuestion + "</p><table>" + friendsString + "</table></body></html>", baseURL: nil)

        
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Handle two-finger pans
        let twoFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneViewPannedTwoFingers))
        thisView.addGestureRecognizer(twoFingerPanRecognizer)
        
    }

    
}
