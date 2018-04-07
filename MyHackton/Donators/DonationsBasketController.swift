import UIKit


class DonationsBasketController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var scannedCode = ""
    var backButton : UIBarButtonItem!
    //Manager
    var manager = false
    var token = ""
    var request: [String] = []
    var items: [[String]] = [[]]
    //
    var basket: [String: [String]] = [:]
    var productImage : UIImage!

    @IBOutlet var table: UITableView!
    
    @IBAction func toAddDetailsController(_ sender: UIBarButtonItem) {
        let nextPage = storyboard!.instantiateViewController(withIdentifier: "donator_details")
        navigationController?.pushViewController(nextPage, animated: true)
        //show(nextPage, sender: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper.jpg")!)
    }
    
    
    let prefs = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if manager{
            if let tok = prefs.string(forKey: "token"){
                token = tok
                navigationItem.title = "הוסף למלאי"
                ServerConnections.getDoubleArrayAsync("/request_items", [token, request[0]], handler: {itemsArray in
                    if let array = itemsArray{
                        self.items = array
                        self.table.reloadData()
                    }
                })
            }
        } else {
            navigationItem.title = "סל תרומות"
            print(scannedCode)
            if let prefsBasket = prefs.dictionary(forKey: "basket"){
                basket = prefsBasket as! [String: [String]]
                for key in basket.keys{
                    if Int(basket[key]![0])! < 1{
                        basket.removeValue(forKey: key)
                    }
                }
                if (basket.count == 0){
                    let alert = UIAlertController(title: "סל ריק", message: "אין מוצרים בסל התרומות", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "אישור", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                prefs.set(basket, forKey: "basket")
                getImages()
            }
        }
    }
    
    
    
    
    
    func getImages(){
        for product in basket{
            if let url = URL(string: product.value[1]){
                URLSession.shared.dataTask(with:url){ (data, response, error) in
                    //if there is any error
                    if let e = error{
                        //displaying the message
                        print("Error Occurred: \(e)")
                    } else {
                        //in case of now error, checking wheather the response is nil or not
                        if (response as? HTTPURLResponse) != nil{
                            //checking if the response contains an image
                            if let imageData = data{
                                //displaying the image
                                DispatchQueue.main.async{
                                    if let prefImageData = UserDefaults.standard.object(forKey: url.absoluteString){
                                        if prefImageData as! Data != imageData{
                                    UserDefaults.standard.set(imageData, forKey: url.absoluteString)
                                            self.table.reloadData()
                                        }
                                    } else {
                                        UserDefaults.standard.set(imageData, forKey: url.absoluteString)
                                        self.table.reloadData()
                                    }
                                }
                            } else {
                                print("Image file is currupted")
                            }
                        } else {
                            print("No response from server")
                        }
                    }
                    }.resume()
            }
        }
    }
    
    //move to scannerViewController to scan barcodes
    @IBAction func scanBarcode(_ sender: UIButton) {
        print("in")
        let scanPage = storyboard!.instantiateViewController(withIdentifier: "scanner") as! ScannerViewController
        navigationController?.pushViewController(scanPage, animated: true)
    }
    
    //table view functions//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundColor = UIColor.clear
        if(manager){
            if items.count > 0{
                if items[0].count > 0{
                    return items.count
                } else {
                    return 0
                }
            } else {
                return 0
            }
        } else {
            return basket.count
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = prefs.string(forKey: "barcode"){
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "products_cell")! as! ProductsTableViewCell
        cell.manager = manager
        if manager{
            cell.name.text = items[indexPath.row][1]
            cell.counter.text = items[indexPath.row][2]
            cell.count = Int(items[indexPath.row][2])!
        } else {
            let key = Array(basket.keys)[indexPath.row]
            cell.name.text = key
            cell.counter.text = basket[key]![0]
            cell.count = Int(basket[key]![0])!
            //Getting images from UserDefaults if they exist
            if let prefImageData = UserDefaults.standard.object(forKey: basket[key]![1]){
                cell.product_image.image = UIImage(data: prefImageData as! Data)
                cell.backgroundColor = UIColor.clear
                cell.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            }
        }
        return cell
    }
    ////
    var text: UITextField!
    func showAlert(flag: Bool){
        let alert = UIAlertController(title: "חריגה", message: "סיבה לשינוי הכמות", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "ביטול", style: .cancel, handler: nil)
        let accept = UIAlertAction(title: "אישור", style: .default, handler: { action in
            if self.text.text!.count != 0{
                self.addReason()
                self.addItems()
            } else {
                self.showAlert(flag: true)
            }
        })
        
        alert.addTextField { (tf) in
            tf.textAlignment = .right
            tf.returnKeyType = .next
            self.text = tf
            if flag{
                tf.placeholder = "הכנס סיבה לשינוי"
            }
        }
        alert.addAction(cancel)
        alert.addAction(accept)
        present(alert, animated: true, completion: nil)
    }
    
    ///Warehouse Manager
    var changedItems = ""
    @IBAction func addItemsManager(_ sender: Any) {
        var flag = false
        for i in 0...items.count - 1{
            let item = table.visibleCells[i] as! ProductsTableViewCell
            if(items[i][2] != item.counter.text!){
                flag = true
                changedItems += "\(items[i][1]):\(item.count - Int(items[i][2])!)&"
            }
        }
        if flag{
            showAlert(flag: false)
        } else {
            addItems()
        }
    }
    
    
    func addItems(){
        items.insert([token, "חולון התחיה 10"], at: 0)
        ServerConnections.getDoubleArrayAsync("/addItems", items, handler: {array in
        self.navigationController?.popViewController(animated: true)
        })
    }
    
    func addReason(){
        ServerConnections.getArrayAsync("/add_reason", [token, request[0], text.text!, changedItems], handler: { array in
            
        })
    }
    ///
}
