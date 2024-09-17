//
//  TableViewController.swift
//  Lyrics
//
//  Created by Peter Burkimsher on 31/10/23.
//

import UIKit

class FilenamesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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

        cell.textLabel?.text = searchResults[indexPath.row]
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let alertController = UIAlertController(title: "Hello", message: String(indexPath.row),preferredStyle: .alert)
//        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
//        alertController.addAction(action)
//        present(alertController, animated: true, completion: nil)
        
        let selectedResult = searchResults[indexPath.row]
        print(selectedResult)
        
        let chapterSender: [String: Any?] = ["lyricsFile": selectedResult]
        
        self.performSegue(withIdentifier: "ResultsToWebView", sender: chapterSender)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "ResultsToWebView") {
           let secondView = segue.destination as! WebViewController
           let object = sender as! [String: Any?]
           secondView.lyricsFile = object["lyricsFile"] as? String
       }
    }

    
    override func viewDidLoad() {
        
        print("searchText:\(searchText ?? "")")
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let musicFilenamesFilePath = documentsPath.path + "/" + "musicFilenames.txt"

        let musicFilenamesContents = FileManager.default.contents(atPath: musicFilenamesFilePath)
        let musicFilenamesContentsAsString = String(bytes: musicFilenamesContents!, encoding: .utf8)
        
        let musicFilenamesLines = musicFilenamesContentsAsString!.components(separatedBy: "\n")
        
        //let searchResults = musicFilenamesContentsAsString?.matchingStrings(regex: ".*" + "\(searchText ?? "")" + ".*")
        
//        let searchResults = musicFilenamesContentsAsString!.components(separatedBy:  "\n")
//            .compactMap { [$0, "\n"] } // add the separator after each split
//                                .filter { $0.contains(searchText) } // remove empty strings

        searchResults = musicFilenamesLines.filter { $0.lowercased().contains(searchText!.lowercased()) }
        
        print(searchResults)
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Handle two-finger pans
        let twoFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneViewPannedTwoFingers))
        thisView.addGestureRecognizer(twoFingerPanRecognizer)
        
    }

}
