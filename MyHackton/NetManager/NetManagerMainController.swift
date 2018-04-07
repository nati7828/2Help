import UIKit

class NetManagerMainController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper.jpg")!)
        
        //hide the back button and put a new button instead that will enable log out from the system
        let b = UIBarButtonItem(title: "התנתק", style: .plain, target: self, action: #selector(backcheck))
        navigationItem.leftBarButtonItem = b
        
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.title = "עמוד ראשי"
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
