//
//  WikiViewController.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 12/11/23.
//

import Foundation
import UIKit
import SWCompression


class WikiTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {
        
    @IBOutlet var thisView: UIView!
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    
    var searchResults: Array <String> = []
    var selectedItemPath: String?
    var searchString: String?

    var indexPos_0: UInt64?
    var numberOfArticles: UInt32?
    var titlesPos: UInt64?
    var lastBlockPos: UInt64?
    var lastArticlePos: UInt32?
    var lastArticleLength: UInt32?
    var thisTitle: String?

    var lastBlockPosArray: Array<UInt64> = []
    var lastArticlePosArray: Array<UInt32> = []
    var lastArticleLengthArray: Array<UInt32> = []
    var thisTitleArray: Array <String> = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        //cell.textLabel?.text = "This is the cell for \(indexPath.row)"
        cell.textLabel?.text = searchResults[indexPath.row]

        return cell

    }
    
    @objc func sceneViewPannedTwoFingers(sender: UIPanGestureRecognizer) {
        
        if (sender.state.rawValue == 3)
        {
            //print("two finger pan")
            
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    func loadInBlocks(path: String) -> [Data] {
        var blocks = [Data]()
        let correctPath = selectedItemPath! + "/articles.bin"
        let fileHandle = FileHandle(forReadingAtPath: correctPath)

        let dataFromFirstByteTo4thByte = fileHandle!.readData(ofLength: 4)
        blocks.append(dataFromFirstByteTo4thByte)
        fileHandle?.seek(toFileOffset: 4)
        let dataFrom5thByteTo8thByte = fileHandle!.readData(ofLength: 4)
        blocks.append(dataFrom5thByteTo8thByte)
        fileHandle?.closeFile()

        return blocks
    }
    
    func loadBlock(number: Int, withBlockSize size: Int, path: String) throws -> Data {
        let correctPath = path.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
        
        guard let fileHandle = FileHandle(forReadingAtPath: correctPath) else { throw NSError() }

        let bytesOffset = UInt64((number-1) * size)
        fileHandle.seek(toFileOffset: bytesOffset)
        let data = fileHandle.readData(ofLength: size)
        fileHandle.closeFile()
        return data
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

        print("titlePos")
        print(titlePos)
        
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

        print("lastBlockPos")
        print(lastBlockPos)
        
        lastArticlePos =
        (UInt32(titleData[8]) << (0*8)) | // shifted by zero bits (not shifted)
        (UInt32(titleData[9]) << (1*8)) | // shifted by 8 bits
        (UInt32(titleData[10]) << (2*8)) | // shifted by 16 bits
        (UInt32(titleData[11]) << (3*8))   // shifted by 24 bits

        print("lastArticlePos")
        print(lastArticlePos)

        lastArticleLength =
        (UInt32(titleData[12]) << (0*8)) | // shifted by zero bits (not shifted)
        (UInt32(titleData[13]) << (1*8)) | // shifted by 8 bits
        (UInt32(titleData[14]) << (2*8)) | // shifted by 16 bits
        (UInt32(titleData[15]) << (3*8))   // shifted by 24 bits

        print("lastArticleLength")
        print(lastArticleLength)

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "WikiTableToArticle") {
            let secondView = segue.destination as! WikiArticleViewController
            let object = sender as! [String: Any?]
            secondView.selectedItemPath = object["selectedItemPath"] as? String
            secondView.searchString = object["searchString"] as? String
            secondView.indexPos_0 = object["indexPos_0"] as? UInt64
            secondView.lastBlockPos = object["lastBlockPos"] as? UInt64
            secondView.lastArticlePos = object["lastArticlePos"] as? UInt32
            secondView.lastArticleLength = object["lastArticleLength"] as? UInt32
            secondView.thisTitle = object["thisTitle"] as? String
            secondView.titlesPos = object["titlesPos"] as? UInt64
            secondView.numberOfArticles = object["numberOfArticles"] as? UInt32
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let alertController = UIAlertController(title: "Hello", message: String(indexPath.row),preferredStyle: .alert)
        //        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        //        alertController.addAction(action)
        //        present(alertController, animated: true, completion: nil)
        
        let lastBlockPosSelected = lastBlockPosArray[indexPath.row]
        let lastArticlePosSelected = lastArticlePosArray[indexPath.row]
        let lastArticleLengthSelected = lastArticleLengthArray[indexPath.row]
        let thisTitleSelected = thisTitleArray[indexPath.row]
        
        let senderDetails: [String: Any?] = ["selectedItemPath": selectedItemPath, "searchString": searchString,
                                             "indexPos_0": indexPos_0, "lastBlockPos": lastBlockPosSelected, "lastArticlePos": lastArticlePosSelected,
                                             "lastArticleLength": lastArticleLengthSelected, "thisTitle": thisTitleSelected,
                                             "titlesPos": titlesPos, "numberOfArticles": numberOfArticles]
        self.performSegue(withIdentifier: "WikiTableToArticle", sender: senderDetails)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (!searchText.isEmpty)
        {
            searchResults = []
            
            lastBlockPosArray = []
            lastArticlePosArray = []
            lastArticleLengthArray = []
            thisTitleArray = []

            let searchTitle = searchText
            var lowerBound = 0
            var upperBound = Int(numberOfArticles!)
            
            var articleNumber = (lowerBound + upperBound) / 2
            
            while (lowerBound <= upperBound)
            {
                articleNumber = (lowerBound + upperBound) / 2
                //                articleNumber = 2048
                print ("articleNumber")
                print (articleNumber)
                
                try? readTitle(indexPos_0: UInt64(indexPos_0!), titlesPos: UInt64(titlesPos!), articleNumber: UInt64(articleNumber))
                
//                if (searchTitle.caseInsensitiveCompare(thisTitle!) == .orderedAscending)
                if (searchTitle.forSorting().localizedStandardCompare(thisTitle!.forSorting()) == .orderedAscending)
                {
                    print(searchTitle, " before ", thisTitle!)
                    upperBound = articleNumber - 1
                }
                
//                if (searchTitle.caseInsensitiveCompare(thisTitle!) == .orderedSame)
                if (searchTitle.forSorting().localizedStandardCompare(thisTitle!.forSorting()) == .orderedSame)
                {
                    print(searchTitle, " found ", thisTitle!)
                    lowerBound = upperBound + 1
                }
                
//                if (searchTitle.caseInsensitiveCompare(thisTitle!) == .orderedDescending)
                if (searchTitle.forSorting().localizedStandardCompare(thisTitle!.forSorting()) == .orderedDescending)
                {
                    print(searchTitle, " after ", thisTitle!)
                    lowerBound = articleNumber + 1
                }
            }
            
            //                try? readTitle(indexPos_0: UInt64(indexPos_0), titlesPos: UInt64(titlesPos), articleNumber: UInt64(0))
            
            for resultArticleNumber in (articleNumber-100)..<(articleNumber+100)
            {
                try? readTitle(indexPos_0: UInt64(indexPos_0!), titlesPos: UInt64(titlesPos!), articleNumber: UInt64(resultArticleNumber))
                
                if (thisTitle!.starts(with: searchTitle) || thisTitle!.compare(searchTitle, options: .caseInsensitive) == .orderedSame)
                {
                    searchResults.append(thisTitle!)
                    
                    lastBlockPosArray.append(lastBlockPos!)
                    lastArticlePosArray.append(lastArticlePos!)
                    lastArticleLengthArray.append(lastArticleLength!)
                    thisTitleArray.append(thisTitle!)
                }
            }
            
            
            resultsTableView.reloadData()
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Handle two-finger pans
        let twoFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneViewPannedTwoFingers))
        thisView.addGestureRecognizer(twoFingerPanRecognizer)
        
        if (selectedItemPath != nil)
        {
            print(selectedItemPath)
            print(searchString)
            //textArea.text = searchString
            
            do
            {
                let data = try loadBlock(number: 1, withBlockSize: 256, path: selectedItemPath! + "/articles.bin")
                print(data)
                
                let languageCode =
                (UInt32(data[0]) << (0*8)) | // shifted by zero bits (not shifted)
                (UInt32(data[1]) << (1*8))   // shifted by 8 bits
                
                print("languageCode")
                print(languageCode)
                
                
                numberOfArticles =
                (UInt32(data[2]) << (0*8)) | // shifted by zero bits (not shifted)
                (UInt32(data[3]) << (1*8)) | // shifted by 8 bits
                (UInt32(data[4]) << (2*8)) | // shifted by 16 bits
                (UInt32(data[5]) << (3*8))   // shifted by 24 bits
                
                print("numberOfArticles")
                print(numberOfArticles)
                
                let titlesPosUpper =
                (UInt64(data[6]) << (0*8)) | // shifted by zero bits (not shifted)
                (UInt64(data[7]) << (1*8)) | // shifted by 8 bits
                (UInt64(data[8]) << (2*8)) | // shifted by 16 bits
                (UInt64(data[9]) << (3*8))   // shifted by 24 bits
                
                let titlesPosLower =
                (UInt64(data[10]) << (4*8)) |
                (UInt64(data[11]) << (5*8)) |
                (UInt64(data[12]) << (6*8)) |
                (UInt64(data[13]) << (7*8))
//
                print("titlesPosUpper")
                print(titlesPosUpper)
                print("titlesPosLower")
                print(titlesPosLower)
                
                titlesPos = titlesPosUpper | titlesPosLower
                print("titlesPos")
                print(titlesPos)
                
                
                let indexPos_0_lower =
                (UInt64(data[14]) << (0*8)) | // shifted by zero bits (not shifted)
                (UInt64(data[15]) << (1*8)) | // shifted by 8 bits
                (UInt64(data[16]) << (2*8)) | // shifted by 16 bits
                (UInt64(data[17]) << (3*8))   // shifted by 24 bits
                
                let indexPos_0_upper =
                (UInt64(data[18]) << (4*8)) |
                (UInt64(data[19]) << (5*8)) |
                (UInt64(data[20]) << (6*8)) |
                (UInt64(data[21]) << (7*8))
//
                
                print("indexPos_0_lower")
                print(indexPos_0_lower)

                print("indexPos_0_upper")
                print(indexPos_0_upper)

                indexPos_0 = indexPos_0_lower | indexPos_0_upper
                
                print("indexPos_0")
                print(indexPos_0)

                guard let indexFileHandle = FileHandle(forReadingAtPath: selectedItemPath! + "/articles.bin") else { throw NSError() }

//                let bytesOffset = UInt64(indexPos_0)
//                indexFileHandle.seek(toFileOffset: bytesOffset)
//                let indexData = indexFileHandle.readDataToEndOfFile()
//                indexFileHandle.closeFile()
//                print(indexData)
                
                
                //let articleNumber = 0

                
            } catch {
                print ("error loading block")
            }
            
            
//            let textFileContents = FileManager.default.contents(atPath: selectedItemPath ?? "")
//            let textFileContentsAsString = String(bytes: textFileContents!, encoding: .utf8)
//            textArea.text = textFileContentsAsString
        }
        //print(textFileContentsAsString)
        

    }

    
}

