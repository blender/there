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

public struct ThereWayPoint: Printable, Equatable, Hashable {
    
    public let lat:Double
    public let lon:Double
    
    public var description:String {
        
        return "<< (lat:\(lat), lon:\(lon)) >>"
    }
    
    /**
    Initializes a new ThereWaypoint with the latitue and longitude values provided.
    
    :param: lat The latitude value.
    :param: lon The longitude value.
    
    
    :returns: A new ThereWaypoint.
    */
    
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
 