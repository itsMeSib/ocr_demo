//
//  ViewController.swift
//  OCR DEMO
//
//  Created by Shahzaib Iqbal Bhatti on 1/20/22.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var labelResult: UILabel!
    
    @IBOutlet weak var labelConfidence: UILabel!
    @IBOutlet weak var labelCode: UILabel!
    
    @IBOutlet weak var selectedImageName: UILabel!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    var imagesToTest = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        populateImages()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        hideActivityLoader()
    }
    
    private func recognizeText(image: UIImage?) {
        guard let cgImage = image?.cgImage else { return }
        
        // Handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Request
        let request = VNRecognizeTextRequest {[weak self] request, error in
            print(request.results)
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil
            else { return }
            
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")
            
            let confidence = observations.compactMap({
                "\($0.confidence)"
            }).joined(separator: ", ")
            
           
            let allTexts = observations.compactMap({
                $0.topCandidates(1).first?.string
            })
            
            self?.checkForPossibleCode(texts: allTexts)
            
            DispatchQueue.main.async {[weak self] in
                self?.labelResult.text = "\(text)"
                self?.labelConfidence.text = "\(confidence)"
                self?.hideActivityLoader()
            }
        }
        
        // Process request
        do {
            try handler.perform([request])
        }catch {
            self.labelResult.text = "\(error)"
            hideActivityLoader()
        }
        
    }
    
    private func checkForPossibleCode(texts: [String]) {
        let probCode = getPromoCode(texts)
        DispatchQueue.main.async {[weak self] in
            self?.labelCode.text = "\(probCode.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: ""))"
        }
    }
    
    private func getPromoCode(_ texts: [String]) -> String {
        var arrayText = texts
        var probCode = "No Promo Code Found"
        if let max = arrayText.max(by: {$1.count > $0.count}) {
            probCode = "\(max)"
            if checkForIllegalCharacters(string: max) {
                probCode = "\(max) Have Special"
                if let index = texts.firstIndex(of: max){
                    arrayText.remove(at: index)
                }
                probCode = getPromoCode(arrayText)
            } else {
                probCode = "\(probCode)"
            }
        }
        return probCode
    }
    
    private func checkForIllegalCharacters(string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "\\/:*?\"<>|.•abcdefghijklmnopqrstuvwxyz")
        .union(.newlines)
        .union(.illegalCharacters)
        .union(.controlCharacters)

        if string.rangeOfCharacter(from: invalidCharacters) != nil {
            print ("Illegal characters detected in file name \(string)")
            // Raise an alert here
            return true
        } else {
           return false
        }
    }
    
    private func populateImages() {
        imagesToTest.removeAll()
        imagesToTest.append(UIImage(named: "imagetestmajor") ?? UIImage())
        imagesToTest.append(UIImage(named: "image") ?? UIImage())
        
        for n in 1 ... 38 {
            if let image = UIImage(named: "imagegroup2-\(n)") {
                imagesToTest.append(image)
            }
        }
        
        for n in 1 ... 25 { //10 is whatever number you want
            if let image = UIImage(named: "image\(n)") {
                imagesToTest.append(image)
            }
        }
    }
    
    private func showActivityLoader() {
        activityLoader.isHidden = false
        activityLoader.startAnimating()
    }
    private func hideActivityLoader() {
        activityLoader.stopAnimating()
        activityLoader.isHidden = true
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showActivityLoader()
        recognizeText(image: imagesToTest[indexPath.row])
        selectedImageName.text = "index: \(indexPath.row)"
    }
}
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imagesToTest.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ImageCell else { return  UICollectionViewCell()}
        cell.imageView.image = imagesToTest[indexPath.row]
        cell.backgroundColor = .red
        return cell
    }
}

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
