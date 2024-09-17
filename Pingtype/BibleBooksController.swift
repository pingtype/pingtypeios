//
//  BibleBooksController.swift
//  Bible
//
//  Created by Peter Burkimsher on 1/11/23.
//

import UIKit

class BibleBooksController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var selectedName: String?
    var folderContents = [String]()
    var translationName: String?
    
    @IBOutlet var thisView: UIView!
        
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
        
        let book: [String: Any?] = ["translationName": translationName, "book": selectedName, "bookId": indexPath.row]
        
        self.performSegue(withIdentifier: "BibleBooksToChapter", sender: book)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "BibleBooksToChapter") {
          let secondView = segue.destination as! ChapterController
          let object = sender as! [String: Any?]
          secondView.translationName = object["translationName"] as? String
          secondView.book = object["book"] as? String
          secondView.id = object["bookId"] as? Int
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

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsPath.path)

        //let listing = try! FileManager.default.contentsOfDirectory(atPath: documentsPath.path + "/Current/")

        let files: [String]? = try? FileManager.default.contentsOfDirectory(atPath: documentsPath.path + "/" + (translationName ?? "") + "/")
        folderContents = files!.sortedByNumberAndString
        
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
        
        // Handle two-finger pans
        let twoFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneViewPannedTwoFingers))
        thisView.addGestureRecognizer(twoFingerPanRecognizer)

    }

    
}
