//
//  BeaconCell.swift
//  iBeacons
//
//  Created by James on 02/02/2018.
//  Copyright © 2018 Rantmedia Ltd. All rights reserved.
//

import UIKit

class BeaconCell: UITableViewCell {

	@IBOutlet weak var idLabel: UILabel!
	@IBOutlet weak var majorLabel: UILabel!
	@IBOutlet weak var minorLabel: UILabel!
	@IBOutlet weak var proximityLabel: UILabel!
	@IBOutlet weak var unknown: UIView!
	@IBOutlet weak var far: UIView!
	@IBOutlet weak var near: UIView!
	@IBOutlet weak var immediate: UIView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