extension String {
func forSorting() -> String {
    let set = [("♯", "z"), ("á", "z"), ("Á", "z"), ("à", "z"), ("ă", "z"), ("ằ", "z"), ("â", "z"), ("ǎ", "z"), ("å", "z"), ("ä", "z"), ("Ä", "z"), ("ą", "z"), ("ā", "z"), ("ả", "z"), ("ạ", "z"), ("æ", "z"), ("ć", "z"), ("č", "z"), ("ç", "z"), ("Ç", "z"), ("đ", "z"), ("Đ", "z"), ("ḍ", "z"), ("ð", "z"), ("é", "z"), ("É", "z"), ("è", "z"), ("ê", "z"), ("Ê", "z"), ("ế", "z"), ("ề", "z"), ("ễ", "z"), ("ể", "z"), ("ë", "z"), ("ė", "z"), ("ę", "z"), ("ē", "z"), ("ệ", "z"), ("ə", "z"), ("Ə", "z"), ("ɘ", "z"), ("ğ", "z"), ("ģ", "z"), ("ḥ", "z"), ("í", "z"), ("ì", "z"), ("î", "z"), ("Î", "z"), ("ǐ", "z"), ("ï", "z"), ("ī", "z"), ("Ī", "z"), ("ị", "z"), ("ı", "z"), ("ɪ", "z"), ("ļ", "z"), ("ł", "z"), ("ḷ", "z"), ("ń", "z"), ("ñ", "z"), ("ņ", "z"), ("ŋ", "z"), ("ó", "z"), ("ò", "z"), ("ŏ", "z"), ("ô", "z"), ("ổ", "z"), ("ǒ", "z"), ("ö", "z"), ("Ö", "z"), ("õ", "z"), ("ø", "z"), ("ǫ", "z"), ("ō", "z"), ("ơ", "z"), ("ớ", "z"), ("ộ", "z"), ("ɔ", "z"), ("ś", "z"), ("š", "z"), ("ş", "z"), ("Ş", "z"), ("Ṣ", "z"), ("ș", "z"), ("ß", "z"), ("ţ", "z"), ("ṭ", "z"), ("ț", "z"), ("ú", "z"), ("ŭ", "z"), ("û", "z"), ("ü", "z"), ("ų", "z"), ("ū", "z"), ("ư", "z"), ("ừ", "z"), ("ữ", "z"), ("ụ", "z"), ("ʋ", "z"), ("ỳ", "z"), ("ÿ", "z"), ("ỹ", "z"), ("ỵ", "z"), ("ź", "z"), ("ž", "z"), ("Ž", "z"), ("ż", "z"), ("ʿ", "z"), ("ǀ", "z"), ("α", "z"), ("ά", "z"), ("β", "z"), ("Ε", "z"), ("έ", "z"), ("η", "z"), ("ι", "z"), ("ί", "z"), ("Κ", "z"), ("λ", "z"), ("μ", "z"), ("ν", "z"), ("π", "z"), ("Π", "z"), ("ρ", "z"), ("σ", "z"), ("τ", "z"), ("ὐ", "z"), ("ж", "z"), ("и", "z"), ("к", "z"), ("н", "z"), ("о", "z"), ("т", "z"), ("у", "z"), ("Я", "z")]
    let ab = self.lowercased()
//    let new = ab.folding(options: .diacriticInsensitive, locale: nil)
    let new = ab
    let final = new.replaceCharacters(characters: set)
    return final
    }
}

extension String {
    func replaceCharacters(characters: [(String, String)]) -> String
    {
        var input: String = self
        let count = characters.count
        if count >= 1
        {
            for i in 1...count
            {
                let c = i - 1
                let first = input
                let working = first.replacingOccurrences(of: characters[c].0, with: characters[c].1)
                input = working
            }
        }
        return input
    }
}
