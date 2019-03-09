//
//  ViewController.swift
//  Scene Detection
//
//  Created by Parshva Shah on 1/19/19.
//  Copyright © 2019 Parshva Shah. All rights reserved.
//

import UIKit
import Vision
import CoreML
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageBtn.layer.cornerRadius = 10
        imageBtn.clipsToBounds = true
        cameraBtn.layer.cornerRadius = 10
        cameraBtn.clipsToBounds = true
        picker.delegate = self
    }


    @IBAction func loadImage(_ sender: Any) {
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func captureImage(_ sender: Any) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.allowsEditing = false
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        /* if let pickedImage = info[.originalImage] as? UIImage{
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        } */
        
        guard let pickedImage = info[.originalImage] as? UIImage else {
            fatalError("couldn't load image from Photos")
        }
        
        imageView.image = pickedImage
        imageView.contentMode = .scaleAspectFit
        
        guard let ciImage = CIImage(image: pickedImage) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        
        detectScene(image: ciImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController{
    func detectScene(image: CIImage){
        guard let model = try? VNCoreMLModel(for: SceneDetectionClassifier().model) else {
            fatalError("can't load Places ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.resultLbl.text = "It's \(topResult.identifier) with Confidence: \(Int(topResult.confidence * 100))%"
            }
            
            let string = "It's \(topResult.identifier) with Confidence: \(Int(topResult.confidence * 100))%"
            
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
            
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
        }
        
        // Run the Core ML GoogLeNetPlaces classifier on global dispatch queue
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }

    }
}
