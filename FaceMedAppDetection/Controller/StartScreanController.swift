//
//  StartScreanController.swift
//  FaceMedAppDetection
//
//  Created by Pavel Murzinov on 11.05.2020.
//  Copyright © 2020 Pavel Murzinov. All rights reserved.
//

import UIKit
import Vision
import CoreML

struct MyColor {
    static let mainColor = #colorLiteral(red: 0.7171078324, green: 0.9898481965, blue: 1, alpha: 1)
    static let buttonColorOne = #colorLiteral(red: 0.9761013389, green: 0.6781292558, blue: 0.002827440854, alpha: 1)
}

class StartScreanController: UIViewController {
    
    @IBOutlet weak var faceScanButton: UIButton!
    @IBOutlet weak var pneumoniaButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    let data: [String] = [
        "Фамилия Имя Отчество",
        "дд.мм.гггг",
        "Адрес проживания",
        "Противопоказания",
        "Дата последнего обращения",
        "История прошлых болезней"
    ]
    
    var image: UIImage? = nil
    var selectButton = 0
    
    var name: String = ""
    var conf = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingUI()
        setupImagePicker()
    }

    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }
    
    private func settingUI() {
        view.backgroundColor = MyColor.mainColor
        [faceScanButton, pneumoniaButton].forEach {
            $0?.backgroundColor = MyColor.buttonColorOne
            $0?.layer.cornerRadius = 10
            $0?.layer.shadowColor = UIColor.black.cgColor
            $0?.layer.shadowOffset = .zero
            $0?.layer.shadowRadius = 2
            $0?.layer.shadowOpacity = 0.8
        }
        
        
        
        
    }
    
    @IBAction func scaningFace(_ sender: UIButton) {
        selectButton = sender.tag
        if sender.tag == 1 {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else if sender.tag == 0 {
            imagePicker.sourceType = .photoLibrary
            alert()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPersonIhfo" {
            guard let vc = segue.destination as? PersonInfoController, let data = sender as? [String] else { return }
            vc.data = data
        }
    }
    
    private func alert() {
        let alertController = UIAlertController(title: "Pneumania", message: "For analysis you will need to choose lungen ringen!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in
            guard let self = self else { return }
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
}

extension StartScreanController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                if selectButton == 0, let img = image.cgImage {
                    self.image = UIImage(cgImage: img)
                    self.dismiss(animated: true) { [weak self] in
                        guard let self = self else { return }
                        self.pneumoniaDettection()
                    }
                    return
                }
                
                let request = VNDetectFaceLandmarksRequest { [weak self] (res, err) in
                    guard let self = self else { return }
                    if let err = err {
                        print("failed to detect face", err)
                        return
                    }
                    
                    var faceCount = 0
                    
                    var allFace: [CGRect] = []
                    res.results?.forEach({ (res) in
                        guard let face = res as? VNFaceObservation else { return }
                        
                        let mySize: CGSize = {
                            image.size
                        }()
                        print(face.boundingBox)
                        let x: CGFloat = face.boundingBox.origin.x * mySize.width
                        let w: CGFloat = face.boundingBox.width * mySize.width
                        let h: CGFloat = face.boundingBox.height * mySize.height
                        let y: CGFloat = ( face.boundingBox.origin.y) * mySize.height
                        allFace.append( CGRect(x: x, y: y, width: w, height: h))
                    })
                    
                    
                    var biggerView: CGRect = .zero
                    allFace.forEach { (fv) in
                        if fv.width * fv.height > biggerView.width * biggerView.height {
                            biggerView = fv
                        }
                    }

                    if biggerView == .zero {
                        self.image = nil
                        return
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(CGSize(width: biggerView.width, height: biggerView.height), true, 0.0)
                    image.draw(at: CGPoint(x: -biggerView.origin.x, y: -biggerView.origin.y))
                    
                    self.image = UIGraphicsGetImageFromCurrentImageContext()
                    
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
    
    private func pneumoniaDettection() {
        guard let model = try? VNCoreMLModel(for: Pneumonia().model), let image = self.image?.cgImage else { return }
        
        let request = VNCoreMLRequest(model: model) { [weak self] (req, err) in
            guard let self = self else { return }
            if let err = err {
                print("Error: ",err)
                return
            }
            
            guard let result = req.results as? [VNClassificationObservation], let first = result.first else {
                return
            }
            
            let alertController = UIAlertController(title: first.identifier, message: "With with probability \(Int(first.confidence * 100))", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Try again", style: .default, handler: { [weak self] (_) in
                guard let self = self else { return }
                self.present(self.imagePicker, animated: true, completion: nil)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        let hundler = VNImageRequestHandler(cgImage: image)
        do {
            try hundler.perform([request])
        } catch let err {
            print("Error_2: ", err)
            return
        }
    }
    
        private func personDetection() {
            guard let model = try? VNCoreMLModel(for: UserClassification_1().model), let image = self.image?.cgImage else {
                return
            }
            
            let request = VNCoreMLRequest(model: model) { [weak self] (req, err) in
                guard let self = self else { return }
                if let err = err {
                    print("Error: ",err)
                    return
                }
                
                guard let result = req.results as? [VNClassificationObservation], let first = result.first else {
                    return
                }
                
                print(first, first.identifier)
                
                if first.identifier == "Pasha" {
                    self.performSegue(withIdentifier: "showPersonIhfo", sender: self.data)
                }
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
