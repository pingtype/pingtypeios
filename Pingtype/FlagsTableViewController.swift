//
//  FlagsTableViewController.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 24/02/24.
//

import Foundation
import UIKit

class FlagsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var thisView: UIView!
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var flagsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    
    var folderContents: Array <String> = []
    var searchResults: Array <String> = []
    var selectedItemPath: String?
    var searchString: String?

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlagsTableViewCell", for: indexPath) as! FlagsTableViewCell

        if (searchResults[indexPath.row] != "")
        {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentPath = paths[0]
            let imagePath = documentPath.appending("/Flags/flags/" + searchResults[indexPath.row] + ".png")
            let image = UIImage(contentsOfFile: imagePath)
            //print(imagePath)
            
            cell.configureCell(image: image!, text: searchResults[indexPath.row])
        }

        return cell
     }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (!searchText.isEmpty)
        {
            searchResults = folderContents.filter { $0.caseInsensitiveHasPrefix(searchText) }

            flagsTableView.reloadData()
        }
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedName = searchResults[indexPath.row]
        let selectedNameSender: [String: Any?] = ["selectedName": selectedName]

        self.performSegue(withIdentifier: "FlagsToCountry", sender: selectedNameSender)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FlagsToCountry") {
            let secondView = segue.destination as! CountryViewController
            let object = sender as! [String: Any?]
            secondView.selectedItemPath = object["selectedName"] as? String
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

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Handle two-finger pans
        let twoFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneViewPannedTwoFingers))
        thisView.addGestureRecognizer(twoFingerPanRecognizer)
        
        if (selectedItemPath != nil)
        {
            //print(selectedItemPath)

            var files = [String]()

            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let flagsFolderPath = documentsPath.path + "/Flags/" + "flags"

            let flagsDirectoryURL = URL(fileURLWithPath: flagsFolderPath)
            let directoryContents = try? FileManager.default.contentsOfDirectory(at: flagsDirectoryURL,
                                                        includingPropertiesForKeys: nil,
                                                        options: [.skipsHiddenFiles])

            for file in directoryContents!
            {
                let thisFilename = file.lastPathComponent
                let name = (thisFilename as NSString).deletingPathExtension

                files.append(name)
            }
            
            folderContents = files.sortedByNumberAndString
            searchResults = folderContents

            flagsTableView.reloadData()

        }
    }
    
}

