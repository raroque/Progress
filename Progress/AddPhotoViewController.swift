//
//  AddPhotoViewController.swift
//  Progress
//
//  Created by Christian Raroque on 8/18/16.
//  Copyright © 2016 AloaLabs. All rights reserved.
//

import UIKit
import CoreData
import DKImagePickerController
import DatePickerDialog
import AVFoundation

class AddPhotoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var progressPicImageView: UIImageView!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var dateButton: UIButton!
    
    @IBOutlet weak var progressPicCollectionView: UICollectionView!
    
    var proPicImage = UIImage()
    var ProPicImages = [UIImage]()
    
    var assets: [DKAsset]?
    var dateOfProgress = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM d, yyyy"
        
        if let asset = assets![0] as? DKAsset {
            if let originalAsset = asset.originalAsset {
                originalAsset.mediaType
                originalAsset.mediaSubtypes
                originalAsset.creationDate
                originalAsset.modificationDate
                // ...
                dateOfProgress = originalAsset.creationDate!
            }
        }
        var betterDate = dayTimePeriodFormatter.string(from: dateOfProgress)
        self.dateButton.setTitle("\(betterDate)", for: UIControlState())
        
        // Do any additional setup after loading the view.
        progressPicCollectionView.delegate = self
        progressPicCollectionView.dataSource = self
        
    //    progressPicImageView.image = proPicImage
        progressPicCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.progressPicCollectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! AddPhotoCollectionViewCell
        
        // Configure the cell
        let asset = self.assets![(indexPath as NSIndexPath).row]
        
        //    cell.proPicView.kf_setImageWithURL(NSURL(string: "\(progressItem.imageUrl)"))
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        asset.fetchImageWithSize(layout.itemSize.toPixel(), completeBlock: { image, info in
            cell.proImageView.image = image
        })
        cell.proImageView.contentMode = UIViewContentMode.scaleAspectFill
        
        cell.proImageView.layer.cornerRadius = 5
        cell.proImageView.layer.masksToBounds = true
        
        // Set cell width to 100%
        //   let collectionViewWidth = self.progressPicsCollectionView.bounds.size.width
        //    cell.frame.size.width = collectionViewWidth / 4
        //   cell.frame.size.height = collectionViewWidth / 4
        
        cell.contentView.frame = cell.bounds
        cell.contentView.autoresizingMask = [.flexibleLeftMargin,
                                             .flexibleWidth,
                                             .flexibleRightMargin,
                                             .flexibleTopMargin,
                                             .flexibleHeight,
                                             .flexibleBottomMargin]
        
        return cell
    }
    
    @IBAction func pickDate(_ sender: AnyObject) {
        DatePickerDialog().show("Pick a date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            
            if date != nil {
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "MMM d, yyyy"
                
                let betterDate = dayTimePeriodFormatter.string(from: date!)
                self.dateButton.setTitle("\(betterDate)", for: UIControlState())
                self.dateOfProgress = date!
            }
        }
    }
    
    
    
    @IBAction func cancelButtonClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        
        for asset in self.assets! {
    
            var proImage = UIImage()
            asset.fetchOriginalImageWithCompleteBlock({ (image, info) in
                proImage = image!
                
                
                // Save the photo
                let id = self.randomString(12)
                let myImageName = "\(id).jpg"
                let imagePath = self.fileInDocumentsDirectory(myImageName)
                
                NSLog("output url is \(imagePath)")
                
                if self.saveImage(proImage, path: imagePath) {
                    NSLog("saved")
                }
                
                //   saveImage(proPicImage, path: imagePath)
                
                
                // Done posting
                let appDelegate =
                    UIApplication.shared.delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                
                let entity =  NSEntityDescription.entity(forEntityName: "Entry",
                    in:
                    managedContext)
                let progressPic = NSManagedObject(entity: entity!,
                    insertInto:managedContext)
                
                progressPic.setValue(self.dateOfProgress, forKey: "timestamp")
                progressPic.setValue("\(myImageName)", forKey: "imageUrl")
                
                // Check if weight is empty
                if (!(self.weightTextField.text?.isEmpty)!) {
                    progressPic.setValue(Int(self.weightTextField.text!), forKey: "weight")
                } else {
                    progressPic.setValue(0.0, forKey: "weight")
                }
                
                do {
                    try managedContext.save()
                    self.dismiss(animated: true, completion: nil)
                } catch _ {
                    NSLog("lol")
                }
            })
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let optionMenu = UIAlertController(title: nil, message: "Remove photo?", preferredStyle: .actionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Yes Please", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.assets?.remove(at: (indexPath as NSIndexPath).row)
            self.progressPicCollectionView.deleteItems(at: [indexPath])
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func getDocumentsURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(_ filename: String) -> String {
        
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL.path
        
    }
    
    func saveImage (_ image: UIImage, path: String ) -> Bool{
        
        //let pngImageData = UIImagePNGRepresentation(image)
        let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
        let result = (try? jpgImageData!.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil
        
        return result
        
    }
    
    func randomString(_ length: Int) -> String {
        let charactersString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let charactersArray : [Character] = Array(charactersString.characters)
        
        var string = ""
        for _ in 0..<length {
            string.append(charactersArray[Int(arc4random()) % charactersArray.count])
        }
        
        return string
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
