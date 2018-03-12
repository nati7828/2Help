import UIKit
import MapKit
import CoreLocation

class MapAddressController: UIViewController , CLLocationManagerDelegate , MKMapViewDelegate {

    @IBOutlet weak var MyMap: MKMapView!
    var locationManager = CLLocationManager()
    let prefs = UserDefaults.standard
    var token = ""
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.navigationItem.title = "בחר את המשלוחים שברצונך לקחת"
        
        let b = UIBarButtonItem(title: "התנתק", style: .plain, target: self, action: #selector(backcheck))
        
        tabBarController?.navigationItem.leftBarButtonItem = b
        self.navigationItem.hidesBackButton = true
    
        MyMap.removeAnnotations(MyMap.annotations)
        if let tok = prefs.string(forKey: "token"){
            token = tok
            ServerConnections.getDoubleArrayAsync("/requests", [token, "מחכה"], handler: { requestsArray in
                if let array = requestsArray{
                    for arr in array{
                        self.addPlaceToMap(place_name: arr[2], id: arr[0])
                    }
                }
            })
        } else {
            //Move back to the main page
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        MyMap.showsCompass = true
        MyMap.showsScale = true
        
        MyMap.mapType = .standard // regular map
        //MyMap.showsUserLocation = true //maybe unnecessary
//        addPlaceToMap(place_name: "התחיה 10 חולון")
//        addPlaceToMap(place_name: "חולון אילת 43")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mylocation()
    }
    
    func addPlaceToMap(place_name : String, id: String){
        let addressTry = place_name
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(addressTry, completionHandler: { (placemarks, error) in
            let longitude = placemarks?.first?.location?.coordinate.longitude
            let latitude = placemarks?.first?.location?.coordinate.latitude
      
            UIApplication.shared.isIdleTimerDisabled = true
            
            self.addMyMarkers(name: place_name, PinLatitude: latitude!, PinLongitude: longitude!, id: id)
            
        })
    }
    
    func addMyMarkers(name: String, PinLatitude: Double, PinLongitude:Double, id: String){
        let pin1 = MKPointAnnotation()
        pin1.subtitle = id
        pin1.title = "\(name)"
        pin1.coordinate = CLLocationCoordinate2D(latitude: PinLatitude, longitude: PinLongitude)
        
        MyMap.addAnnotation(pin1) // add pin1 to map
   
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pin.canShowCallout = true
        pin.leftCalloutAccessoryView = UIButton(type: .contactAdd)
        pin.animatesDrop = true
        
        return pin
    }
    
    // button on annotation is pressed
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let currentAnnotation = view.annotation{
            if let id = currentAnnotation.subtitle{
                ServerConnections.getArrayAsync("/add_my_request", [token, id!], handler: {array in
                    self.MyMap.removeAnnotation(currentAnnotation)
                })
            }
        }
        
        //navigationController?.pushViewController(displayPage, animated: true)
    }
    
    func mylocation(){
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
//        let myLocation = CLLocationCoordinate2DMake((self.locationManager.location?.coordinate.latitude)!, (self.locationManager.location?.coordinate.longitude)!)
        let myLocation = CLLocationCoordinate2DMake(32.0158, 34.7874)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        self.MyMap.setRegion(region, animated: true)
        self.MyMap.userLocation.title = "המיקום שלי"  
        self.MyMap.showsUserLocation = true
    }
    
    
    //logout from the system
    @objc func backcheck(){
        //let main = storyboard!.instantiateViewController(withIdentifier: "main")
        let alert =  UIAlertController(title:"יציאה מהמערכת", message: "האם אתה בטוח שברצונך להתנתק מהמערכת?", preferredStyle: .alert)
        
        func okHandler(alert: UIAlertAction!){
            navigationController?.popToRootViewController(animated: true)
        }
     
        alert.addAction(UIAlertAction(title: "ביטול", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "אישור", style: .default, handler: okHandler))
        
        present(alert, animated: true, completion: nil)
  
    }
}
