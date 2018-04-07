import UIKit

class DeliveryRequestCell: UITableViewCell {
    
    @IBOutlet var address: UILabel!
    @IBOutlet var km_label :UILabel!
    @IBOutlet var icon_adress: UIImageView!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.white.withAlphaComponent(0.5)

    }
    

}
