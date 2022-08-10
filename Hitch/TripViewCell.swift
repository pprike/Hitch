//
//  TripViewCell.swift
//  Hitch
//
//  Created by Parikshit Murria on 2022-08-01.
//
import UIKit

class TripViewCell: UITableViewCell {
    
    @IBOutlet weak var orderId: UILabel!
    
    @IBOutlet weak var pickupLoc: UILabel!
    
    @IBOutlet weak var dropLoc: UILabel!
    
    @IBOutlet weak var orderDate: UILabel!
    
    @IBOutlet weak var orderTime: UILabel!
        
    @IBOutlet weak var orderItemName: UILabel!
    
    @IBOutlet weak var categoryImageView: UIImageView!
    
    @IBOutlet weak var imageBgView: UIView!
     
    @IBOutlet weak var orderStatusTag: UIButton!
    
    @IBOutlet weak var driversEarning: UILabel!
    
    @IBOutlet weak var tripDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
