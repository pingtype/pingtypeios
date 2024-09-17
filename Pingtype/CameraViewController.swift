//
//  CameraViewController.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 11/11/23.
//

import UIKit
import Vision
import MediaPlayer


class CameraViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var delegate: isAbleToReceiveData!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet var thisView: UIView!
    
    @IBAction func takePhotoButtonTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            self.imagePickerController.takePicture()
        } else{
            print("Error on taking picture")
        }
    }
    
    private lazy var imagePickerController: UIImagePickerController = {
        let imagePickers = UIImagePickerController()
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            imagePickers.delegate = self
            imagePickers.sourceType = UIImagePickerController.SourceType.camera
            imagePickers.view.frame = cameraView.bounds
            imagePickers.allowsEditing = false
            imagePickers.showsCameraControls = true
        }
        return imagePickers
    }()

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            print("Image:\(image)")
            
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
                            print(recognizedString)
                            
                            //let searchTextSender: [String: Any?] = ["text": recognizedString]
                            
                            self.delegate.pass(data: recognizedString)
                            self.navigationController?.popViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)
                            //self.performSegue(withIdentifier: "CameraToMain", sender: searchTextSender)
                            
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
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                
        addCameraInView()
    }
    
    private func addCameraInView(){
        // Add the imageviewcontroller to UIView as a subview
        self.cameraView.addSubview((imagePickerController.view))
    }

    
    
}
