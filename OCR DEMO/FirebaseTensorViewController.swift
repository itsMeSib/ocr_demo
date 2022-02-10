//
//  FirebaseTensorViewController.swift
//  OCR DEMO
//
//  Created by Shahzaib Iqbal Bhatti on 1/24/22.
//

import UIKit

class FirebaseTensorViewController: UIViewController {

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

extension FirebaseTensorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showActivityLoader()
        selectedImageName.text = "index: \(indexPath.row)"
        
    }
}
extension FirebaseTensorViewController: UICollectionViewDataSource {
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
