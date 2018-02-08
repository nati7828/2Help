import UIKit

class DonatorController: UIViewController,UITableViewDataSource {

    
    @IBOutlet var tbl_products: UITableView!
    
    var totalCount: Int = 0
    //var str : [Int] = [1,2,3,4,5,6,7,8,9,10]
    var products: [String] = []
    
override func viewWillAppear(_ animated: Bool) {
    if totalCount > 0 {
        tabBarController!.navigationItem.rightBarButtonItem!.isEnabled = true
    }
        tabBarController!.navigationItem.rightBarButtonItem!.title = "מלא פרטים"
        tabBarController!.title = "תרומות"
}
    
    

override func viewDidAppear(_ animated: Bool){
        // show the products from the server in a new task
        let url = URL(string: "http://2help-server.eu-gb.mybluemix.net/items")!
        URLSession.shared.dataTask(with: url, completionHandler: {(d,r,e) in
            AsyncTask(backgroundTask: { (d: Data) -> [String]? in
                return (try? JSONSerialization.jsonObject(with: d, options: .mutableContainers)) as? [String]
            }, afterTask: { products in
                self.products = products ?? []
                if products == nil {
                    print("nil was found HERE")
                }
                else {
                    print(products!)
                    self.tbl_products.reloadData()
                }
            }).execute(d!)
        }).resume()
        //
    }

    
override func viewDidLoad(){
    super.viewDidLoad()
}
    
    //Products table//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell") as! DonatorProductsCell
        cell.set(donatorController: self)
        cell.productName.text = products[indexPath.row]
        
        return cell
    }
    ////
    
    // dependency injection - update the count on the dontaorProductCell
    func updateCount(c : Int){
        totalCount += c
        
        //enable the button press if count is bigger than 0
        tabBarController!.navigationItem.rightBarButtonItem!.isEnabled = totalCount > 0
    }
    ////
    
}

