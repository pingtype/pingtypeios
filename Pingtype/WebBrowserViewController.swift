//
//  WebBrowserViewController.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 9/11/23.
//

import UIKit
import WebKit

class WebBrowserViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    
    var searchText: String?

    var text: String?

    @IBOutlet weak var exitButton: UIBarButtonItem!
    @IBOutlet weak var pingtypeButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    lazy var webView: WKWebView = {
        let   webCfg:WKWebViewConfiguration = WKWebViewConfiguration()

        // Setup WKUserContentController instance for injecting user script
        var userController:WKUserContentController = WKUserContentController()

        // Add a script message handler for receiving  "buttonClicked" event notifications posted from the JS document using  window.webkit.messageHandlers.postMessageListener.postMessage(JSON.stringify({data})) script message
        userController.add(self, name: "jsHandler")
        // Configure the WKWebViewConfiguration instance with the WKUserContentController
        webCfg.userContentController = userController;

        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - self.toolbar.frame.height), configuration: webCfg)
        return webView
    }()

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

                        
    }

    
    @objc func exitButtonClicked(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

    @objc func pingtypeButtonClicked(sender: UIBarButtonItem) {
     
        
        webView.evaluateJavaScript("document.body.innerText") { (result, error) in
            if error == nil {
                print(result ?? "")
                
                let searchTextSender: [String: Any?] = ["text": result]
                
                self.performSegue(withIdentifier: "webBrowserToPingtype", sender: searchTextSender)
                
            } else {
                print(error ?? "")
            }
        }
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "webBrowserToPingtype") {
           let secondView = segue.destination as! InteractiveWebViewController
           let object = sender as! [String: Any?]
           secondView.text = object["text"] as? String
        }

    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.configuration.preferences.javaScriptEnabled = true
        self.view.addSubview(webView)
        
//        let urlString = "https://www.google.com/search?q=" + (searchText ?? "")
//        print(urlString)
//        let url = URL (string: urlString)
        
        let txtAppend = (searchText ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let urlString = "https://www.google.com/search?q=\(txtAppend!)"
        let openUrl = URL(string: urlString)

        let requestObj = URLRequest(url: openUrl!)
        webView.load(requestObj)

        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true

        exitButton.action = #selector(exitButtonClicked(sender:))
        pingtypeButton.action = #selector(pingtypeButtonClicked(sender:))

        
    }


    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "jsHandler" {
            print(message.body)
        }
        
        let bodyString = message.body as? String
        

    }
    

    
}
