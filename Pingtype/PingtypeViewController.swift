//
//  PingtypeViewController.swift
//  Lyrics
//
//  Created by Peter Burkimsher on 4/11/23.
//

import UIKit
import WebKit

class PingtypeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var text: String?
    
    @IBOutlet weak var pingtypeWebView: WKWebView!
    @IBOutlet var thisView: UIView!
    @IBOutlet weak var cacheButton: UIBarButtonItem!
    
    @objc func sceneViewPannedTwoFingers(sender: UIPanGestureRecognizer) {
        
        if (sender.state.rawValue == 3)
        {
            //print("two finger pan")
            
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print(Float(pingtypeWebView.estimatedProgress))
            
            if (Float(pingtypeWebView.estimatedProgress) == 1.0)
            {
                
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let dictionaryFilePath = documentsPath.path + "/pingtype/PinyinDefinitionsTonesSorted.txt"
                var dictionaryFileContentsAsString = ""
                if (FileManager.default.fileExists(atPath: dictionaryFilePath))
                {
                    print("user-submitted dictionary")
                    let dictionaryFileContents = FileManager.default.contents(atPath: dictionaryFilePath)
                    dictionaryFileContentsAsString = String(bytes: dictionaryFileContents!, encoding: .utf8) ?? ""
                } else {
                    print("built-in dictionary")
                    
                    let dictionaryFileURL = Bundle.main.url(forResource: "PinyinDefinitionsTonesSorted", withExtension: "txt", subdirectory: "www")!
                    print(dictionaryFileURL)
                    let dictionaryFileContents = FileManager.default.contents(atPath: dictionaryFileURL.path)
                    dictionaryFileContentsAsString = String(bytes: dictionaryFileContents!, encoding: .utf8) ?? ""
                }
                                
                let dictionaryFileContentsAsStringOneLine = dictionaryFileContentsAsString.replacingOccurrences(of: "\n", with: "\\n")
                
                pingtypeWebView.evaluateJavaScript("combinedDictionaryData = \"" + dictionaryFileContentsAsStringOneLine + "\"") { (result, error) in
                    if error == nil {
                        //print(result ?? "")
                    } else {
                        print(error ?? "")
                    }
                }
                
                let radicalsFilePath = documentsPath.path + "/pingtype/radicals.txt"
                var radicalsFileContentsAsString = ""
                if (FileManager.default.fileExists(atPath: radicalsFilePath))
                {
                    print("user-submitted radicals")
                    let radicalsFileContents = FileManager.default.contents(atPath: radicalsFilePath)
                    radicalsFileContentsAsString = String(bytes: radicalsFileContents!, encoding: .utf8) ?? ""
                } else {
                    print("built-in radicals")
                    
                    let radicalsFileURL = Bundle.main.url(forResource: "radicals", withExtension: "txt", subdirectory: "www")!
                    print(radicalsFileURL)
                    let radicalsFileContents = FileManager.default.contents(atPath: radicalsFileURL.path)
                    radicalsFileContentsAsString = String(bytes: radicalsFileContents!, encoding: .utf8) ?? ""
                }

                                
                let radicalsFileContentsAsStringOneLine = radicalsFileContentsAsString.replacingOccurrences(of: "\n", with: "\\n")
                
                pingtypeWebView.evaluateJavaScript("radicals = \"" + radicalsFileContentsAsStringOneLine + "\"") { (result, error) in
                    if error == nil {
                        //print(result ?? "")
                    } else {
                        print(error ?? "")
                    }
                }
                
                let compositionFilePath = documentsPath.path + "/pingtype/cjk-decomp-0.4.0.txt"
                var compositionFileContentsAsString = ""
                if (FileManager.default.fileExists(atPath: compositionFilePath))
                {
                    print("user-submitted composition")
                    let compositionFileContents = FileManager.default.contents(atPath: compositionFilePath)
                    compositionFileContentsAsString = String(bytes: compositionFileContents!, encoding: .utf8) ?? ""
                } else {
                    print("built-in composition")
                    
                    let compositionFileURL = Bundle.main.url(forResource: "cjk-decomp-0.4.0", withExtension: "txt", subdirectory: "www")!
                    print(compositionFileURL)
                    let compositionFileContents = FileManager.default.contents(atPath: compositionFileURL.path)
                    compositionFileContentsAsString = String(bytes: compositionFileContents!, encoding: .utf8) ?? ""
                }

                                
                let compositionFileContentsAsStringOneLine = compositionFileContentsAsString.replacingOccurrences(of: "\n", with: "\\n")
                
                pingtypeWebView.evaluateJavaScript("compositionData = \"" + compositionFileContentsAsStringOneLine + "\"") { (result, error) in
                    if error == nil {
                        //print(result ?? "")
                    } else {
                        print(error ?? "")
                    }
                }

                pingtypeWebView.evaluateJavaScript("dictionariesLoaded();") { (result, error) in
                    if error == nil {
                        print(result ?? "")
                    } else {
                        print(error ?? "")
                    }
                }
                var textSingleLine = (text ?? "").replacingOccurrences(of: "\n", with: "\\n")
                textSingleLine = textSingleLine.replacingOccurrences(of: "'", with: "\\\'")
                textSingleLine = textSingleLine.replacingOccurrences(of: "\"", with: "\\\"")
                //print("document.getElementById(\"chineseTextArea\").value = \"" + textSingleLine + "\"")
                pingtypeWebView.evaluateJavaScript("document.getElementById(\"chineseTextArea\").value = \"" + textSingleLine + "\"") { (result, error) in
                    if error == nil {
                        print(result ?? "")
                    } else {
                        print(error ?? "")
                    }
                }

                pingtypeWebView.evaluateJavaScript("translateButtonClicked();") { (result, error) in
                    if error == nil {
                        print(result ?? "")
                    } else {
                        print(error ?? "")
                    }
                }

                
            } // end if estimated progress is 1
            
        }
    }
    
    @objc func buttonClicked(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        //print("webview loaded")

        //pingtypeWebView.loadHTMLString(text ?? "", baseURL: URL(string:""))
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var fileURL = documentsPath.appendingPathComponent("pingtype/index.html")
                
        if (FileManager.default.fileExists(atPath: fileURL.path))
        {
            print("user-submitted pingtype")
            pingtypeWebView.loadFileURL(fileURL, allowingReadAccessTo: documentsPath)
        } else {
            print("built-in pingtype")
            
            fileURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "www")!
            print(fileURL)
            pingtypeWebView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }
        
        pingtypeWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        print("text")
        print(text ?? "")
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Handle two-finger pans
        let twoFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneViewPannedTwoFingers))
        thisView.addGestureRecognizer(twoFingerPanRecognizer)
        
        cacheButton.action = #selector(buttonClicked(sender:))
        
    }

    
}
