import UIKit
import CoreLocation

class ContactUsController: UIViewController {

    @IBOutlet var number: UIButton!
    @IBOutlet var address: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "צור קשר"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper.jpg")!)
    }
    
    @IBAction func call() {
        //call the organization
        let numberToCall = (number.titleLabel?.text)!
        if let phoneURL = URL(string :"tel://" + numberToCall) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }else{
            print("number is not good")//check
        }
    }
    
    @IBAction func toWaze() {
        //check if waze installed on the iPhone
        if(UIApplication.shared.canOpenURL(URL(string:"waze://")!)){
            
            //let NameUrl = (addresses.text?.replacingOccurrences(of: " ", with: "+"))!
            
            //            let address = "https://waze.com/ul?q=\(NameUrl)"
            //            let addressURL = URL(string: address)
            
            // print("\(addressURL!)")
            
            // geocoding
            
            //let addressTry = "פתח תקווה רוטשילד 119"
            let geoCoder = CLGeocoder()
            //get the address and convert it to coordinates
            geoCoder.geocodeAddressString((address.titleLabel?.text)!, completionHandler: { (placemarks, error) in
                let longitude = placemarks?.first?.location?.coordinate.longitude
                let latitude = placemarks?.first?.location?.coordinate.latitude

                
                let addressURL = URL(string: "http://waze.com/ul?ll=\(latitude!),\(longitude!)&navigate=yes")
                
                
                UIApplication.shared.open(addressURL!, options: [:], completionHandler: nil)
                UIApplication.shared.isIdleTimerDisabled = true
                
            })
            
            ////
            
        } else {
            //else open a web url that says waze is not installed and link to appstore to download waze
            let url = URL(string:"https://itunes.apple.com/app/apple-store/id323229106?mt=8")
           
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
        
    }
    
    @IBAction func toWebsite() {
        if let url = URL(string: "https://www.2help.org.il/") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func toFacebook() {
        let fbProfileId = URL(string: "fb://profile/138399090105076") //2help profile id
        //check if facebook app exists
        if UIApplication.shared.canOpenURL(fbProfileId!){
            //open the 2help profile in the facebook app
            UIApplication.shared.open(fbProfileId!)
        }else {
            //if not exists, open in safari
            if let url = URL(string: "https://www.facebook.com/2help.org.il/") {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
}
