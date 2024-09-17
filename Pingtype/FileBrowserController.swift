//
//  FileBrowserController.swift
//  Bible
//
//  Created by Peter Burkimsher on 1/11/23.
//

import UIKit

class FileBrowserController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var selectedFolder: String?
    var selectedName: String?
    var folderContents = [String]()
    
    var selectedUrl: URL?
    
    @IBOutlet weak var navigatorTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var cacheButton: UIBarButtonItem!
    
    @IBAction func newFileButtonClicked(_ sender: Any) {
        let thisAlertController = UIAlertController(title: "Filename", message: nil, preferredStyle: .alert)
        thisAlertController.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned thisAlertController] _ in
            let answer = thisAlertController.textFields![0]
            // do something interesting with "answer" here
            
            self.selectedName = answer.text
            
            let rawData: Data? = "".data(using: .utf8)
            let selectedItemPath = self.selectedUrl?.appendingPathComponent(answer.text ?? "")
            FileManager.default.createFile(atPath: selectedItemPath?.path ?? "", contents: rawData, attributes: nil)
            
            //let files: [String]? = try? FileManager.default.contentsOfDirectory(atPath: self.selectedUrl!.path)
            let files: [String]? = try? FileManager.default.contentsOfDirectory(atPath: self.selectedUrl!.path)
            self.folderContents = (files ?? []).sortedByNumberAndString
            
            self.navigatorTableView.reloadData()
            
            if (self.selectedName!.contains(".txt"))
            {
                let senderDetails: [String: Any?] = ["selectedItemPath": selectedItemPath?.path]
                self.performSegue(withIdentifier: "FileBrowserToTextFile", sender: senderDetails)
            }
            
        }

        thisAlertController.addAction(submitAction)

        present(thisAlertController, animated: true)

    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        selectedName = ""
        selectedUrl = selectedUrl!.deletingLastPathComponent() // 'a/b'
        //print (selectedUrl)
        //let files: [String]? = try? FileManager.default.contentsOfDirectory(atPath: selectedUrl?.path ?? "")
        //folderContents = files!.sortedByNumberAndString
        
        var files = [String]()

        let directoryURL = URL(fileURLWithPath: selectedUrl!.path)
        let directoryContents = try? FileManager.default.contentsOfDirectory(at: directoryURL,
                                                    includingPropertiesForKeys: nil,
                                                    options: [.skipsHiddenFiles])

        for file in directoryContents!
        {
            files.append(file.lastPathComponent)
        }
        
        folderContents = files.sortedByNumberAndString

        navigatorTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderContents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        //cell.textLabel?.text = "This is the cell for \(indexPath.row)"
        cell.textLabel?.text = folderContents[indexPath.row]

        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let alertController = UIAlertController(title: "Hello", message: String(indexPath.row),preferredStyle: .alert)
//        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
//        alertController.addAction(action)
//        present(alertController, animated: true, completion: nil)
        
        selectedName = folderContents[indexPath.row]
        
        let translationName: [String: Any?] = ["translationName": selectedName]
        
        //let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let selectedItemPath = selectedUrl?.appendingPathComponent(selectedName ?? "")
        //print(selectedItemPath)
        
        if (selectedItemPath!.hasDirectoryPath) // if selected item is a folder
        {
            
            if (selectedName!.contains("UrbanDictionary"))
            {
                
                let thisAlertController = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
                thisAlertController.addTextField()

                let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned thisAlertController] _ in
                    let answer = thisAlertController.textFields![0]
                    // do something interesting with "answer" here
                    
                    //self.selectedName = answer.text
                    
                    let senderDetails: [String: Any?] = ["selectedItemPath": selectedItemPath?.path, "searchString": answer.text]
                    self.performSegue(withIdentifier: "FileBrowserToUD", sender: senderDetails)

                }

                thisAlertController.addAction(submitAction)

                present(thisAlertController, animated: true)
            }

