import UIKit
import MapKit
import CoreLocation

class MapAddressController: UIViewController , CLLocationManagerDelegate , MKMapViewDelegate {
    
    //make a custome point class to store later the id of each donator
    class CustomePoint : MKPointAnnotation{
        var id : String!
    }
    
    @IBOutlet weak var MyMap: MKMapView!
    
    var locationManager = CLLocationManager()
    let prefs = UserDefaults.standard
    var token = ""
    
    //var deliveryRequest : DeliveryRequestController!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        tabBarController?.navigationItem.title = "בחר את המשלוחים שברצונך לקחת"
        
        let b = UIBarButtonItem(title: "התנתק", style: .plain, target: self, action: #selector(backcheck))
        tabBarController?.navigationItem.leftBarButtonItem = b
        self.navigationItem.hidesBackButton = true
        
        //Remove all annotations from the map, so that later, the user(messenger) will see only the annotations that he didnt choose yet. - he can choose to add and remove annotations from the map.
        MyMap.removeAnnotations(MyMap.annotations)
        
        if let tok = prefs.string(forKey: "token"){
            token = tok
            ServerConnections.getDoubleArrayAsync("/requests", [token, "מחכה"], handler: { requestsArray in
                if let array = requestsArray{
                    //Add all donators addresses to the map - so the messenger can see now the donators that wait for delivery of their donations.
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
        
        MyMap.mapType = .standard // regular map style
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mylocation()
    }
    
    func addPlaceToMap(place_name : String, id: String){
        let addressTry = place_name
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(addressTry, completionHandler: { (placemarks, error) in
            if let longitude = placemarks?.first?.location?.coordinate.longitude{
                if let latitude = placemarks?.first?.location?.coordinate.latitude{
                    UIApplication.shared.isIdleTimerDisabled = true
                    self.addMyMarkers(name: place_name, PinLatitude: latitude, PinLongitude: longitude, id: id)
                }
            }  
        })
    }
    
    func addMyMarkers(name: String, PinLatitude: Double, PinLongitude:Double, id: String){
        let pin = CustomePoint()
        pin.id = id
        pin.title = "\(name)"
        pin.coordinate = CLLocationCoordinate2D(latitude: PinLatitude, longitude: PinLongitude)
        
        MyMap.addAnnotation(pin) // add pin to map
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pin.canShowCallout = true
        pin.leftCalloutAccessoryView = UIButton(type: .contactAdd)
        pin.leftCalloutAccessoryView?.tintColor = UIColor(named: "textColor")
        pin.animatesDrop = true
        
        
        if pin.annotation?.coordinate.latitude == MyMap.userLocation.coordinate.latitude && pin.annotation?.coordinate.longitude == MyMap.userLocation.coordinate.longitude {
            pin.leftCalloutAccessoryView?.isHidden = true
            pin.pinTintColor = UIColor(named: "textColor")
        }
        
        return pin
    }
    
    // the function start when the button on annotation is pressed
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let custome_point = view.annotation as? CustomePoint
        print((custome_point?.id)!)
            if let id = custome_point?.id{
                ServerConnections.getArrayAsync("/add_my_request", [token, id], handler: {array in
                    //self.deliveryRequest = DeliveryRequestController()
                    self.MyMap.removeAnnotation(custome_point!)
                })
                
            }
    }
    
    func mylocation(){
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
        
        // real time loaction from a iphone device
        let myLocation = CLLocationCoordinate2DMake((self.locationManager.location?.coordinate.latitude)!, (self.locationManager.location?.coordinate.longitude)!)
        
        // in case i open the app in the emulator - set region(focus map) on holon israel- instead of san francisco
        //let myLocation = CLLocationCoordinate2DMake(32.0158, 34.7874)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        self.MyMap.setRegion(region, animated: false)
        self.MyMap.userLocation.title = "        המיקום שלי"
        self.MyMap.showsUserLocation = true
        
    }
    
    //logout from the system
    @objc func backcheck(){
        //let main = storyboard!.instantiateViewController(withIdentifier: "main")
        let alert =  UIAlertController(title:"יציאה מהמערכת", message: "האם אתה בטוח שברצונך להתנתק מהמערכת?", preferredStyle: .alert)
        
        func okHandler(alert: UIAlertAction!){
            navigationController?.popToRootViewController(animated: true)
            let prefs = UserDefaults.standard
            prefs.removeObject(forKey: "token")
        }
        
        alert.addAction(UIAlertAction(title: "ביטול", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "אישור", style: .default, handler: okHandler))
        
        present(alert, animated: true, completion: nil)
    }
    
}
