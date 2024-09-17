//
//  ViewController.swift
//  lyrics
//
//  Created by Peter Burkimsher on 29/10/23.
//

import UIKit

class ChapterController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //Declare variables to receive datas.
    var translationName: String?
    var book: String?
    var id: Int?
    var chapter: String?
    var bookContents = [String]()

    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]
    
        
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return self.items.count
        return self.bookContents.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        //cell.myLabel.text = self.items[indexPath.row] // The row value is the same as the index of the desired text within the array.
        cell.myLabel.text = String(indexPath.row + 1)

        //cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")

        let chapterSender: [String: Any?] = ["translationName": translationName, "book": book, "chapter": (indexPath.item + 1), "chapterFile": bookContents[indexPath.item]]
        
        self.performSegue(withIdentifier: "ChapterToBibleWebView", sender: chapterSender)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "ChapterToBibleWebView") {
           let secondView = segue.destination as! BibleWebViewController
           let object = sender as! [String: Any?]
           secondView.translationName = object["translationName"] as? String
           secondView.book = object["book"] as? String
           secondView.chapter = object["chapter"] as? Int
           secondView.chapterFile = object["chapterFile"] as? String
       }
    }

    func theNumberOfItemsInCollectionView() -> Int {
        return 150
    }
    
        
    @IBOutlet var chapterView: UIView!
    
//    @IBOutlet weak var chapterCollectionView: CustomCollectionView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "This is the cell for \(indexPath.row)"
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let alertController = UIAlertController(title: "Hello", message: String(indexPath.row),preferredStyle: .alert)
//        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
//        alertController.addAction(action)
//        present(alertController, animated: true, completion: nil)
        
        self.performSegue(withIdentifier: "BookToChapter", sender: self)

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
        
        print("Book:\(book ?? "") & my id: \(id ?? 0)")
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let files: [String]? = try? FileManager.default.contentsOfDirectory(atPath: documentsPath.path + "/" + (translationName ?? "") + "/" + (book ?? "") + "/")
        bookContents = files!.sortedByNumberAndString
        
        
        for file in bookContents
        {
            print(file.debugDescription)
        }

        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Handle two-finger pans
        let twoFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneViewPannedTwoFingers))
        chapterView.addGestureRecognizer(twoFingerPanRecognizer)

    }


}

extension Sequence where Iterator.Element == String {
    var sortedByNumberAndString : [String] {
        return self.sorted { (s1, s2) -> Bool in
            return s1.compare(s2, options: .numeric) == .orderedAscending
        }
    }
}