//            if (selectedName!.contains("Wiki2Touch"))
//            {
//
//                let senderDetails: [String: Any?] = ["selectedItemPath": selectedItemPath?.path, "searchString": ""]
//                self.performSegue(withIdentifier: "FileBrowserToWiki", sender: senderDetails)
//
//                let thisAlertController = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
//                thisAlertController.addTextField()
//
//                let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned thisAlertController] _ in
//                    let answer = thisAlertController.textFields![0]
//                    // do something interesting with "answer" here
//                    
//                    //self.selectedName = answer.text
//                    
//                    let senderDetails: [String: Any?] = ["selectedItemPath": selectedItemPath?.path, "searchString": answer.text]
//                    self.performSegue(withIdentifier: "FileBrowserToWiki", sender: senderDetails)
//
//                }
//
//                thisAlertController.addAction(submitAction)
//
//                present(thisAlertController, animated: true)
//            }

            
            let selectedContents: [String]? = try? FileManager.default.contentsOfDirectory(atPath: selectedItemPath?.path ?? "")
            let selectedContentsString = selectedContents?.joined(separator: " ") ?? ""
            if (selectedContentsString.contains("Genesis") && selectedContentsString.contains("Exodus"))
            {
                // Folder is a Bible
                self.performSegue(withIdentifier: "FileBrowserToBibleBooks", sender: translationName)
            } else if (selectedContentsString.contains("words.txt") && selectedContentsString.contains("dictionary.txt"))
            {
                let senderDetails: [String: Any?] = ["selectedItemPath": selectedItemPath?.path]
                self.performSegue(withIdentifier: "FileBrowserToDictionary", sender: senderDetails)
            } else if (selectedName!.contains("Wiki2Touch")) {
                let senderDetails: [String: Any?] = ["selectedItemPath": selectedItemPath?.path, "searchString": ""]
                self.performSegue(withIdentifier: "FileBrowserToWiki", sender: senderDetails)
            } else if (selectedName!.contains("MIDI")) {
                let senderDetails: [String: Any?] = ["selectedItemPath": selectedItemPath?.path]
                self.performSegue(withIdentifier: "FileBrowserToMIDI", sender: senderDetails)
            } else if (selectedName!.contains("Flags")) {
                let senderDetails: [String: Any?] = ["selectedItemPath": selectedItemPath?.path]
                self.performSegue(withIdentifier: "FileBrowserToFlags", sender: senderDetails)


            } else { // if folder is not a Bible or a dictionary
                
                selectedUrl = selectedItemPath
                let files: [String]? = try? FileManager.default.contentsOfDirectory(atPath: selectedUrl?.path ?? "")
                folderContents = (files ?? []).sortedByNumberAndString
                
                navigatorTableView.reloadData()
            }
        } else {
            
            if (selectedName!.contains("rplan.sh"))
            {
                self.performSegue(withIdentifier: "FileBrowserToRPlan", sender: self)
            }
            
            if (selectedName!.contains(".txt"))
            {
                let senderDetails: [String: Any?] = ["selectedItemPath": selectedItemPath?.path]
                self.performSegue(withIdentifier: "FileBrowserToTextFile", sender: senderDetails)
            }

            if (selectedName!.contains(".jpg"))
            {
                let senderDetails: [String: Any?] = ["selectedItemPath": selectedItemPath?.path]
                self.performSegue(withIdentifier: "FileBrowserToJPEG", sender: senderDetails)
            }

            if (selectedName!.contains(".html"))
            {
                let senderDetails: [String: Any?] = ["selectedItemPath": selectedItemPath?.path]
                self.performSegue(withIdentifier: "FileBrowserToHTML", sender: senderDetails)
            }

            
        }
        
        
//        if (selectedName == "NIV2011")
//        {
//            self.performSegue(withIdentifier: "FileBrowserToBibleBooks", sender: translationName)
//        }
//
//        if (selectedName == "CUNP NLT")
//        {
//            self.performSegue(withIdentifier: "FileBrowserToBibleBooks", sender: translationName)
//        }

        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "FileBrowserToBibleBooks") {
          let secondView = segue.destination as! BibleBooksController
          let object = sender as! [String: Any?]
          secondView.translationName = object["translationName"] as? String
       }

        if (segue.identifier == "FileBrowserToTextFile") {
           let secondView = segue.destination as! TextFileViewController
           let object = sender as! [String: Any?]
           secondView.selectedItemPath = object["selectedItemPath"] as? String
        }

        if (segue.identifier == "FileBrowserToJPEG") {
           let secondView = segue.destination as! JPEGViewController
           let object = sender as! [String: Any?]
           secondView.selectedItemPath = object["selectedItemPath"] as? String
        }

        if (segue.identifier == "FileBrowserToHTML") {
           let secondView = segue.destination as! HTMLViewController
           let object = sender as! [String: Any?]
           secondView.selectedItemPath = object["selectedItemPath"] as? String
        }

        if (segue.identifier == "FileBrowserToUD") {
           let secondView = segue.destination as! UrbanDictionaryViewController
           let object = sender as! [String: Any?]
           secondView.selectedItemPath = object["selectedItemPath"] as? String
           secondView.searchString = object["searchString"] as? String
        }

        if (segue.identifier == "FileBrowserToWiki") {
           let secondView = segue.destination as! WikiTableViewController
           let object = sender as! [String: Any?]
           secondView.selectedItemPath = object["selectedItemPath"] as? String
           secondView.searchString = object["searchString"] as? String
        }

        if (segue.identifier == "FileBrowserToMIDI") {
           let secondView = segue.destination as! MIDIViewController
           let object = sender as! [String: Any?]
           secondView.selectedItemPath = object["selectedItemPath"] as? String
        }

        if (segue.identifier == "FileBrowserToDictionary") {
           let secondView = segue.destination as! DictionaryTableViewController
           let object = sender as! [String: Any?]
           secondView.selectedItemPath = object["selectedItemPath"] as? String
        }

        if (segue.identifier == "FileBrowserToFlags") {
           let secondView = segue.destination as! FlagsTableViewController
           let object = sender as! [String: Any?]
           secondView.selectedItemPath = object["selectedItemPath"] as? String
        }

    }

    @objc func buttonClicked(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsPath.path)
        selectedUrl = documentsPath
        //print(selectedUrl?.path)
        //let listing = try! FileManager.default.contentsOfDirectory(atPath: documentsPath.path + "/Current/")

        //let files: [String]? = try? FileManager.default.contentsOfDirectory(atPath: selectedUrl?.path ?? "")
        //folderContents = files!.sortedByNumberAndString
        
        var files = [String]()

        let directoryURL = URL(fileURLWithPath: selectedUrl!.path)
        let directoryContents = try? FileManager.default.contentsOfDirectory(at: directoryURL,
                                                    includingPropertiesForKeys: nil,
                                                    options: [.skipsHiddenFiles])

        for file in directoryContents!
        {
            files.append(file.lastPathComponent)
        }
        
        folderContents = files.sortedByNumberAndString
        
//        for file in sortedFiles
//        {
//            folderContents.append(file.debugDescription)
//
//            //folderContents[currentFile] = file.debugDescription
//            //currentFile = currentFile + 1
//            //print(file.debugDescription)
//        }
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cacheButton.action = #selector(buttonClicked(sender:))
    }

    
}

