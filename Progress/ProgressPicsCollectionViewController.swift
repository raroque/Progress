//
//  ProgressPicsCollectionViewController.swift
//  Progress
//
//  Created by Christian Raroque on 8/18/16.
//  Copyright © 2016 AloaLabs. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher
import DKImagePickerController

private let reuseIdentifier = "Cell"

class ProgressItem: NSObject {
    var imageUrl = ""
    var image = UIImage()
    var weight = 0.0
    var timestamp = Date()
    var dateString = "No date"
    var object: NSManagedObject?
}

class ProgressPicsCollectionViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var progressPicsCollectionView: UICollectionView!
    @IBOutlet weak var comparePhotosButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var deletePhotosButton: UIButton!
    
    var assets: [DKAsset]?
    
    var sectionsInTable = ["Just a sec."]
    
    var progressItems = [ProgressItem]()
    var photosSelected = [ProgressItem]()
    var forDeletion = [ProgressItem]()
    var forDeletionIndexes = [IndexPath]()
    
    var imageToPost = UIImage()
    let pickerController = DKImagePickerController()
    
    var collectionViewLayout: CustomImageFlowLayout!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat = 0.0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
     //   self.comparePhotosButton.isHidden = true
     //   self.deletePhotosButton.isHidden = true
     //   self.cameraButton.isHidden = false
        
     //   loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        self.progressPicsCollectionView.dataSource = self
        self.progressPicsCollectionView.delegate = self
        
    //    var footerView = UIView()
      //  footerView.frame = CGRectMake(0, self.progressPicsCollectionView.height - 78, screenSize.width, 78)
      //  self.progressPicsCollectionView.addSubview(footerView)

        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(ProgressPicsCollectionViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.progressPicsCollectionView.addGestureRecognizer(lpgr)
        
        
        
        collectionViewLayout = CustomImageFlowLayout()
        collectionViewLayout.headerReferenceSize = CGSize(width: self.progressPicsCollectionView.frame.width, height: 21)
        progressPicsCollectionView.collectionViewLayout = collectionViewLayout
        progressPicsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 77, right: 0)
        /*
        // Change layout of the collectionview
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenWidth/4, height: screenWidth/4)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.progressPicsCollectionView.collectionViewLayout = layout */


        
        var image = UIImage(named: "logo")
        self.navigationItem.titleView = UIImageView(image: image)
        
        self.navigationController?.navigationBar.tintColor = colorWithHexString("ffffff")
        self.navigationController?.navigationBar.barTintColor = colorWithHexString("ffffff")
        
        self.comparePhotosButton.isHidden = true
        self.deletePhotosButton.isHidden = true
        self.cameraButton.isHidden = false
        loadData()
    }
    
    func handleLongPress(_ gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.began {
            return
        }
        
        let p = gestureReconizer.location(in: self.progressPicsCollectionView)
        let indexPath = self.progressPicsCollectionView.indexPathForItem(at: p)
        
        if let index = indexPath {
            var cell = self.progressPicsCollectionView.cellForItem(at: index)
            // do stuff with your cell, for example print the indexPath
            deleteSelected(index)
        } else {
            NSLog("idk index path")
        }
    }
    
    func deleteSelected(_ indexPath: IndexPath) {
        NSLog("deleted selected called")
        
        if self.photosSelected.count == 0 {
            let selectedForDeletionProgressItems = self.getSectionItems((indexPath as NSIndexPath).section)
            let selectedProgressItem = selectedForDeletionProgressItems[(indexPath as NSIndexPath).row]
            if(self.forDeletion.contains(selectedProgressItem)) {
                let indexOfSelected = self.forDeletion.index(of: selectedProgressItem)
                self.forDeletion.remove(at: indexOfSelected!)
                self.forDeletionIndexes.remove(at: indexOfSelected!)
                if let cell = self.progressPicsCollectionView.cellForItem(at: indexPath) as? ProgressPicsCollectionViewCell {
                    cell.selectedOverlayImageView.image = UIImage(named: "deleteSelected")
                    cell.selectedOverlayImageView.isHidden = true
                }
                
            } else {
                self.forDeletion.append(selectedProgressItem)
                self.forDeletionIndexes.append(indexPath)
                if let cell = self.progressPicsCollectionView.cellForItem(at: indexPath) as? ProgressPicsCollectionViewCell {
                    cell.selectedOverlayImageView.image = UIImage(named: "deleteSelected")
                    cell.selectedOverlayImageView.isHidden = false
                }
            }
            
            if(forDeletion.count >= 1) {
                self.deletePhotosButton.isHidden = false
                //    self.cameraButton.makeX()(0).makeY()(self.view.frame.height).makeWidth()(self.view.frame.width).makeHeight()(30).spring().animate()(1.0)
                self.cameraButton.isHidden = true
            } else {
                self.deletePhotosButton.isHidden = true
                self.cameraButton.isHidden = false
            }
        }
    }
    
    /*
    func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        
        let lightboxImages = images.map {
            return LightboxImage(image: $0)
        }
        
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        imagePicker.presentViewController(lightbox, animated: true, completion: nil)
    }
    
    func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    func cancelButtonDidPress(imagePicker: ImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    } */
    
    func loadData() {
        
        self.photosSelected.removeAll()
        self.forDeletion.removeAll()
        self.forDeletionIndexes.removeAll()
        self.progressItems.removeAll(keepingCapacity: false)
        self.sectionsInTable.removeAll(keepingCapacity: false)
        
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entry")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        //3
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            var entries = results as! [NSManagedObject]
            for entry in entries {
                var item = ProgressItem()
                if let timestampTemp = entry.value(forKey: "timestamp") as? Date {
                    item.timestamp = timestampTemp
                }
                
                if let weightTemp = entry.value(forKey: "weight") as? Double {
                    item.weight = weightTemp
                }
                
                if let imageUrlTemp = entry.value(forKey: "imageUrl") as? String {
                    NSLog("got a url \(imageUrlTemp)")
                    item.imageUrl = imageUrlTemp
                    item.image = loadImageFromPath(imageUrlTemp)!
                } else {
                    NSLog("didn't get a url")
                }
                
                
                item.object = entry
                
                addSection(item)
                
                self.progressItems.append(item)
                
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        NSLog("done loading items, there are \(self.progressItems.count) items")
        self.progressPicsCollectionView.reloadData()
    }
    
    func addSection(_ item: ProgressItem) {
        // Format the dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let formattedDate = dateFormatter.string(from: item.timestamp) as NSString
        
        var isASection = false
        
        for date in self.sectionsInTable {
            if(date == formattedDate as String) {
                isASection = true
            }
        }
        
        if(!isASection) {
            self.sectionsInTable.append("\(formattedDate)")
        }
        
        item.dateString = "\(formattedDate)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        let progressItems = self.getSectionItems(section)
        return progressItems.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sectionsInTable.count
    }
    
    func collectionView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            let headerView =
                collectionView.dequeueReusableSupplementaryView(ofKind: kind,withReuseIdentifier: "headerCell", for: indexPath) as! HeaderCollectionViewCell
            headerView.headerLabel.text = "\(sectionsInTable[(indexPath as NSIndexPath).section])"
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.progressPicsCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProgressPicsCollectionViewCell
    
        // Configure the cell
        let progressItems = self.getSectionItems((indexPath as NSIndexPath).section)
        
        NSLog("number of items is \(progressItems.count) index path is \((indexPath as NSIndexPath).row)")
        let progressItem = progressItems[(indexPath as NSIndexPath).row]
        NSLog("url is \(progressItem.imageUrl)")
    //    cell.proPicView.kf_setImageWithURL(NSURL(string: "\(progressItem.imageUrl)"))
        
        DispatchQueue.main.async(execute: {
            cell.proPicView.image = progressItem.image
        })
        
        cell.proPicView.contentMode = UIViewContentMode.scaleAspectFill
        
        cell.proPicView.layer.cornerRadius = 5
        cell.proPicView.layer.masksToBounds = true
        
    
        
        if self.photosSelected.contains(progressItem) || self.forDeletion.contains(progressItem) {
            cell.selectedOverlayImageView.isHidden = false
        } else {
            cell.selectedOverlayImageView.isHidden = true
        }
        
        if self.forDeletion.contains(progressItem) {
            cell.selectedOverlayImageView.image = UIImage(named: "deleteSelected")
        } else if self.photosSelected.contains(progressItem) {
            cell.selectedOverlayImageView.image = UIImage(named: "overlaySelected")
        }
        
        
    
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        title = sectionsInTable[section]
        
        return title
    }
    
    @IBAction func takePhoto(_ sender: AnyObject) {
     //   self.presentViewController(fusuma, animated: true, completion: nil)
    //    self.presentViewController(imagePickerController, animated: true, completion: nil)
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            self.assets = assets
            self.performSegue(withIdentifier: "postPicture", sender: nil)
        }
        
        pickerController.showsCancelButton = true
        pickerController.didCancel = {
       //     self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        pickerController.assetType = DKImagePickerControllerAssetType.allAssets
        pickerController.allowsLandscape = false
        pickerController.allowMultipleTypes = false
        pickerController.sourceType = DKImagePickerControllerSourceType.both
        pickerController.autoDownloadWhenAssetIsInCloud = true
        
        self.present(pickerController, animated: true) {}
    }
    /*
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((collectionView.frame.size.width / 3) - 20, 100)
    } */
    
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(_ image: UIImage) {
        
        print("Image selected")
        self.imageToPost = image
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(_ image: UIImage) {
        
        print("Called just after FusumaViewController is dismissed.")
        self.performSegue(withIdentifier: "postPicture", sender: self)
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        print("Called just after a video has been selected.")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NSLog("for deletion is \(self.forDeletion.count)")
        
        if self.forDeletion.count == 0 {
            let selectedProgressItems = self.getSectionItems((indexPath as NSIndexPath).section)
            let selectedProgressItem = selectedProgressItems[(indexPath as NSIndexPath).row]
            
            if self.photosSelected.count <= 2 {
                if(self.photosSelected.contains(selectedProgressItem)) {
                    let indexOfSelected = self.photosSelected.index(of: selectedProgressItem)
                    self.photosSelected.remove(at: indexOfSelected!)
                    if let cell = collectionView.cellForItem(at: indexPath) as? ProgressPicsCollectionViewCell {
                        cell.selectedOverlayImageView.image = UIImage(named: "overlaySelected")
                        cell.selectedOverlayImageView.isHidden = true
                    }
                    
                } else if (self.photosSelected.count < 2) {
                    self.photosSelected.append(selectedProgressItem)
                    
                    if let cell = collectionView.cellForItem(at: indexPath) as? ProgressPicsCollectionViewCell {
                        cell.selectedOverlayImageView.image = UIImage(named: "overlaySelected")
                        cell.selectedOverlayImageView.isHidden = false
                    }
                }
                
                if(photosSelected.count == 1) {
                    self.comparePhotosButton.isHidden = false
                    self.comparePhotosButton.isEnabled = false
                    //    self.cameraButton.makeX()(0).makeY()(self.view.frame.height).makeWidth()(self.view.frame.width).makeHeight()(30).spring().animate()(1.0)
                    self.comparePhotosButton.setTitle("Select 1 More Photo", for: UIControlState())
                    self.cameraButton.isHidden = true
                } else if(photosSelected.count == 2) {
                    self.comparePhotosButton.isHidden = false
                    self.comparePhotosButton.isEnabled = true
                    self.comparePhotosButton.setTitle("Compare Photos", for: UIControlState())
                    self.cameraButton.isHidden = true
                } else {
                    self.comparePhotosButton.isHidden = true
                    self.cameraButton.isHidden = false
                }
            }
        }

        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postPicture" {
            let navVC = segue.destination as! UINavigationController
            let newVC = navVC.viewControllers.first as! AddPhotoViewController
            newVC.assets = self.assets
        }
        
        if segue.identifier == "comparePhotos" {
            let navVC = segue.destination as! UINavigationController
            let newVC = navVC.viewControllers.first as! ComparePhotosViewController
            newVC.progressPics = self.photosSelected
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
    
    @IBAction func comparePhotos(_ sender: AnyObject) {
    }
    
    
    func getSectionItems(_ section: Int) -> [ProgressItem] {
        var sectionItems = [ProgressItem]()
        
        if(self.progressItems.count == 0) {
             NSLog("no event data present WTFTFTF")
        }
        
        // loop through the testArray to get the items for this sections's date
        for item in self.progressItems {
            let proPic = item as ProgressItem
            let dayOfWeek = proPic.dateString
            
            NSLog("day of week is \(dayOfWeek)")
            
            // if the item's date equals the section's date then add it
            if dayOfWeek == (self.sectionsInTable[section] as NSString) as String {
                NSLog("appended something")
                sectionItems.append(proPic)
            } else {
                NSLog("thing is \(self.sectionsInTable[section] as NSString)")
            }
        }
        return sectionItems
    }
    
    func getDayOfWeek()->NSString {
        
        let todayDate = Date()
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM d, yyyy"
        
        let dayOfWeek = dayTimePeriodFormatter.string(from: todayDate)
        return dayOfWeek as NSString
    }
    
    func removeEmptySections() {
        var numberToRemove = [Int]()
        
        for i in stride(from: self.sectionsInTable.count - 1, to: 0, by: -1){
            var numberOfEventsInSection = 0
            let day = self.sectionsInTable[i] as NSString
            for event in self.progressItems {
                if(day == event.dateString as NSString) {
                    numberOfEventsInSection += 1
                }
            }
            if(numberOfEventsInSection == 0) {
                numberToRemove.append(i)
            }
        }
        

        
        for index in numberToRemove {
            self.sectionsInTable.remove(at: index)
        }
    }
    
    @IBAction func deletePhotos(_ sender: AnyObject) {
        
        var indexPaths = [Int]()
        
        for progressItem in self.forDeletion {
            let indexPath = self.progressItems.index(of: progressItem)
            
            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext
            context.delete(self.progressItems[indexPath!].object! as NSManagedObject)
            self.progressItems.remove(at: indexPath!)
            do {
                try context.save()
            } catch _ {
                NSLog("lol")
            }
        }
        
        self.progressPicsCollectionView.deleteItems(at: self.forDeletionIndexes)
        self.removeEmptySections()
        
        self.forDeletion.removeAll()
        self.forDeletionIndexes.removeAll()
        self.deletePhotosButton.isHidden = true
        self.cameraButton.isHidden = false
        
    }
    

}

func colorWithHexString (_ hex:String) -> UIColor {
 //   var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercased()
    var cString:String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()

    
    if (cString.hasPrefix("#")) {
        cString = (cString as NSString).substring(from: 1)
    }
    
    if (cString.characters.count != 6) {
        return UIColor.gray
    }
    
    let rString = (cString as NSString).substring(to: 2)
    let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
    let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
    
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    Scanner(string: rString).scanHexInt32(&r)
    Scanner(string: gString).scanHexInt32(&g)
    Scanner(string: bString).scanHexInt32(&b)
    
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
}

class CustomImageFlowLayout: UICollectionViewFlowLayout {
    
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    override var itemSize: CGSize {
        set {
            
        }
        get {
            let numberOfColumns: CGFloat = 4
            
         //   let itemWidth = (CGRectGetWidth(self.collectionView!.frame) - (numberOfColumns - 1)) / (numberOfColumns + 1)
            let itemWidth = UIScreen.main.bounds.size.width / 4.6875
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    func setupLayout() {
        let itemWidth = UIScreen.main.bounds.size.width / 4.6875
        let edgeWidth = (UIScreen.main.bounds.size.width - (itemWidth * 4)) / 5
        sectionInset = UIEdgeInsets(top: edgeWidth, left: edgeWidth, bottom: edgeWidth, right: edgeWidth)
        minimumInteritemSpacing = 1
        minimumLineSpacing = edgeWidth
        scrollDirection = .vertical
    }
    
}
