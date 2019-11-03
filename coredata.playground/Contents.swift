import UIKit
import CoreData
import Request

public func createMainContext() -> NSManagedObjectContext {
    
    // Replace "Model" with the name of your model
    let modelUrl = Bundle.mainBundle().URLForResource("Rest_Engine", withExtension: "momd")
    guard let model = NSManagedObjectModel.init(contentsOfurl: modelUrl!) else { fatalError("model not found") }
    
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    try! psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    
    return context
}

let context = createMainContext()

let fr = NSFetchRequest<Request>(entityName: "Request")
let result = try! context.executeFetchRequest(fr)

print(result)
