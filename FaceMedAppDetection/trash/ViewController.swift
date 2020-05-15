//
//  ViewController.swift
//  FaceMedAppDetection
//
//  Created by Pavel Murzinov on 06.05.2020.
//  Copyright © 2020 Pavel Murzinov. All rights reserved.
//

import UIKit
import Vision
import CoreML
import AVFoundation


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    
    let previewLayer = AVCaptureVideoPreviewLayer()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePicker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        imageView.setNeedsLayout()
        imageView.layoutIfNeeded()
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    @IBAction func pickAPhotoAction(_ sender: Any) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            let request = VNDetectFaceLandmarksRequest { [weak self] (res, err) in
                guard let self = self else { return }
                if let err = err {
                    print("failed to detect face", err)
                    return
                }
                
                var faceCount = 0
                self.imageView.subviews.forEach { (sub) in
                    sub.removeFromSuperview()
                }
                
//                self.imageView.image = image
                self.imageView.contentMode = .scaleAspectFit
                
                var allFace: [CGRect] = []
                res.results?.forEach({ (res) in
                    guard let face = res as? VNFaceObservation else { return }
                    faceCount += 1
                    
                    let faceView = UIView()
                    faceView.backgroundColor = .clear
                    faceView.alpha = 0.4
                    
                    let mySize: CGSize = {
//                        self.imageView.frame.size
                        image.size
                    }()
                    print(face.boundingBox)
                    let x: CGFloat = face.boundingBox.origin.x * mySize.width
                    let w: CGFloat = face.boundingBox.width * mySize.width
                    let h: CGFloat = face.boundingBox.height * mySize.height
                    let y: CGFloat = ( face.boundingBox.origin.y) * mySize.height
                    faceView.frame = CGRect(x: x, y: y, width: w, height: h)
                    allFace.append( CGRect(x: x, y: y, width: w, height: h))
                    self.imageView.addSubview(faceView)
                })
                
                
                var biggerView: CGRect = .zero
                allFace.forEach { (fv) in
                    if fv.width * fv.height > biggerView.width * biggerView.height {
                        biggerView = fv
                    }
                }

                if biggerView == .zero {
                    return
                }
                UIGraphicsBeginImageContextWithOptions(CGSize(width: biggerView.width, height: biggerView.height), true, 0.0)
                image.draw(at: CGPoint(x: -biggerView.origin.x, y: -biggerView.origin.y))
                if let croppedImage = UIGraphicsGetImageFromCurrentImageContext() {
                    self.imageView.image = croppedImage
                }
                
                
                UIGraphicsEndImageContext()
            }
            
            
            guard let cgimage = image.cgImage else { return }
            
            let handler = VNImageRequestHandler(cgImage: cgimage, orientation: .rightMirrored , options: [:])
            do {
                try handler.perform([request])
            } catch let reqErr {
                print(reqErr)
            }
        }
        
        imagePicker.dismiss(animated: true) { [weak self] in
            if let self = self {
                self.personDetection()
            }
        }
    }
    
    private func personDetection() {
        guard let model = try? VNCoreMLModel(for: UserClassification_1().model), let image = imageView.image?.cgImage else {
            return
        }
        
        let request = VNCoreMLRequest(model: model) { (req, err) in
            if let err = err {
                print("Error: ",err)
                return
            }
            
            guard let result = req.results as? [VNClassificationObservation] else {
                return
            }
            
            print(result)
        }
        
        let hundler = VNImageRequestHandler(cgImage: image)
        do {
            try hundler.perform([request])
        } catch let err {
            print("Error_2: ", err)
            return
        }
    }
}

