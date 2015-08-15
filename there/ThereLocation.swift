//    The MIT License (MIT)
//
//    Copyright (c) <2015> <Tommaso Piazza>
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

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
