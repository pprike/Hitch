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
    
    @IBOutlet weak var orderStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
