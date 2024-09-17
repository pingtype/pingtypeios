//
//  LyricsTableViewController.swift
//  Lyrics
//
//  Created by Peter Burkimsher on 2/11/23.
//

import UIKit

class LyricsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Declare variables to receive datas.
    var searchText: String?
    var searchResults = [String]()

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//       if (segue.identifier == "ChapterToWebview") {
//           let secondView = segue.destination as! WebViewController
//           let object = sender as! [String: Any?]
//           secondView.book = object["book"] as? String
//           secondView.chapter = object["chapter"] as? Int
//           secondView.chapterFile = object["chapterFile"] as? String
//       }
//    }

        
    @IBOutlet var chapterView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet var thisView: UIView!
    
    @objc func sceneViewPannedTwoFingers(sender: UIPanGestureRecognizer) {
        
        if (sender.state.rawValue == 3)
        {
            //print("two finger pan")
            
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.font = UIFont.systemFont(ofSize: 10)
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.numberOfLines = 3

        //let searchResult = searchResults[indexPath.row].components(separatedBy: "\t")
        let searchResultFilename = searchResults[indexPath.row].textBetween("start", and: "\t")
        let searchResultLyrics = searchResults[indexPath.row].textBetween("\t", and: "end")

        let lyricsBefore = searchResultLyrics.textBetween("start", and: (searchText ?? "end")!)
        let lyricsAfter = searchResultLyrics.textBetween((searchText ?? "start")!, and: "end")
        
        let lyricsBeforeLines = lyricsBefore.components(separatedBy: "§")
        let lyricsBeforeLine = lyricsBeforeLines[lyricsBeforeLines.count - 1]
        
        let lyricsAfterLine = lyricsAfter.textBetween("start", and: "§")

        cell.textLabel?.text = searchResultFilename + " " + lyricsBeforeLine + searchText! + lyricsAfterLine
        return cell

    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let alertController = UIAlertController(title: "Hello", message: String(indexPath.row),preferredStyle: .alert)
//        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
//        alertController.addAction(action)
//        present(alertController, animated: true, completion: nil)
        
        let searchResult = searchResults[indexPath.row].components(separatedBy: "\t")
        let lyricsFile = searchResult[0]

        print(lyricsFile)
        
        let chapterSender: [String: Any?] = ["lyricsFile": lyricsFile]
        
        self.performSegue(withIdentifier: "LyricsResultsToWebView", sender: chapterSender)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "LyricsResultsToWebView") {
           let secondView = segue.destination as! WebViewController
           let object = sender as! [String: Any?]
           secondView.lyricsFile = object["lyricsFile"] as? String
       }
    }

    
    override func viewDidLoad() {
        
        print("searchText:\(searchText ?? "")")
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let musicFilePath = documentsPath.path + "/" + "music.txt"

        let musicContents = FileManager.default.contents(atPath: musicFilePath)
        let musicContentsAsString = String(bytes: musicContents!, encoding: .utf8)
        
        let musicLines = musicContentsAsString!.components(separatedBy: "\n")
        
        //let searchResults = musicFilenamesContentsAsString?.matchingStrings(regex: ".*" + "\(searchText ?? "")" + ".*")
        
//        let searchResults = musicFilenamesContentsAsString!.components(separatedBy:  "\n")
//            .compactMap { [$0, "\n"] } // add the separator after each split
//                                .filter { $0.contains(searchText) } // remove empty strings

        searchResults = musicLines.filter { $0.lowercased().contains(searchText!.lowercased()) }
        
        print(searchResults)
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Handle two-finger pans
        let twoFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneViewPannedTwoFingers))
        thisView.addGestureRecognizer(twoFingerPanRecognizer)
        
    }

}

public extension String {
  func textBetween(_ startDelim: String, and endDelim: String) -> String {
    precondition(!startDelim.isEmpty && !endDelim.isEmpty)

    let startIdx: String.Index
    let endIdx: String.Index

    if startDelim == "start" {
      startIdx = startIndex
    } else if let r = range(of: startDelim) {
      startIdx = r.upperBound
    } else {
      return ""
    }

    if endDelim == "end" {
      endIdx = endIndex
    } else if let r = self[startIdx...].range(of: endDelim) {
      endIdx = r.lowerBound
    } else {
      endIdx = endIndex
    }

    return String(self[startIdx..<endIdx])
  }
}
