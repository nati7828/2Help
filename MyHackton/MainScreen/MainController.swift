import UIKit
import WebKit
import SafariServices

class MainController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        let prefs = UserDefaults.standard
        prefs.set([:], forKey: "basket")
        
        setCollectionViewProperties()
        
        
        if let token = prefs.string(forKey: "token"){
            ServerConnections.getDoubleArrayAsync("/token_login", [token], handler: {array in
                if let arr = array{
                    if(arr.count > 0){
                        //Job
                        let job = arr[0][0]
                        switch(job){
                        case "שליח":
                            print("שליח")
                            self.ConnectAsDeliveryGuy(false)
                            break
                        case "מחסנאי":
                            print("מחסנאי")
                            self.ConnectAsStorageKeeper(false)
                            break
                        case "מנהל רשת":
                            print("מנהל רשת")
                            self.ConnectAsNetManager(false)
                            break
                        default:
                            print("Old token")
                        }
                    }}
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.backgroundColor = UIColor.clear
        
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper.jpg")!)
        
    }

    @IBAction func toSafari(_ sender: UIButton) {
        let url = URL(string: "https://www.2help.org.il/food")!
        let svc = SFSafariViewController(url: url)
        show(svc, sender: self)
        
    }
    
    @IBAction func login() {
        //alert when pressing the login button
        let alert =  UIAlertController(title: "התחברות", message: "הכנס שם משתמש וסיסמא", preferredStyle: .alert)
        
        alert.addTextField { (tf) in      // textfiled of the username
            tf.placeholder = "שם משתמש"
            tf.textAlignment = .right
            tf.returnKeyType = .next
            
        }
        
        alert.addTextField { (tf) in    // textfield of the password
            tf.placeholder = "סיסמא"
            tf.textAlignment = .right
            tf.isSecureTextEntry = true
            tf.returnKeyType = .done
        }
        
       let  usernameTF = alert.textFields![0]
       let  passwordTF = alert.textFields![1]
        
        func checkLogin(alert:UIAlertAction){
            let username = usernameTF.text!
            let password = passwordTF.text!
            
            //Server Authentication:
            //The username and password will be sent to the server, the server will return a token and a job in array.
            //After that if the server returend data that meants the user was found and takes the user to his page.
            ServerConnections.getArrayAsync("/login", [username, password], handler: {array in
                if let arr = array{
                    if(arr.count > 0){
                        //Tokken from the server
                        let prefs = UserDefaults.standard
                        prefs.set(arr[0], forKey: "token")
                        let job = arr[1]
                        switch(job){
                        case "שליח":
                            print("שליח")
                            self.ConnectAsDeliveryGuy(true)
                            break
                        case "מחסנאי":
                            print("מחסנאי")
                            self.ConnectAsStorageKeeper(true)
                            break
                        case "מנהל רשת":
                            self.ConnectAsNetManager(true)
                            break
                        default:
                            print("not found")
                            self.login()
                        }
                    }}
                     else {
                        self.login()
                    }
            })
        }
        
        alert.addAction(UIAlertAction(title: "ביטול", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "התחבר", style:.default , handler: checkLogin))
        
        present(alert , animated: true, completion: nil)
        }
    
    private func ConnectAsDeliveryGuy(_ animation: Bool){
        let next = storyboard!.instantiateViewController(withIdentifier: "mapAddress")
        navigationController?.pushViewController(next, animated: animation)
    }
    
    private func ConnectAsStorageKeeper(_ animation: Bool){
        let next = storyboard!.instantiateViewController(withIdentifier: "storage_main")
        navigationController?.pushViewController(next, animated: animation)
    }
    
    private func ConnectAsNetManager(_ animation: Bool){
        let next = storyboard!.instantiateViewController(withIdentifier: "net_manager")
        navigationController?.pushViewController(next, animated: animation)
    }
    
    ////collection view////
    func setCollectionViewProperties(){
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(UINib.init(nibName: "collecViewCell", bundle: nil), forCellWithReuseIdentifier: "collectionCell")
        
        let flowLayout = UPCarouselFlowLayout()
        
        flowLayout.itemSize = CGSize(width: collectionView.frame.size.width-40, height: collectionView.frame.size.height-5)
        
        flowLayout.scrollDirection = .horizontal
        flowLayout.sideItemScale = 0.8
        flowLayout.sideItemAlpha = 1.0
        flowLayout.spacingMode = .fixed(spacing: 5.0)
        collectionView.collectionViewLayout = flowLayout
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! collecViewCell
        
        let urlsRequests = URLRequest(url: cell.urls[1])

        cell.webView.load(urlsRequests)
        cell.webView.scrollView.isScrollEnabled = false
        
        cell.textLbl.text? = cell.stories[indexPath.row]
        
        if cell.textLbl.text == ""{
            cell.black_screen.isHidden = true
            cell.webView.isHidden = false
            cell.imageView.isHidden = true
        }
        else{
            //show the black screen and the image and hide the webview
            cell.black_screen.isHidden = false
            cell.webView.isHidden = true
            cell.imageView.isHidden = false
            
            //show the images or the webview(youtube video) on the collection view
            if let url = URL(string: cell.urls[indexPath.row].absoluteString){
                URLSession.shared.dataTask(with:url){ (data, response, error) in
                    //if there is any error
                    if let e = error{
                        //displaying the message
                        print("Error Occurred: \(e)")
                    } else {
                        //checking if the response contains an image
                        if let imageData = data{
                            //displaying the image
                            DispatchQueue.main.async{
                                //check if the image url is in the user defaults
                                if let prefImageData = UserDefaults.standard.object(forKey: url.absoluteString){
                                    cell.imageView.image = UIImage(data: prefImageData as! Data)
                                    //check if the image on phone is the same as the image on the url
                                    if prefImageData as! Data != imageData{
                                        UserDefaults.standard.set(imageData, forKey: url.absoluteString)
                                        cell.imageView.image = UIImage(data: prefImageData as! Data)
                                        collectionView.reloadData()
                                    }
                                } else {
                                    //if the url is not in the user defaults, download the url
                                    UserDefaults.standard.set(imageData, forKey: url.absoluteString)
                                    cell.imageView.image = UIImage(data: imageData)
                                    collectionView.reloadData()
                                }
                            }
                        } else {
                            print("Image file is currupted")
                        }
                        
                    }
                    }.resume()
            }
            
        }
        
        return cell
    }
    ////
        
}
