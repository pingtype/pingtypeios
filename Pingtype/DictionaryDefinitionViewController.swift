//
//  DictionaryDefinitionViewController.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 18/11/23.
//

import Foundation
import UIKit
import SWCompression
import WebKit

class DictionaryDefinitionViewController: UIViewController, UIGestureRecognizerDelegate, WKScriptMessageHandler, WKNavigationDelegate {
    
    @IBOutlet var thisView: UIView!
    @IBOutlet weak var exitButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var selectedItemPath: String?
    var searchString: String?
    var definitionText: String?
    var thisTitle: String?
    var fileSize: UInt64?
    
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

        var defintionTextOneLine = (definitionText?.replacingOccurrences(of: "\"", with: "\\\"") ?? "")
        defintionTextOneLine = defintionTextOneLine.replacingOccurrences(of: "\n", with: "\\n")
        
        print("defintionTextOneLine")
        print(defintionTextOneLine)
        
        webView.evaluateJavaScript("definitionText = \"" + defintionTextOneLine + "\"") { (result, error) in
            if error == nil {
                //print(result ?? "")
            } else {
                print(error ?? "")
            }
        }

        webView.evaluateJavaScript("document.getElementById(\"definitionText\").innerHTML = parse(definitionText);") { (result, error) in
            if error == nil {
                //print(result ?? "")
            } else {
                print(error ?? "")
            }
        }

    }

    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "jsHandler" {
            print(message.body)
        }
        
        //let bodyString = message.body as? String
        
    }

    
    
    @objc func sceneViewPannedTwoFingers(sender: UIPanGestureRecognizer) {
        
        if (sender.state.rawValue == 3)
        {
            //print("two finger pan")
            
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
    }

    func findDefinitionEnd(blockData: Data) -> Int
    {
        var endBuffer = 0
        for currentIndex in stride(from: blockData.count - 1, through: 0, by: -1)
        {
            //print (currentIndex, " ", blockData[currentIndex])
            if (blockData[currentIndex] == 10)
            {
                endBuffer = currentIndex
                break
            }
        }
        
        return endBuffer
    }

    
    func readBlock(thisBound: UInt64)
    {
        do
        {
            var blockData = Data([])
            guard let blockFileHandle = FileHandle(forReadingAtPath: selectedItemPath! + "/dictionary.txt") else { throw NSError() }
            var blockBytesOffset = thisBound
            blockFileHandle.seek(toFileOffset: blockBytesOffset)
            let bufferLength = 32767
            //let bufferLength = 65536
            //let bufferLength = 65536 * 4
            //let bufferLength = 65536 * 8
            //blockData.append(blockFileHandle.readData(ofLength: bufferLength))
            
            var endBuffer = 0
            while (endBuffer == 0)
            {
                if (blockBytesOffset > fileSize!)
                {
                    break
                }
                
                blockFileHandle.seek(toFileOffset: blockBytesOffset)
                blockData.append(blockFileHandle.readData(ofLength: bufferLength))
                endBuffer = findDefinitionEnd(blockData: blockData)
                blockBytesOffset = blockBytesOffset + UInt64(bufferLength)
                
            }

            
//            blockFileHandle.seek(toFileOffset: blockBytesOffset)
//            blockData.append(blockFileHandle.readData(ofLength: bufferLength))
//            
//            blockBytesOffset = blockBytesOffset + UInt64(bufferLength)
            
            //let blockData = blockFileHandle.readDataToEndOfFile()
            blockFileHandle.closeFile()
            
                        
            let blockDataString = String(data: blockData, encoding: .utf8)
            
            print("blockDataString")
            print(blockDataString)
            
            
            
            if ((blockDataString ?? "").contains("\n" + searchString! + "\t"))
            {
                definitionText = blockDataString!.textBetween("\n" + searchString! + "\t", and: "\n")
            }
            
            thisTitle = (blockDataString ?? "").textBetween("\n", and: "\t")
            print("thisTitle")
            print(thisTitle)
            
            
        } catch {
            print ("error loading block")
        }

    }
    
    func loadDefinition()
    {
        var lowerBound = UInt64(0)
        fileSize = UInt64(FileManager.default.sizeOfFile(atPath: selectedItemPath! + "/dictionary.txt")!)
        var upperBound = fileSize!
        
        var thisBound = (lowerBound + upperBound) / 2
        
        while (lowerBound <= upperBound)
        {
            thisBound = (lowerBound + upperBound) / 2
            //                articleNumber = 2048
            print ("thisBound")
            print (thisBound)
            
            readBlock(thisBound: thisBound)
            
            if (searchString!.localizedCaseInsensitiveCompare(thisTitle!) == .orderedAscending)
            {
                print(searchString!, " before ", thisTitle!)
                upperBound = thisBound - 1
            }
            
            if (searchString!.localizedCaseInsensitiveCompare(thisTitle!) == .orderedSame)
            {
                print(searchString!, " found ", thisTitle!)
                lowerBound = upperBound + 1
            }
            
            if (searchString!.localizedCaseInsensitiveCompare(thisTitle!) == .orderedDescending)
            {
                print(searchString!, " after ", thisTitle!)
                lowerBound = thisBound + 1
            }
        }
        
    }
    
    func grepDefinition()
    {
        let pathURL = URL(fileURLWithPath: selectedItemPath! + "/dictionary.txt")
        print(pathURL)
        let s = StreamReader(url: pathURL)
        var str : String = ""
        var strArray : [String] = []
        
        func printData(offset: UInt64) {
            str = ""
            s?.setoffset(offset: offset)
            while true {
                if let line = s?.nextLine() {
                    if line.contains("\t") {
                        str.append(line)
                        str.append("\n")
                        break
                    }
                    else {
                        str.append(line)
                        str.append("\n")
                    }
                }
            }
            if let line = s?.nextLine() {
                str.append(line)
                str.append("\n")
            }
            strArray.append(str)
            
        }
        
        if FileManager.default.fileExists(atPath: pathURL.path) { print(1) }
        
        while true {
            if let line = s?.nextLine() {
                if (line.starts(with: searchString ?? "" + "\t")) {
                    //printData(offset: s?.offsetvalue() ?? 0)
                    print(line)
                    //textArea.text = line
                    definitionText = line

                    break
                }
            }
            else {
                break
            }
        }
        
        for i in strArray {
            print(i)
        }
        
    }
    
    @objc func exitButtonClicked(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        //loadDefinition()
        grepDefinition()
                
        webView.configuration.preferences.javaScriptEnabled = true
        self.view.addSubview(webView)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var fileURL = documentsPath.appendingPathComponent("Dictionaries/parser.html")
        
        if (FileManager.default.fileExists(atPath: fileURL.path))
        {
            print("user-submitted parser")
            webView.loadFileURL(fileURL, allowingReadAccessTo: documentsPath)
        } else {
            print("built-in parser")
            
            fileURL = Bundle.main.url(forResource: "dictionariesParser", withExtension: "html", subdirectory: "www")!
            print(fileURL)
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }

        webView.navigationDelegate = self
        exitButton.action = #selector(exitButtonClicked(sender:))

        
    }

    
}

extension FileManager {
    func sizeOfFile(atPath path: String) -> Int64? {
        guard let attrs = try? attributesOfItem(atPath: path) else {
            return nil
        }

        return attrs[.size] as? Int64
    }
}
