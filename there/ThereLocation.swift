//
//  ThereLocation.swift
//  there
//
//  Created by Tommaso Piazza on 08/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import Foundation

public struct ThereLocation: Printable, Equatable {

    public let wayPoint:ThereWayPoint
    public let address:String
    
    public var description:String {
    
        return "<< address: \(address), wayPoint:\(wayPoint) >>"
    }
    
    public init(lat:Double, lon:Double, address:String){
        
        self.wayPoint = ThereWayPoint(lat:lat, lon:lon)
        self.address = address
    }
    
    public init(wayPoint:ThereWayPoint, address:String) {
        
        self.wayPoint = wayPoint
        self.address = address
    }
}

public func ==(lhs: ThereLocation, rhs: ThereLocation) -> Bool {
    
    return lhs.wayPoint == rhs.wayPoint && lhs.address == rhs.address
}
