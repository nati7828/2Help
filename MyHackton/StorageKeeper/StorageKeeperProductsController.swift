import UIKit

class StorageKeeperProductsController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "products_cell_review")!
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
}
