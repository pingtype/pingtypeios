//
//  WikiArticleViewController.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 15/11/23.
//

import Foundation
import UIKit
import SWCompression
import WebKit


class WikiArticleViewController: UIViewController, UIGestureRecognizerDelegate, WKScriptMessageHandler, WKNavigationDelegate {
    
    @IBOutlet var thisView: UIView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var exitButton: UIBarButtonItem!
    @IBOutlet weak var textButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!

    var selectedItemPath: String?
    var searchString: String?
    
    var indexPos_0: UInt64?
    var lastBlockPos: UInt64?
    var lastArticlePos: UInt32?
    var lastArticleLength: UInt32?
    var thisTitle: String?
    var titlesPos: UInt64?
    var numberOfArticles: UInt32?

    var articleText: String?
    
    var titles: Array<String> = []
    
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

        var articleTextOneLine = (articleText?.replacingOccurrences(of: "\"", with: "\\\"") ?? "")
        articleTextOneLine = articleTextOneLine.replacingOccurrences(of: "\n", with: "\\n")
        articleTextOneLine = articleTextOneLine.replacingOccurrences(of: "\\underline", with: "\\\\underline")

        webView.evaluateJavaScript("articleText = \"" + articleTextOneLine + "\"") { (result, error) in
            if error == nil {
                //print(result ?? "")
            } else {
                
                print(error ?? "")
            }
        }

