//
//  ViewController.swift
//  Rest Engine
//
//  Created by Manoj Inukolunu on 8/5/19.
//  Copyright © 2019 Manoj Inukolunu. All rights reserved.
//

import Cocoa
import Alamofire
import CoreData
import SwiftyJSON

class ViewController: NSViewController {
    
    @IBOutlet  var requestUrlTextField: NSTextField!
    
    @IBOutlet var responseTextView: NSTextView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    
    
    
    private var appDelegate = NSApplication.shared.delegate as! AppDelegate
    
    
    var requests: [Request] = []

    func loadData(){
        let path = "/Users/manoji/Downloads/postmaN-history.json"
        do{
            //let contents = try String(contentsOfFile:path,encoding:.utf8)
            let url = URL(fileURLWithPath:path)
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            if let json = try?JSONSerialization.jsonObject(with: data) as? NSArray {
                for item in json! {
                    if let unwrappedDict = item as? NSDictionary {
                        let managedContext = appDelegate.persistentContainer.viewContext
                        let entity = NSEntityDescription.entity(forEntityName: "Request", in: managedContext)
                        let requestObject = NSManagedObject(entity: entity!, insertInto: managedContext)
                        requestObject.setValue(unwrappedDict["url"], forKey: "url")
                        requestObject.setValue(Date(), forKey: "date")
                        do {
                           try managedContext.save()
                          } catch {
                           print("Failed saving")
                        }
                    }
                }
            }
        } catch let error as NSError{
            print("Oops! something went wrong: \(error)")
        }
    }

    
    @IBAction func executeRequest(_ sender: Any) {
        let requestUrl = requestUrlTextField.stringValue
        print(requestUrl)
        Alamofire.request(requestUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let json = response.data {
                    do{
                        let data = try JSON(data: json)
                        self.responseTextView.insertText(String(describing:data), replacementRange: NSMakeRange(0,1))
                        print("INserted TExt")
                    }
                    catch{
                        print("JSON Error")
                    }
                    
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsColumnResizing=true
        let managedContext = appDelegate.persistentContainer.viewContext
        // Dont UnComment this will reload data loadData()
        let fetchRequest = NSFetchRequest<Request>(entityName: "Request")
        do {
            requests = try managedContext.fetch(fetchRequest)
            print("Got \(requests.count) of data ")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        tableView.reloadData()
    }
    
}


extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        let count = requests.count
        print("Loading data \(count) count")
        return count
    }
}

extension ViewController:NSTableViewDelegate{
    
    fileprivate enum CellIdentifiers {
        static let requestCell = "RequestID"
        static let dateCell = "DateID"
    }
    
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellIdentifier: String = ""
        var text: String=""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        
        let request = requests[row]
        if tableColumn!.title == "Request"{
            text = request.url!
            cellIdentifier = CellIdentifiers.requestCell
        }
        if tableColumn!.title == "Date"{
            text = dateFormatter.string(from: request.date!)
            cellIdentifier = CellIdentifiers.dateCell
        }
        
    
        
        if let cell = tableView.makeView(withIdentifier:NSUserInterfaceItemIdentifier(rawValue: cellIdentifier),owner:self ) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        print(tableColumn.dataCell)
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = self.tableView.selectedRow
        // If the user selected a row. (When no row is selected, the index is -1)
        if (selectedRow > -1) {
            let myCell = self.tableView.view(atColumn: 0, row: selectedRow, makeIfNecessary: true) as! NSTableCellView
            let textField = myCell.textField as! NSTextField
            print(textField.stringValue);
            self.requestUrlTextField.stringValue=textField.stringValue;
        }
    }
    
    
}






