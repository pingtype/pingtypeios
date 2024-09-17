//
//  CountryViewController.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 24/02/24.
//

import Foundation
import UIKit
import WebKit


class CountryViewController: UIViewController, UIGestureRecognizerDelegate, WKNavigationDelegate {
    
    @IBOutlet var thisView: UIView!
    @IBOutlet weak var exitButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!

    var selectedItemPath: String?
    var countryText: String?

    lazy var webView: WKWebView = {
        let   webCfg:WKWebViewConfiguration = WKWebViewConfiguration()

        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - self.toolbar.frame.height), configuration: webCfg)
        return webView
    }()

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        var countryTextOneLine = (countryText?.replacingOccurrences(of: "\"", with: "\\\"") ?? "")
        countryTextOneLine = countryTextOneLine.replacingOccurrences(of: "\n", with: "\\n")
        countryTextOneLine = countryTextOneLine.replacingOccurrences(of: "\\underline", with: "\\\\underline")

        webView.evaluateJavaScript("countryText = \"" + countryTextOneLine + "\"") { (result, error) in
            if error == nil {
                //print(result ?? "")
            } else {
                
                print(error ?? "")
            }
        }

        webView.evaluateJavaScript("document.getElementById(\"body\").innerHTML = countryText;") { (result, error) in
            if error == nil {
                //print(result ?? "")
            } else {
                //self.webView.loadHTMLString(self.articleText!, baseURL: URL(string:"https://localhost:8080"))
                                
                print(error ?? "")
            }
        }

    }
    
    
    @objc func sceneViewPannedTwoFingers(sender: UIPanGestureRecognizer) {
        
        if (sender.state.rawValue == 3)
        {
            //print("two finger pan")
            
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
    }

    @objc func exitButtonClicked(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        webView.configuration.preferences.javaScriptEnabled = true
        self.view.addSubview(webView)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var fileURL = documentsPath.appendingPathComponent("Flags/Countries/" + selectedItemPath! + ".txt")
                
        webView.loadFileURL(fileURL, allowingReadAccessTo: documentsPath)

        webView.navigationDelegate = self
        exitButton.action = #selector(exitButtonClicked(sender:))

        
    }

    
    
}
