//
//  Request+CoreDataProperties.swift
//  
//
//  Created by Manoj Inukolunu on 8/5/19.
//
//

import Foundation
import CoreData


extension Request {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Request> {
        return NSFetchRequest<Request>(entityName: "Request")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var url: String?

}