        webView.evaluateJavaScript("document.getElementById(\"article\").innerHTML = wiki2html(articleText);") { (result, error) in
            if error == nil {
                //print(result ?? "")
            } else {
                //self.webView.loadHTMLString(self.articleText!, baseURL: URL(string:"https://localhost:8080"))
                                
                print(error ?? "")
            }
        }

    }

    func readTitle(indexPos_0: UInt64, titlesPos: UInt64, articleNumber: UInt64) throws
    {
        guard let indexFileHandle = FileHandle(forReadingAtPath: selectedItemPath! + "/articles.bin") else { throw NSError() }
        let indexBytesOffset = UInt64(indexPos_0) + UInt64(articleNumber) * 4 // 4 is sizeof(Int)
        indexFileHandle.seek(toFileOffset: indexBytesOffset)
        let indexTitleData = indexFileHandle.readData(ofLength: 4)
        indexFileHandle.closeFile()

        let titlePos =
        (UInt32(indexTitleData[0]) << (0*8)) | // shifted by zero bits (not shifted)
        (UInt32(indexTitleData[1]) << (1*8)) | // shifted by 8 bits
        (UInt32(indexTitleData[2]) << (2*8)) | // shifted by 16 bits
        (UInt32(indexTitleData[3]) << (3*8))   // shifted by 24 bits

        //print("titlePos")
        //print(titlePos)
        
        guard let titleFileHandle = FileHandle(forReadingAtPath: selectedItemPath! + "/articles.bin") else { throw NSError() }
        let titleBytesOffset = UInt64(titlesPos) + UInt64(titlePos)
        titleFileHandle.seek(toFileOffset: titleBytesOffset)
        let titleData = titleFileHandle.readData(ofLength: 256)
        titleFileHandle.closeFile()
        
        let lastBlockPos_lower =
        (UInt64(titleData[0]) << (0*8)) | // shifted by zero bits (not shifted)
        (UInt64(titleData[1]) << (1*8)) | // shifted by 8 bits
        (UInt64(titleData[2]) << (2*8)) | // shifted by 16 bits
        (UInt64(titleData[3]) << (3*8))   // shifted by 24 bits
        
        let lastBlockPos_upper =
                (UInt64(titleData[4]) << (4*8)) |
                (UInt64(titleData[5]) << (5*8)) |
                (UInt64(titleData[6]) << (6*8)) |
                (UInt64(titleData[7]) << (7*8))
        
        lastBlockPos = lastBlockPos_lower | lastBlockPos_upper

        //print("lastBlockPos")
        //print(lastBlockPos)
        
        lastArticlePos =
        (UInt32(titleData[8]) << (0*8)) | // shifted by zero bits (not shifted)
        (UInt32(titleData[9]) << (1*8)) | // shifted by 8 bits
        (UInt32(titleData[10]) << (2*8)) | // shifted by 16 bits
        (UInt32(titleData[11]) << (3*8))   // shifted by 24 bits

        //print("lastArticlePos")
        //print(lastArticlePos)

        lastArticleLength =
        (UInt32(titleData[12]) << (0*8)) | // shifted by zero bits (not shifted)
        (UInt32(titleData[13]) << (1*8)) | // shifted by 8 bits
        (UInt32(titleData[14]) << (2*8)) | // shifted by 16 bits
        (UInt32(titleData[15]) << (3*8))   // shifted by 24 bits

        //print("lastArticleLength")
        //print(lastArticleLength)

        var endIndex = 16
        for currentIndex in 16..<256
        {
            if (titleData[currentIndex] == 0)
            {
                endIndex = currentIndex
                break
            }
        }
        
        //let slice = titleData.dropFirst(16)
        //let titleDataSliced = Data(slice)
        let titleDataSliced = titleData[16..<endIndex]
        thisTitle = String(decoding: titleDataSliced, as: UTF8.self)

        print("thisTitle")
        print(thisTitle)

    }

    func findTitle(searchTitle: String)
    {
        var lowerBound = 0
        var upperBound = Int(numberOfArticles!)
        
        var articleNumber = (lowerBound + upperBound) / 2
        
        while (lowerBound <= upperBound)
        {
            articleNumber = (lowerBound + upperBound) / 2
            //                articleNumber = 2048
            //print ("articleNumber")
            //print (articleNumber)
            
            try? readTitle(indexPos_0: UInt64(indexPos_0!), titlesPos: UInt64(titlesPos!), articleNumber: UInt64(articleNumber))
            
            //if (searchTitle.localizedCaseInsensitiveCompare(thisTitle!) == .orderedAscending)
            if (searchTitle.forSorting().localizedStandardCompare(thisTitle!.forSorting()) == .orderedAscending)
            {
                print(searchTitle, " before ", thisTitle!)
                upperBound = articleNumber - 1
            }
            
            //if (searchTitle.localizedCaseInsensitiveCompare(thisTitle!) == .orderedSame)
            if (searchTitle.forSorting().localizedStandardCompare(thisTitle!.forSorting()) == .orderedSame)
            {
                print(searchTitle, " found ", thisTitle!)
                lowerBound = upperBound + 1
            }
            
            //if (searchTitle.localizedCaseInsensitiveCompare(thisTitle!) == .orderedDescending)
            if (searchTitle.forSorting().localizedStandardCompare(thisTitle!.forSorting()) == .orderedDescending)
            {
                print(searchTitle, " after ", thisTitle!)
                lowerBound = articleNumber + 1
            }
        }
        
        //                try? readTitle(indexPos_0: UInt64(indexPos_0), titlesPos: UInt64(titlesPos), articleNumber: UInt64(0))
        
        var resultArticleNumber = articleNumber
        //while (searchTitle.caseInsensitiveCompare(thisTitle!) == .orderedSame)
        while (searchTitle.forSorting().localizedStandardCompare(thisTitle!.forSorting()) == .orderedSame)
            {
            resultArticleNumber = resultArticleNumber - 1
            try? readTitle(indexPos_0: UInt64(indexPos_0!), titlesPos: UInt64(titlesPos!), articleNumber: UInt64(resultArticleNumber))
            
        }

        resultArticleNumber = resultArticleNumber + 1
        
        try? readTitle(indexPos_0: UInt64(indexPos_0!), titlesPos: UInt64(titlesPos!), articleNumber: UInt64(resultArticleNumber))
        
        
        loadArticle()
        
        //while ((articleText ?? "").contains("#REDIRECT"))
        //{
        //    resultArticleNumber = resultArticleNumber + 1
            
        //    try? readTitle(indexPos_0: UInt64(indexPos_0!), titlesPos: UInt64(titlesPos!), articleNumber: UInt64(resultArticleNumber))
            
        //    loadArticle()
        //}

    }
    
    func articleToWebView()
    {
        var articleTextOneLine = (articleText?.replacingOccurrences(of: "\"", with: "\\\"") ?? "")
        articleTextOneLine = articleTextOneLine.replacingOccurrences(of: "\n", with: "\\n")
        articleTextOneLine = articleTextOneLine.replacingOccurrences(of: "\\underline", with: "\\")
        print(articleTextOneLine);
        webView.evaluateJavaScript("articleText = \"" + (articleTextOneLine ?? "") + "\"") { (result, error) in
            if error == nil {
                //print(result ?? "")
            } else {
                //print(error ?? "")
                self.webView.loadHTMLString(self.articleText!, baseURL: URL(string:"https://localhost:8080"))
            }
        }

        webView.evaluateJavaScript("document.getElementById(\"article\").innerHTML = wiki2html(articleText);") { (result, error) in
            if error == nil {
                //print(result ?? "")
            } else {
                
                self.webView.loadHTMLString(self.articleText!, baseURL: URL(string:"https://localhost:8080"))
                                
                //print(error ?? "")
            }
        }

    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "jsHandler" {
            print(message.body)
        }
        
        let bodyString = message.body as? String
        
        if ((bodyString ?? "").contains("openLink"))
        {
            var searchTitle = bodyString!.textBetween("(", and: ")")
            searchTitle = searchTitle.replacingOccurrences(of: "_", with: " ")
            print("searchTitle")
            print(searchTitle)
            findTitle(searchTitle: searchTitle)
            
            titles.append(thisTitle!)
            
            articleToWebView()
            
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

    func findBlockEnd(blockData: Data) -> Int
    {
        var endBuffer = 0
        for currentIndex in stride(from: blockData.count - 3, through: 0, by: -1)
        {
            //print (currentIndex, " ", blockData[currentIndex])
            if ((blockData[currentIndex] == 66) && (blockData[currentIndex + 1] == 90) && (blockData[currentIndex + 2] == 104))
            {
                endBuffer = currentIndex
                break
            }
        }
        
        return endBuffer
    }
    
    @objc func exitButtonClicked(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

    @objc func backButtonClicked(sender: UIBarButtonItem) {
        titles.popLast()
        let searchTitle = titles.popLast()
        if (searchTitle != "")
        {
            findTitle(searchTitle: searchTitle!)
            loadArticle()
            articleToWebView()
        }
    }

    @objc func textButtonClicked(sender: UIBarButtonItem) {
        //let searchTitle = titles.popLast()
        //if (searchTitle != "")
        //{
            //findTitle(searchTitle: searchTitle!)
            //loadArticle()

            var articleTextOneLine = (articleText?.replacingOccurrences(of: "\"", with: "\\\"") ?? "")
            articleTextOneLine = articleTextOneLine.replacingOccurrences(of: "\n", with: "\\n")
            print(articleTextOneLine);
            webView.evaluateJavaScript("articleText = \"" + (articleTextOneLine ?? "") + "\"") { (result, error) in
                if error == nil {
                    //print(result ?? "")
                } else {
                    print(error ?? "")
                }
            }

            webView.evaluateJavaScript("document.getElementById(\"article\").innerHTML = \"<textarea rows=\\\"52\\\">\" + articleText + \"</textarea>\";") { (result, error) in
                if error == nil {
                    //print(result ?? "")
                } else {
                    print(error ?? "")
                }
            }

        //}
    }
    
    func loadArticle()
    {
        do
        {
            var blockData = Data([])
            guard let blockFileHandle = FileHandle(forReadingAtPath: selectedItemPath! + "/articles.bin") else { throw NSError() }
            var blockBytesOffset = UInt64(lastBlockPos!)
            blockFileHandle.seek(toFileOffset: blockBytesOffset)
            let bufferLength = 32767
            //let bufferLength = 65536
            //let bufferLength = 65536 * 4
            //let bufferLength = 65536 * 8
            //blockData.append(blockFileHandle.readData(ofLength: bufferLength))
            
            var endBuffer = 0
            while (endBuffer == 0)
            {
                if (blockBytesOffset > indexPos_0!)
                {
                    break
                }
                
                blockFileHandle.seek(toFileOffset: blockBytesOffset)
                blockData.append(blockFileHandle.readData(ofLength: bufferLength))
                endBuffer = findBlockEnd(blockData: blockData)
                blockBytesOffset = blockBytesOffset + UInt64(bufferLength)
                
            }

            var endBufferOne = endBuffer
            while (endBuffer == endBufferOne)
            {
                if (blockBytesOffset > indexPos_0!)
                {
                    break
                }
                
                blockFileHandle.seek(toFileOffset: blockBytesOffset)
                blockData.append(blockFileHandle.readData(ofLength: bufferLength))
                endBuffer = findBlockEnd(blockData: blockData)
                blockBytesOffset = blockBytesOffset + UInt64(bufferLength)
                
            }

            
            //let blockData = blockFileHandle.readDataToEndOfFile()
            blockFileHandle.closeFile()
            
            print("blockData")
            print(blockData)
            
            print("blockData[0]")
            print(blockData[0])
            print("blockData[1]")
            print(blockData[1])
            
            print("endBuffer")
            print(endBuffer)
            
            let blockDataSliced = blockData[0..<endBuffer]
            //let blockDataSliced = blockData
            
            let decompressedData = try? BZip2.decompress(data: blockDataSliced)
            //                let bitReader = MsbBitReader(data: blockData)
            //                let decompressedData = try? WikiViewController.decompress(bitReader)
            
            print("decompressedData")
            print(decompressedData)
            
            print ("lastArticlePos");
            print (lastArticlePos!);

            print ("lastArticleLength");
            print (lastArticleLength!);

            //let decompressedDataSliced = decompressedData![lastArticlePos!..<lastArticlePos!+lastArticleLength!+1]
            let decompressedDataSliced = decompressedData![lastArticlePos!..<lastArticlePos!+lastArticleLength!]

            let decompressedDataString = String(data: decompressedDataSliced, encoding: .utf8)
            
            print("decompressedDataString")
            print(decompressedDataString)
            
            articleText = decompressedDataString
            
            
        } catch {
            print ("error loading block")
        }
        

    }
    
    override func viewDidLoad() {
        
        loadArticle()
        
        titles.append(thisTitle!)
        
        webView.configuration.preferences.javaScriptEnabled = true
        self.view.addSubview(webView)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var fileURL = documentsPath.appendingPathComponent("Wiki2Touch/articleParser.html")
                
        if (FileManager.default.fileExists(atPath: fileURL.path))
        {
            print("user-submitted parser")
            webView.loadFileURL(fileURL, allowingReadAccessTo: documentsPath)
        } else {
            print("built-in parser")
            
            fileURL = Bundle.main.url(forResource: "articleParser", withExtension: "html", subdirectory: "www")!
            print(fileURL)
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }

        webView.navigationDelegate = self
        exitButton.action = #selector(exitButtonClicked(sender:))
        backButton.action = #selector(backButtonClicked(sender:))
        textButton.action = #selector(textButtonClicked(sender:))

        
    }
    
}

