import UIKit
import WebKit

class InteractiveWebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    
    var text: String?

    @IBOutlet weak var exitButton: UIBarButtonItem!
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
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self

        return webView
    }()

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

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
                
                webView.evaluateJavaScript("combinedDictionaryData = \"" + dictionaryFileContentsAsStringOneLine + "\"") { (result, error) in
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
                
                webView.evaluateJavaScript("radicals = \"" + radicalsFileContentsAsStringOneLine + "\"") { (result, error) in
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
                
                webView.evaluateJavaScript("compositionData = \"" + compositionFileContentsAsStringOneLine + "\"") { (result, error) in
                    if error == nil {
                        //print(result ?? "")
                    } else {
                        print(error ?? "")
                    }
                }

                
                webView.evaluateJavaScript("dictionariesLoaded();") { (result, error) in
                    if error == nil {
                        print(result ?? "")
                    } else {
                        print(error ?? "")
                    }
                }

                var textSingleLine = (text ?? "").replacingOccurrences(of: "\n", with: "\\n")
                textSingleLine = textSingleLine.replacingOccurrences(of: "\r", with: "\\n")
                textSingleLine = textSingleLine.replacingOccurrences(of: "'", with: "\\\'")
                textSingleLine = textSingleLine.replacingOccurrences(of: "\"", with: "\\\"")
                print("document.getElementById(\"chineseTextArea\").value = \"" + textSingleLine + "\"")
                webView.evaluateJavaScript("document.getElementById(\"chineseTextArea\").value = \"" + textSingleLine + "\"") { (result, error) in
                    if error == nil {
                        print(result ?? "")
                    } else {
                        print(error ?? "")
                    }
                }

                webView.evaluateJavaScript("translateButtonClicked();") { (result, error) in
                    if error == nil {
                        print(result ?? "")
                    } else {
                        print(error ?? "")
                    }
                }

                        
    }

    
    @objc func buttonClicked(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.configuration.preferences.javaScriptEnabled = true
        self.view.addSubview(webView)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var fileURL = documentsPath.appendingPathComponent("pingtype/index.html")
                
        if (FileManager.default.fileExists(atPath: fileURL.path))
        {
            print("user-submitted pingtype")
            webView.loadFileURL(fileURL, allowingReadAccessTo: documentsPath)
        } else {
            print("built-in pingtype")
            
            fileURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "www")!
            print(fileURL)
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }

        webView.navigationDelegate = self

        exitButton.action = #selector(buttonClicked(sender:))

        
    }


    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "jsHandler" {
            print(message.body)
        }
        
        let bodyString = message.body as? String
        
        if ((bodyString ?? "").contains("filenamesButtonClicked"))
        {
            
            webView.evaluateJavaScript("document.getElementById(\"chineseTextArea\").value") { (result, error) in
                if error == nil {
                    print(result ?? "")
                    
                    let searchTextSender: [String: Any?] = ["searchText": result]
                    
                    self.performSegue(withIdentifier: "filenamesButtonClicked", sender: searchTextSender)
                    
                } else {
                    print(error ?? "")
                }
            }
        }


        if ((bodyString ?? "").contains("lyricsButtonClicked"))
        {
            
            webView.evaluateJavaScript("document.getElementById(\"chineseTextArea\").value") { (result, error) in
                if error == nil {
                    print(result ?? "")
                    
                    let searchTextSender: [String: Any?] = ["searchText": result]
                    
                    self.performSegue(withIdentifier: "lyricsButtonClicked", sender: searchTextSender)
                    
                } else {
                    print(error ?? "")
                }
            }
        }

        if ((bodyString ?? "").contains("saveTextFile"))
        {
            
            webView.evaluateJavaScript("document.getElementById(\"chineseTextArea\").value") { (result, error) in
                if error == nil {
                    print(result ?? "")
                    
                    let searchTextSender: [String: Any?] = ["text": result]
                    
                    self.performSegue(withIdentifier: "saveTextFile", sender: searchTextSender)
                    
                } else {
                    print(error ?? "")
                }
            }
        }

        if ((bodyString ?? "").contains("loadTaiwanese"))
        {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            let taiwaneseFilePath = documentsPath.path + "/pingtype/TaiwaneseDictionaryTaiyuNumbers.txt"
            var taiwaneseFileContentsAsString = ""
            if (FileManager.default.fileExists(atPath: taiwaneseFilePath))
            {
                print("user-submitted taiwanese")
                let taiwaneseFileContents = FileManager.default.contents(atPath: taiwaneseFilePath)
                taiwaneseFileContentsAsString = String(bytes: taiwaneseFileContents!, encoding: .utf8) ?? ""
            } else {
                print("built-in taiwanese")
                
                let taiwaneseFileURL = Bundle.main.url(forResource: "TaiwaneseDictionaryTaiyuNumbers", withExtension: "txt", subdirectory: "www")!
                print(taiwaneseFileURL)
                let taiwaneseFileContents = FileManager.default.contents(atPath: taiwaneseFileURL.path)
                taiwaneseFileContentsAsString = String(bytes: taiwaneseFileContents!, encoding: .utf8) ?? ""
            }

                            
            let taiwaneseFileContentsAsStringOneLine = taiwaneseFileContentsAsString.replacingOccurrences(of: "\n", with: "\\n")
            
            webView.evaluateJavaScript("taiwaneseData = \"" + taiwaneseFileContentsAsStringOneLine + "\"") { (result, error) in
                if error == nil {
                    //print(result ?? "")
                } else {
                    print(error ?? "")
                }
            }

            webView.evaluateJavaScript("taiwaneseToWordLengths();") { (result, error) in
                if error == nil {
                    //print(result ?? "")
                } else {
                    print(error ?? "")
                }
            }

            webView.evaluateJavaScript("wordSpaceButtonClicked();") { (result, error) in
                if error == nil {
                    //print(result ?? "")
                } else {
                    print(error ?? "")
                }
            }

            webView.evaluateJavaScript("taiwaneseCheckboxClicked('taiwaneseCheckbox');") { (result, error) in
                if error == nil {
                    //print(result ?? "")
                } else {
                    print(error ?? "")
                }
            }

            
            webView.evaluateJavaScript("translateBilingualInterface();") { (result, error) in
                if error == nil {
                    //print(result ?? "")
                } else {
                    print(error ?? "")
                }
            }

            webView.evaluateJavaScript("taiwaneseColours();") { (result, error) in
                if error == nil {
                    //print(result ?? "")
                } else {
                    print(error ?? "")
                }
            }

            
        }


    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "filenamesButtonClicked") {
          let secondView = segue.destination as! FilenamesTableViewController
          let object = sender as! [String: Any?]
          secondView.searchText = object["searchText"] as? String
       }
        
        if (segue.identifier == "lyricsButtonClicked") {
           let secondView = segue.destination as! LyricsTableViewController
           let object = sender as! [String: Any?]
           secondView.searchText = object["searchText"] as? String
        }
        
        if (segue.identifier == "lyricsButtonClicked") {
           let secondView = segue.destination as! LyricsTableViewController
           let object = sender as! [String: Any?]
           secondView.searchText = object["searchText"] as? String
        }
        
        if (segue.identifier == "saveTextFile") {
           let secondView = segue.destination as! TextFileViewController
           let object = sender as! [String: Any?]
           secondView.text = object["text"] as? String
        }

        
        


    }

    

    
}
