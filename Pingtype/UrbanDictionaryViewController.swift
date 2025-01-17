//
//  UrbanDictionaryViewController.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 11/11/23.
//

import UIKit

class UrbanDictionaryViewController: UIViewController, UIGestureRecognizerDelegate {

 
    @IBOutlet var thisView: UIView!
    @IBOutlet weak var textArea: UITextView!
    
    var selectedItemPath: String?
    var searchString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pathURL = URL(fileURLWithPath: selectedItemPath! + "/UrbanDictionaryFirstDefinitions.txt")
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
                    textArea.text = line

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
}

class StreamReader {
    let encoding: String.Encoding
    let chunkSize: Int
    let fileHandle: FileHandle
    var buffer: Data
    let delimPattern : Data
    var isAtEOF: Bool = false
    
    init?(url: URL, delimeter: String = "\n", encoding: String.Encoding = .utf8, chunkSize: Int = 8192)
    {
        guard let fileHandle = try? FileHandle(forReadingFrom: url) else { return nil }
        self.fileHandle = fileHandle
        self.chunkSize = chunkSize
        self.encoding = encoding
        buffer = Data(capacity: chunkSize)
        delimPattern = delimeter.data(using: .utf8)!
    }
    
    deinit {
        fileHandle.closeFile()
    }
    
    func rewind() {
        fileHandle.seek(toFileOffset: 0)
        buffer.removeAll(keepingCapacity: true)
        isAtEOF = false
    }
    
    func setoffset(offset: UInt64) {
        fileHandle.seek(toFileOffset: offset)
    }
    
    func offsetvalue() -> UInt64 {
        return fileHandle.offsetInFile
    }
    
    func nextLine() -> String? {
        if isAtEOF { return nil }
        
        repeat {
            if let range = buffer.range(of: delimPattern, options: [], in: buffer.startIndex..<buffer.endIndex) {
                let subData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
                let line = String(data: subData, encoding: encoding)
                buffer.replaceSubrange(buffer.startIndex..<range.upperBound, with: [])
                return line
            } else {
                let tempData = fileHandle.readData(ofLength: chunkSize)
                if tempData.count == 0 {
                    isAtEOF = true
                    return (buffer.count > 0) ? String(data: buffer, encoding: encoding) : nil
                }
                buffer.append(tempData)
            }
        } while true
    }
}
