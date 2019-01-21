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

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        picker.delegate = self
    }


    @IBAction func loadImage(_ sender: Any) {
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage{
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController{
    func detectScene(image: CIImage){
        guard let model = try? VNCoreMLModel(for: VGG16().model) else {
            fatalError("can't load Places ML model")
        }
        
        
    }
}
