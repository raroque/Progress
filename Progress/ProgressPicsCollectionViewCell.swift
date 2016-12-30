//
//  ProgressPicsCollectionViewCell.swift
//  Progress
//
//  Created by Christian Raroque on 8/18/16.
//  Copyright © 2016 AloaLabs. All rights reserved.
//

import UIKit

class ProgressPicsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var proPicView: UIImageView!
    @IBOutlet weak var selectedOverlayImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        proPicView.layer.cornerRadius = self.proPicView.frame.width/4.0
        proPicView.layer.masksToBounds = true
        proPicView.image = nil
    }
    
}
