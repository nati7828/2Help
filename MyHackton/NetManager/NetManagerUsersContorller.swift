import UIKit

class NetManagerUsersController: UIViewController{
    var user:[String] = []
    var toDo: String!
    
    var pageTitle : String!
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var segment: UISegmentedControl!
    @IBOutlet var fullname: UITextField!
    @IBOutlet var phone: UITextField!
    @IBOutlet var address: UITextField!
    @IBOutlet var toDoBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper.jpg")!)
        toDoBtn.titleLabel?.textColor = UIColor.white
        
        let font = UIFont.boldSystemFont(ofSize: 16)
        segment.setTitleTextAttributes([NSAttributedStringKey.font : font], for: .normal)
        segment.backgroundColor = UIColor.white.withAlphaComponent(0.7)

        navigationItem.title = pageTitle
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.backBarButtonItem?.title = "חזור"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {

        if (toDo == "update"){
            toDoBtn.setTitle("עדכן", for: .normal)
        } else {
            toDoBtn.setTitle("הוסף", for: .normal)
            
        }
        if user.count > 0{
            username.text = user[1]
            switch user[2] {
            case "מנהל רשת":
                segment.selectedSegmentIndex = 0
            case "מחסנאי":
                segment.selectedSegmentIndex = 1
            default:
                segment.selectedSegmentIndex = 2
            }
            fullname.text = user[3]
            phone.text = user[4]
            address.text = user[5]
        }
    }
    
    @IBAction func btnPress(_ sender: Any) {
        let prefs = UserDefaults.standard
        if let token = prefs.string(forKey: "token"){
            
            switch toDo {
            case "add":
                //Adds user info to array
                user.append(username.text!)
                user.append(password.text!)
                user.append(segment.titleForSegment(at: segment.selectedSegmentIndex)!)
                user.append(fullname.text!)
                user.append(phone.text!)
                user.append(address.text!)
                
                ServerConnections.getDoubleArrayAsync("/add_user", [[token], user], handler: {array in
                    let alert = UIAlertController(title: "התראה", message: "משתמש נוסף למערכת בהצלחה", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "אישור", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
                
            case "update":
                //updates user info in array
                user[1] = username.text!
                user.insert(password.text!, at: 2)
                user[3] = segment.titleForSegment(at: segment.selectedSegmentIndex)!
                user[4] = fullname.text!
                user[5] = phone.text!
                user[6] = address.text!
                ServerConnections.getDoubleArrayAsync("/update_user", [[token], user], handler: {array in
                    let alert = UIAlertController(title: "התראה", message: "פרטי המשתמש עודכנו בהצלחה", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "אישור", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
                
            default:
                break
            }
        }
    }
    
}
