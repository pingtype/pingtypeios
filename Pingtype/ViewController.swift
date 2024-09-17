//
//  ViewController.swift
//  DataBaseDemo
//
//  Created by Peter Burkimsher on 31/10/23.
//

import UIKit
import Vision
import MediaPlayer
import Photos

protocol isAbleToReceiveData {
  func pass(data: String)  //data: string is an example parameter
}

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, isAbleToReceiveData {
    
    var cameraLoaded = false
    var imageView = UIImageView()
    
    @IBOutlet weak var searchBox: UITextView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet var thisView: UIView!
    
    func pass(data: String) { 
//        print("data")
//        print(data)
        searchBox.text = data
     }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {

        self.performSegue(withIdentifier: "MainToCamera", sender: self)

    }
    
    @IBAction func loadImageButtonClicked(_ sender: Any) {
        
        let provider = CameraProvider(delegate: self)

        do {
            let picker = try provider.getImagePicker(source: .photoLibrary)
            present(picker, animated: true)
        } catch {
            NSLog("Error: \(error.localizedDescription)")
        }
        
    }
    
    @IBAction func saveImageButtonClicked(_ sender: Any) {
        let snapshot: UIImage = imageView.image!

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: snapshot)
        }, completionHandler: { success, error in
            if success {
                // Saved successfully!
                print("Saved successfully!")
            }
            else if let error = error {
                print("Save photo failed with error")
                // Save photo failed with error
            }
            else {
                print("Save photo failed with no error")
                // Save photo failed with no error
            }
        })

        
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: Any) {
        if (cameraLoaded == false)
        {
            addCameraInView()
            cameraLoaded = true
        } else {
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.imagePickerController.takePicture()
            } else{
                print("Error on taking picture")
            }
        }
    }
    
    @IBAction func pingtypeButtonClicked(_ sender: Any) {
        
        let searchTextSender: [String: Any?] = ["text": searchBox.text!]
        
        self.performSegue(withIdentifier: "SearchToPingtype", sender: searchTextSender)
        
    }
    
    @IBAction func songButtonClicked(_ sender: Any) {
        //print("songButtonClicked")
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
            //print(nowPlayingItem.title)
            searchBox.text = nowPlayingItem.title
        } else {
            //print("Nothing's playing")
            searchBox.text = "Nothing's playing"
        }

        
    }
    
    @IBAction func lyricsButtonClicked(_ sender: Any) {
    
        //print("songButtonClicked")
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
            //print(nowPlayingItem.title)
            searchBox.text = nowPlayingItem.lyrics
        } else {
            //print("Nothing's playing")
            searchBox.text = "Nothing's playing"
        }

    
    }
    
    @IBAction func pasteButtonClicked(_ sender: Any) {
        let clipboardString = UIPasteboard.general.string
        searchBox.text = clipboardString
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        print(searchBox.text!)

        let searchTextSender: [String: Any?] = ["text": searchBox.text!]
        
        self.performSegue(withIdentifier: "ViewControllerToTextFile", sender: searchTextSender)

    }
    
    @IBAction func lyricsSearchButtonClicked(_ sender: Any) {

        print(searchBox.text!)

        let searchTextSender: [String: Any?] = ["searchText": searchBox.text!]
        
        self.performSegue(withIdentifier: "SearchToLyricsTable", sender: searchTextSender)

    }
    
    @IBAction func webButtonClicked(_ sender: Any) {
        
        print(searchBox.text!)

        let searchTextSender: [String: Any?] = ["searchText": searchBox.text!]
        
        self.performSegue(withIdentifier: "SearchToWeb", sender: searchTextSender)

    }
    
    @IBAction func filenamesButtonClicked(_ sender: Any) {
        
        print(searchBox.text!)

        let searchTextSender: [String: Any?] = ["searchText": searchBox.text!]
        
        self.performSegue(withIdentifier: "SearchToTable", sender: searchTextSender)
        
    }
    
    @IBAction func asciiButtonClicked(_ sender: Any) {
        let filteredString = self.removeNonAsciiFromString(text: searchBox.text ?? "")
        self.searchBox.text = filteredString
    }
    
    @IBAction func nonAsciiButtonClicked(_ sender: Any) {
        
        let filteredString = self.removeAsciiFromString(text: searchBox.text ?? "")
        self.searchBox.text = filteredString
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "SearchToTable") {
          let secondView = segue.destination as! FilenamesTableViewController
          let object = sender as! [String: Any?]
          secondView.searchText = object["searchText"] as? String
       }

        if (segue.identifier == "SearchToLyricsTable") {
           let secondView = segue.destination as! LyricsTableViewController
           let object = sender as! [String: Any?]
           secondView.searchText = object["searchText"] as? String
        }

        if (segue.identifier == "SearchToPingtype") {
           let secondView = segue.destination as! InteractiveWebViewController
           let object = sender as! [String: Any?]
           secondView.text = object["text"] as? String
        }

        if (segue.identifier == "ViewControllerToTextFile") {
           let secondView = segue.destination as! TextFileViewController
           let object = sender as! [String: Any?]
           secondView.text = object["text"] as? String
        }

        if (segue.identifier == "SearchToWeb") {
           let secondView = segue.destination as! WebBrowserViewController
           let object = sender as! [String: Any?]
           secondView.searchText = object["searchText"] as? String
        }
        
        if (segue.identifier == "MainToCamera") {
            /** code for passing data **/
            //let vc2 = CameraViewController()  
            let secondView = segue.destination as! CameraViewController
            secondView.delegate = self   //sets the delegate in the new viewcontroller
                                  //before displaying
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchBox {
            print ("return pressed")
            //textField.resignFirstResponder()
            
            let searchTextSender: [String: Any?] = ["searchText": searchBox.text!]
            self.performSegue(withIdentifier: "SearchToTable", sender: searchTextSender)
            
            return false
        }
        return true
    }
    
    private lazy var imagePickerController: UIImagePickerController = {
        let imagePickers = UIImagePickerController()
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            imagePickers.delegate = self
            imagePickers.sourceType = UIImagePickerController.SourceType.camera
            imagePickers.view.frame = cameraView.bounds
            imagePickers.allowsEditing = false
            imagePickers.showsCameraControls = false
        }
        return imagePickers
    }()

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            print("Image:\(image)")
            imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: cameraView.frame.width, height: cameraView.frame.height)

            cameraView.addSubview(imageView)
            
            cameraLoaded = false

            
                    if let cgImage = image.cgImage {
                      let requestHandler = VNImageRequestHandler(cgImage: cgImage)
            
                      let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
                        guard let observations = request.results as? [VNRecognizedTextObservation] else {
                          return
                        }
            
                        let recognizedStrings = observations.compactMap { observation in
                          observation.topCandidates(1).first?.string
                        }
            
                        DispatchQueue.main.async {
                            print("recognizedStrings")
                            print(recognizedStrings)
                            let recognizedString = recognizedStrings.joined(separator: "\n")
                            
                            self.searchBox.text = recognizedString
                        }
                      }
            
                      recognizeTextRequest.recognitionLevel = .accurate
                        recognizeTextRequest.recognitionLanguages = ["zh-Hant"]
            
                      DispatchQueue.global(qos: .userInitiated).async {
                        do {
                          try requestHandler.perform([recognizeTextRequest])
                        } catch {
                          print(error)
                        }
                      }
                    }

        }
        picker.dismiss(animated: true, completion: nil)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBox.becomeFirstResponder()
        
        let tap = UITapGestureRecognizer(target: thisView, action: #selector(UIView.endEditing))
        thisView.addGestureRecognizer(tap)
        
        //addCameraInView()
        
//        let image = UIImage(named: "anhop.png")
//
//        if let cgImage = image?.cgImage {
//          let requestHandler = VNImageRequestHandler(cgImage: cgImage)
//            
//          let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
//            guard let observations = request.results as? [VNRecognizedTextObservation] else {
//              return
//            }
//            
//            let recognizedStrings = observations.compactMap { observation in
//              observation.topCandidates(1).first?.string
//            }
//            
//            DispatchQueue.main.async {
//              print(recognizedStrings)
//            }
//          }
//          
//          recognizeTextRequest.recognitionLevel = .accurate
//            recognizeTextRequest.recognitionLanguages = ["zh-Hant"]
//          
//          DispatchQueue.global(qos: .userInitiated).async {
//            do {
//              try requestHandler.perform([recognizeTextRequest])
//            } catch {
//              print(error)
//            }
//          }
//        }

        
    }

    
    private func addCameraInView(){
        // Add the imageviewcontroller to UIView as a subview
        self.cameraView.addSubview((imagePickerController.view))
    }

    func removeAsciiFromString(text: String) -> String {
        let asciiChars = Set("​     _-,、;:!¡?¿.·'\"«»()[]{}§¶@*/\\&#%‧`´^¯¨¸ˋ°©®+±÷×<=>¬|¦~¤¢$£¥01½¼23¾456789aAáÁàÀâǎåäãāĀæbBcCçdDðeEéÉèÈêěëēĒfFgGhHiIíìîǐïījJkKlLmMḿnNǹňñoOóòôǒöõøōpPqQrRsSßtTuUúùûǔüÜǘǜǚūvVwWxXyYýÿzZþµ")
        let filteredText = text.filter {!asciiChars.contains($0) }
        var newlinesString = filteredText.replacingOccurrences(of: "\n\n", with: "\n")
        while (newlinesString.contains("\n\n"))
        {
            newlinesString = newlinesString.replacingOccurrences(of: "\n\n", with: "\n")
        }
        return newlinesString
    }

    func removeNonAsciiFromString(text: String) -> String {
        let asciiChars = Set("​     _-,、;:!¡?¿.·'\"«»()[]{}§¶@*/\\&#%‧`´^¯¨¸ˋ°©®+±÷×<=>¬|¦~¤¢$£¥01½¼23¾456789aAáÁàÀâǎåäãāĀæbBcCçdDðeEéÉèÈêěëēĒfFgGhHiIíìîǐïījJkKlLmMḿnNǹňñoOóòôǒöõøōpPqQrRsSßtTuUúùûǔüÜǘǜǚūvVwWxXyYýÿzZþµ")
        let filteredText = text.filter {asciiChars.contains($0) }
        
        var newlinesString = filteredText.replacingOccurrences(of: "\n\n", with: "\n")
        while (newlinesString.contains("\n\n"))
        {
            newlinesString = newlinesString.replacingOccurrences(of: "\n\n", with: "\n")
        }
        return newlinesString
    }

}
