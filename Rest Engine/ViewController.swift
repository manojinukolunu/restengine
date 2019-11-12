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
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet var resposneViewNew: NSTextView!
 
    @IBAction func responseSearch(_ sender: NSSearchFieldCell) {
        print(sender.stringValue)
    }
    
    @IBAction func searchChanced(_ sender: NSSearchField) {
        if !sender.stringValue.isEmpty {
             //print(sender.stringValue)
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<Request>(entityName: "Request")
            fetchRequest.predicate = NSPredicate(format: "url contains[c] %@", sender.stringValue)
            do {
                requests = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            tableView.reloadData()
        }else{
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<Request>(entityName: "Request")
            do {
                requests = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            tableView.reloadData()
            print("string value is empty in search reloading data")
        }
       
    }
    
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
        Alamofire.request(requestUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let json = response.data {
                    do{
                        let data = try JSON(data: json)
                        let str = data.rawString()
                        let prettyJson = str!.data(using: .utf8)!.prettyPrintedJSONString! as String
                        self.resposneViewNew.string=prettyJson
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
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        tableView.reloadData()
    }
    
}


extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        let count = requests.count
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
       // print(tableColumn.dataCell)
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = self.tableView.selectedRow
        // If the user selected a row. (When no row is selected, the index is -1)
        if (selectedRow > -1) {
            let myCell = self.tableView.view(atColumn: 0, row: selectedRow, makeIfNecessary: true) as! NSTableCellView
            let textField = myCell.textField as! NSTextField
            //print(textField.stringValue);
            self.requestUrlTextField.stringValue=textField.stringValue;
        }
    }
}

extension NSTextView {
override open func performKeyEquivalent(with event: NSEvent) -> Bool {
    let commandKey = NSEvent.ModifierFlags.command.rawValue
    let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
    if event.type == NSEvent.EventType.keyDown {
        if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey {
            switch event.charactersIgnoringModifiers! {
            case "x":
                if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return true }
            case "c":
                if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return true }
            case "v":
                if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return true }
            case "z":
                if NSApp.sendAction(Selector(("undo:")), to:nil, from:self) { return true }
            case "a":
                if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to:nil, from:self) { return true }
            default:
                break
            }
        } else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandShiftKey {
            if event.charactersIgnoringModifiers == "Z" {
                if NSApp.sendAction(Selector(("redo:")), to:nil, from:self) { return true }
            }
        }
    }
    return super.performKeyEquivalent(with: event)
}
}


extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}





