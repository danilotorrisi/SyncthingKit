//
//  Folder.swift
//  Syncthing-Finder
//
//  Created by Danilo Torrisi on 16/01/15.
//  Copyright (c) 2015 Danilo Torrisi. All rights reserved.
//

import Foundation
import BrightFutures
import Alamofire
import SwiftyJSON


public struct Folder : Printable {
    
    public let identifier: String
    public let path: String
    public let rescanInterval: Int
    public let readonly: Bool = false
    
    // Private init in order to build a Folder from its JSON representation.
    private init?(json: JSON) {
        
        // Parse the json.
        if let identifier = json["ID"].string   { self.identifier = identifier } else { return nil }
        if let path = json["Path"].string       { self.path = path.stringByReplacingOccurrencesOfString("~", withString: "/Users/danilotorrisi") } else { return nil }
        if let readonly = json["ReadOnly"].bool { self.readonly = readonly } else { return nil }
        if let rescanInterval = json["RescanIntervalS"].int { self.rescanInterval = rescanInterval } else { return nil }
    }
    
    // MARK: Printable
    public var description: String {
        return "(\(identifier)) \(path)"
    }
}

public func retrieveFolders() -> Future<Array<Folder>> {
    let promise = Promise<Array<Folder>>()
    
    // Send a GET request.
    request(.GET, "http://localhost:8080/rest/config").responseSwiftyJSON { (_, _, res, error) in

        // If got an error
        if let err = error {
            
            // Return the failure
            promise.failure(err)
            
        } else {

            // Retun the Folders
            promise.success(res["Folders"].array?.map { Folder(json: $0) }.filter { $0 != nil }.map { $0! } ?? [])
        }
    }
    
    return promise.future
}


