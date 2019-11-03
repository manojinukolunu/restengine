import Cocoa
import Foundation

var str = "Hello, playground"

func loadData(){
    let path = "/Users/manoji/Downloads/postmaN-history.json"
    do{
        //let contents = try String(contentsOfFile:path,encoding:.utf8)
        let url = URL(fileURLWithPath:path)
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        let json = try?JSONSerialization.jsonObject(with: data) as? NSArray
        json?.forEach({ (item) in
            if let unwrappedDict = item as? NSDictionary {
                print(unwrappedDict["url"]!)
            }
        })
    } catch let error as NSError{
        print("Oops! something went wrong: \(error)")
    }
}
