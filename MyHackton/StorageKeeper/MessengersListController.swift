import UIKit

class MessengersListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var requests: [[String]] = [[]]
    @IBOutlet var requestsList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper.jpg")!)
        
        let b = UIBarButtonItem(title: "התנתק", style: .plain, target: self, action: #selector(backcheck))
        tabBarController?.navigationItem.leftBarButtonItem = b
        tabBarController?.navigationItem.title = tabBarItem.title
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let prefs = UserDefaults.standard
        if let token = prefs.string(forKey: "token"){
            ServerConnections.getDoubleArrayAsync("/requests", [token, "נלקח"], handler: { requestsArray in
                if let array = requestsArray{
                    self.requests = array
                    self.requestsList.reloadData()
                } else {
                    //Move back to the main page
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
        } else {
            //Move back to the main page
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    //table functions//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundColor = UIColor.clear
        if(requests.count > 0 && requests[0].count > 0){
            return requests.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messanger")! as! MessengerListCell
        if(requests[0].count > 0){
            cell.address.text = requests[indexPath.row][2]
            cell.deliveryName.text = requests[indexPath.row][6]
            cell.index = indexPath.row
            cell.controller = self
            
            cell.abortDeliveryButton.layer.cornerRadius = 19
        }
        return cell
    }
    ////
    
    
    
    
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
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey: "token")
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
