//
//  Folder.swift
//  Syncthing-Finder
//
//  Created by Danilo Torrisi on 16/01/15.
//  Copyright (c) 2015 Danilo Torrisi. All rights reserved.
//

import Foundation
import BrightFutures
import SwiftyJSON
import Alamofire


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
    
    // Make a GET config request, get the Folders in JSON and return the Folders
    return Syncthing.get("config").map { (json) in json["Folders"].array?.map({ Folder(json: $0)! }) ?? [] }
}


