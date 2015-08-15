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

import UIKit
import XCTest
import there

class ThereRequestGeneratorTests: ThereTestCase {
    
    var defaultGenerator:ThereRequestGenerator!
    
    override func setUp() {
        super.setUp()
        self.defaultGenerator = ThereRequestGenerator(appId:"1234567890", appCode:"0987654321")
    }
    
    
    func testThatAppIdandAppCodeAreAppendedToQueryParameters() {
        
        let eitherRequestOrError = self.defaultGenerator.searchRequestWithParameters("")
        
        switch eitherRequestOrError {
            
        case .Left(let box):
            XCTFail("Generator should not return error")
        case .Right(let box):
            if let url = box.value.URL {
                
                let components = NSURLComponents(URL: url, resolvingAgainstBaseURL:false)
                if let queryItems = components?.queryItems as? [NSURLQueryItem]{
                    
                    var didFindAppId = false
                    var didFindAppCode = false
                    
                    for queryItem in queryItems {
                        
                        if queryItem.name == "app_id" {
                            XCTAssertEqual(queryItem.value!, "1234567890", "AppId did not match expectation")
                            didFindAppId = true
                        }
                        if queryItem.name == "app_code" {
                            XCTAssertEqual(queryItem.value!, "0987654321", "AppId did not match expectation")
                            didFindAppCode = true
                        }
                    }
                    
                    XCTAssertTrue(didFindAppCode && didFindAppId, "Generator request does not include AppId and AppCode")
                }
                else {
                    XCTFail("Generator failed to produce query items")
                }
            }
            else {
                XCTFail("Generator should produce URL")
            }
        }
    }
    
    func testThatRequestEscapesAndSign() {
        
        let eitherRequestOrError = self.defaultGenerator.searchRequestWithParameters("&&&&")
        
        switch eitherRequestOrError {
            
        case .Left(let box):
            XCTFail("Generator should not return error")
        case .Right(let box):
            if let url = box.value.URL {
                
                XCTAssertEqual(url.absoluteString!, "https://geocoder.cit.api.here.com/6.2/geocode.json?app_id=1234567890&app_code=0987654321&searchtext=%26%26%26%26", "URL string did not match escaping expectations")
            }
            else {
                XCTFail("Generator should produce URL")
            }
        }
    }
    
    func testThatRoutingRequestDoesNotGetCreated() {
        
        var testWayPoints = [(12.215251, 4.125125)]
        
        let eitherRequestOrError = self.defaultGenerator.routeRequestWithParameters(testWayPoints, mode: .FastestCar)
        
        switch eitherRequestOrError {
        case .Left(let box):
            XCTAssertEqual(box.value.code, ThereError.MalformedParameters.rawValue, "Routing request procuded a diffrent error that expected")
            break
        case .Right(let box):
            XCTFail("Generator should NOT produce URL")
        }
    }
    
    func testThatRoutingRequestIncludesWayPoints() {
        
        var testWayPoints = [(12.215251, 4.125125), (56.215251, 34.125125), (25.215251, 14.125125)]
        
        let eitherRequestOrError = self.defaultGenerator.routeRequestWithParameters(testWayPoints, mode: .FastestCar)
        
        switch eitherRequestOrError {
        case .Left(let box):
            XCTFail("Generator should not return error")
        case .Right(let box):
            if let url = box.value.URL {
                
                let components = NSURLComponents(URL: url, resolvingAgainstBaseURL:false)
                if let queryItems = components?.queryItems as? [NSURLQueryItem]{
                    
                    var waypointsFound = 0
                    
                    for queryItem in queryItems {
                        for i in 0...testWayPoints.count-1 {
                            if queryItem.name == "waypoint\(i)" {
                                XCTAssertEqual(queryItem.value!, "\(testWayPoints[i].0),\(testWayPoints[i].1)", "Waypoint failed expectations")
                                waypointsFound++
                            }
                        }
                    }
                    
                    XCTAssertTrue(waypointsFound == testWayPoints.count, "Generator request does not include enough waypoints")
                }
                else {
                    XCTFail("Generator failed to produce query items")
                }
            }
            else {
                XCTFail("Generator should produce URL")
            }
        }
    }
}
