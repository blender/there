//
//  ThereWayPoint.swift
//  there
//
//  Created by Tommaso Piazza on 08/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import Foundation

public struct ThereWayPoint: Printable, Equatable, Hashable {
    
    public let lat:Double
    public let lon:Double
    
    public var description:String {
        
        return "<< (lat:\(lat), lon:\(lon)) >>"
    }
    
    init(lat:Double, lon:Double){
        self.lat = lat
        self.lon = lon
    }
    
    public var hashValue : Int {
        get {
            return "\(self.lat),\(self.lon)".hashValue
        }
    }
}
    
public func ==(lhs: ThereWayPoint, rhs: ThereWayPoint) -> Bool {

    return lhs.lat == rhs.lat && lhs.lon == rhs.lon
}
 