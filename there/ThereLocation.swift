//
//  ThereLocation.swift
//  there
//
//  Created by Tommaso Piazza on 08/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import Foundation

public struct ThereLocation: Printable, Equatable, Hashable {

    public let wayPoint:ThereWayPoint
    public let address:String
    
    public var description:String {
    
        return "<< address: \(address), wayPoint:\(wayPoint) >>"
    }
    
    /**
    Initializes a new ThereLocation with the latitue, longitude and address values provided.
    
    :param: lat The latitude value.
    :param: lon The longitude value.
    :param: address A String representing the address of this location.
    
    
    :returns: A new ThereLocation.
    */
    
    public init(lat:Double, lon:Double, address:String){
        
        self.wayPoint = ThereWayPoint(lat:lat, lon:lon)
        self.address = address
    }
    
    /**
    Initializes a new ThereWaypoint with the ThereWayPoint and address values provided.
    
    :param: wayPoint The ThereWayPoint.
    :param: address A String representing the address of this location.
    
    
    :returns: A new ThereLocation.
    */
    
    public init(wayPoint:ThereWayPoint, address:String) {
        
        self.wayPoint = wayPoint
        self.address = address
    }
    
    public var hashValue : Int {
        get {
            let addressHash = "\(address) - \(wayPoint.lat),\(wayPoint.lon)".hashValue

            return addressHash
        }
    }
}

public func ==(lhs: ThereLocation, rhs: ThereLocation) -> Bool {
    
    return lhs.wayPoint == rhs.wayPoint && lhs.address == rhs.address
}
