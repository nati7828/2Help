import UIKit

class StorageKeeperProductsController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var table: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items[0].count > 0{
            return items.count
        } else {
            return 0
        }
    }
    
    var cellItems: [String: Int] = [:]
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.backgroundColor = UIColor.clear
        let cell = tableView.dequeueReusableCell(withIdentifier: "products_cell")! as! ProductsTableViewCell
        if items[0].count > 0{
            if cell.name.text! != "מוצרים"{
                cellItems.updateValue(cell.count, forKey: cell.name.text!)
            }
            cell.manager = true
            if let count = cellItems[items[indexPath.row][1]]{
                cell.counter.text = String(count)
                cell.count = count
            } else {
                cell.counter.text = items[indexPath.row][2]
                cell.count = Int(items[indexPath.row][2])!
                cellItems.updateValue(cell.count, forKey: cell.name.text!)
            }
            cell.name.text = items[indexPath.row][1]
        }
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper.jpg")!)
        
        let b = UIBarButtonItem(title: "התנתק", style: .plain, target: self, action: #selector(backcheck))
        tabBarController?.navigationItem.leftBarButtonItem = b
       
        //Reset the cells
        for cell in table.visibleCells as! [ProductsTableViewCell]{
            cell.name.text = "מוצרים"
        }
        
        if let tok = prefs.string(forKey: "token"){
            token = tok
            navigationItem.title = "הוסף למלאי"
            ServerConnections.getDoubleArrayAsync("/warehouse_items", [token], handler: {itemsArray in
                if let array = itemsArray{
                    self.items = array
                    self.cellItems = [:]
                    self.table.reloadData()
                }
            })
        }
    }
    
    var request: [String] = []
    var items: [[String]] = [[]]
    var token = ""
    let prefs = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var changedItems: [[String]] = []
    @IBAction func addItemsManager(_ sender: Any) {
        changedItems = []
        for cell in table.visibleCells as! [ProductsTableViewCell]{
            cellItems.updateValue(cell.count, forKey: cell.name.text!)
        }
        
        var flag = false
        for i in 0...items.count - 1{
            if let itemCount = cellItems[items[i][1]]{
                if(Int(items[i][2]) != itemCount){
                    flag = true
                    changedItems.append(["", items[i][1], String(-(Int(items[i][2])! - itemCount))])
                }
            }
        }
        if flag{
            showAlert(flag: false)
        } else {
            //self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showAlert(flag: Bool){
        self.navigationController?.isNavigationBarHidden = false
        let alert = UIAlertController(title: "שינוי כמות", message: "אתה בטוח שאתה רוצה לעדכן את הכמות?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "ביטול", style: .cancel, handler: nil)
        let accept = UIAlertAction(title: "אישור", style: .default, handler: { action in
        self.addItems()
        })
        alert.addAction(cancel)
        alert.addAction(accept)
        present(alert, animated: true, completion: nil)
    }
    
    func addItems(){
        changedItems.insert([token, "חולון התחיה 10"], at: 0)
        ServerConnections.getDoubleArrayAsync("/addItems", changedItems, handler: {array in
            //self.navigationController?.popViewController(animated: true)
        })
    }
//    func getImages(){
//        for product in basket{
//            if let url = URL(string: product.value[1]){
//                URLSession.shared.dataTask(with:url){ (data, response, error) in
//                    //if there is any error
//                    if let e = error{
//                        //displaying the message
//                        print("Error Occurred: \(e)")
//                    } else {
//                        //in case of now error, checking wheather the response is nil or not
//                        if (response as? HTTPURLResponse) != nil{
//                            //checking if the response contains an image
//                            if let imageData = data{
//                                //displaying the image
//                                DispatchQueue.main.async{
//                                    if let prefImageData = UserDefaults.standard.object(forKey: url.absoluteString){
//                                        if prefImageData as! Data != imageData{
//                                            UserDefaults.standard.set(imageData, forKey: url.absoluteString)
//                                            self.table.reloadData()
//                                        }
//                                    } else {
//                                        UserDefaults.standard.set(imageData, forKey: url.absoluteString)
//                                        self.table.reloadData()
//                                    }
//                                }
//                            } else {
//                                print("Image file is currupted")
//                            }
//                        } else {
//                            print("No response from server")
//                        }
//                    }
//                    }.resume()
//            }
//        }
//    }
    
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
