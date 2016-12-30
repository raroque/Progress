//
//  ComparePhotosViewController.swift
//  Progress
//
//  Created by Christian Raroque on 9/7/16.
//  Copyright © 2016 AloaLabs. All rights reserved.
//

import UIKit

class ComparePhotosViewController: UIViewController, UIScrollViewDelegate {
    
    
    @IBOutlet weak var scrollView1: UIScrollView!
    @IBOutlet weak var scrollView2: UIScrollView!
    
    @IBOutlet weak var date1: UILabel!
    @IBOutlet weak var weight1: UILabel!
    @IBOutlet weak var date2: UILabel!
    @IBOutlet weak var weight2: UILabel!

    var progressPics = [ProgressItem]()
    var imageView1 = UIImageView()
    var imageView2 = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if progressPics.count == 2 {
            
            var item1 = ProgressItem()
            var item2 = ProgressItem()
            
            if(self.progressPics[0].timestamp < self.progressPics[1].timestamp) {
                item1 = self.progressPics[0]
                item2 = self.progressPics[1]
            } else {
                item1 = self.progressPics[1]
                item2 = self.progressPics[0]
            }
            
            let image1 = loadImageFromPath(item1.imageUrl)!
            let image2 = loadImageFromPath(item2.imageUrl)!

            var date1 = item1.timestamp
            var date2 = item2.timestamp
            
            var weight1 = item1.weight
            var weight2 = item2.weight
            
            self.weight1.text = "\(weight1) pounds"
            self.weight2.text = "\(weight2) pounds"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            let formattedDate1 = dateFormatter.string(from: date1) as NSString
            let formattedDate2 = dateFormatter.string(from: date2) as NSString
            self.date1.text = "\(formattedDate1)"
            self.date2.text = "\(formattedDate2)"
            
            scrollView1.bounces = false
            scrollView1.contentSize = CGSize(width: image1.size.width / 8, height: image1.size.height / 8)
            scrollView1.clipsToBounds = true
         
            imageView1.contentMode = UIViewContentMode.scaleAspectFit
            
            scrollView1.delegate = self
            scrollView1.alwaysBounceVertical = false
            scrollView1.alwaysBounceHorizontal = false
            scrollView1.showsVerticalScrollIndicator = true
            scrollView1.flashScrollIndicators()
            scrollView1.backgroundColor = colorWithHexString("#F6F6F6")
            scrollView1.minimumZoomScale = 1.0
            scrollView1.maximumZoomScale = 10.0
            
            imageView1.frame = self.scrollView1.bounds
            imageView1.frame = CGRect(x: 0, y: 0, width: image1.size.width / 8, height: image1.size.height / 8)
            imageView1.isUserInteractionEnabled = true
            imageView1.image = image1
            imageView1.layer.cornerRadius = 11.0
            imageView1.clipsToBounds = false
            scrollView1.addSubview(imageView1)
            
            // view 2
            scrollView2.bounces = false
            scrollView2.contentSize = CGSize(width: image2.size.width / 8, height: image2.size.height / 8)
            scrollView2.clipsToBounds = true
            
            imageView2.contentMode = UIViewContentMode.scaleAspectFit
            
            scrollView2.delegate = self
            scrollView2.alwaysBounceVertical = false
            scrollView2.alwaysBounceHorizontal = false
            scrollView2.showsVerticalScrollIndicator = true
            scrollView2.flashScrollIndicators()
            scrollView2.backgroundColor = colorWithHexString("#F6F6F6")
            scrollView2.minimumZoomScale = 1.0
            scrollView2.maximumZoomScale = 10.0
            
            imageView2.frame = self.scrollView2.bounds
            imageView2.frame = CGRect(x: 0, y: 0, width: image2.size.width / 8, height: image2.size.height / 8)
            imageView2.isUserInteractionEnabled = true
            imageView2.image = image2
            imageView2.layer.cornerRadius = 11.0
            imageView2.clipsToBounds = false
            scrollView2.addSubview(imageView2)
        } else {
     
        }
    }
    
   func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == self.scrollView1 {
            NSLog("it is number 1")
            return self.imageView1
        } else {
            return self.imageView2
    }
    }
 
    func loadImageFromPath(_ path: String) -> UIImage? {
        
        let imagePath = fileInDocumentsDirectory(path)
        let image = UIImage(contentsOfFile: imagePath)
        
        if image == nil {
            
            print("missing image at: \(imagePath)")
        }
        print("Loading image from path: \(imagePath)") // this is just for you to see the path in case you want to go to the directory, using Finder.
        return image
        
    }
    
    func getDocumentsURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(_ filename: String) -> String {
        
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL.path
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    

}
