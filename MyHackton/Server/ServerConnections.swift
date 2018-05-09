import Foundation

class ServerConnections{
    //static let HOSTURL = "http://2help-server.eu-gb.mybluemix.net"
    static let HOSTURL = "http://localhost:8080"
    //Connection to the server with url addon and if needed with package of string, returning an array or a dobule array of
    //String from the server.
    static func getArrayAsync(_ urlAddon: String, _ package: [String], handler: @escaping ([String]?)->()) {
        let url = URL(string: HOSTURL + urlAddon)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: package, options: .sortedKeys)
        //request.httpBody = packageToString(package: package).data(using: .utf8)
        URLSession.shared.dataTask(with: request, completionHandler: {(d,r,e) in
            if let data = d {
                //call handler with result (in main thread)
                DispatchQueue.main.async {
                    handler((try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) as? [String])
                }
            }
            else {
                print("Nil Data.")
            }
        }).resume()
    }
    
    static func getDoubleArrayAsync(_ urlAddon: String, _ package: [String], handler: @escaping ([[String]]?)->()) {
        let url = URL(string: HOSTURL + urlAddon)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: package, options: .sortedKeys)
        //packageToString(package: package).data(using: .utf8)
        URLSession.shared.dataTask(with: request, completionHandler: {(d,r,e) in
            if let data = d {
                //call handler with result (in main thread)
                DispatchQueue.main.async {
                    handler((try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) as? [[String]])
                }
            }
            else {
                print("Nil Data.")
            }
        }).resume()
    }
    
    static func getDoubleArrayAsync(_ urlAddon: String, _ package: [[String]], handler: @escaping ([[String]]?)->()) {
        let url = URL(string: HOSTURL + urlAddon)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: package, options: .sortedKeys)
        //packageToString(package: package).data(using: .utf8)
        URLSession.shared.dataTask(with: request, completionHandler: {(d,r,e) in
            if let data = d {
                //call handler with result (in main thread)
                DispatchQueue.main.async {
                    handler((try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) as? [[String]])
                }
            }
            else {
                print("Nil Data.")
            }
        }).resume()
    }
    
    static func packageToString(package: [String]) -> String{
        var back = ""
        for pac in package{
            if(back.count != 0){
                back += "&"
            }
            back += pac
        }
        return back
    }
    //    static func getDonators() -> [Donator]{
    //        getDictonaryAsync("/donators", "", handler: { donators in
    //            var back: [Donator]
    //            if let d = donators{
    //                for donator in d {
    //
    //                }
    //            }
    //
    //        })
    //        return back
    //    }
}
