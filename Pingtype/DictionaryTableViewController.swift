//
//  DictionaryViewController.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 18/11/23.
//

import Foundation
import UIKit

class DictionaryTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {

    
    @IBOutlet var thisView: UIView!
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var wordsArray: Array <String> = []
    var searchResults: Array <String> = []
    var selectedItemPath: String?
    
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

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (!searchText.isEmpty)
        {
            searchResults = []
            
            //searchResults = wordsArray.filter( { $0.hasPrefix(searchText) } )
            //searchResults = wordsArray.filter { $0.starts(with: searchText) }
            searchResults = wordsArray.filter { $0.caseInsensitiveHasPrefix(searchText) }
            
            
            
            resultsTableView.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "DictionaryTableToDefinition") {
            let secondView = segue.destination as! DictionaryDefinitionViewController
            let object = sender as! [String: Any?]
            secondView.selectedItemPath = object["selectedItemPath"] as? String
            secondView.searchString = object["searchString"] as? String
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let alertController = UIAlertController(title: "Hello", message: String(indexPath.row),preferredStyle: .alert)
        //        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        //        alertController.addAction(action)
        //        present(alertController, animated: true, completion: nil)
        
        let searchString = searchResults[indexPath.row]
        print(searchString)
                
        let senderDetails: [String: Any?] = ["searchString": searchString, "selectedItemPath": selectedItemPath]
        self.performSegue(withIdentifier: "DictionaryTableToDefinition", sender: senderDetails)
        
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
            //textArea.text = searchString
            
            let wordsPath = selectedItemPath! + "/words.txt"
            print(wordsPath)
            let wordsFileContents = FileManager.default.contents(atPath: wordsPath)
            let wordsFileContentsAsString = String(bytes: wordsFileContents!, encoding: .utf8)
            
            wordsArray = wordsFileContentsAsString!.components(separatedBy: "\n")

        }
        //print(textFileContentsAsString)
        

    }

    
}

extension String {
    func caseInsensitiveHasPrefix(_ prefix: String) -> Bool {
        return lowercased().hasPrefix(prefix.lowercased())
    }
}
