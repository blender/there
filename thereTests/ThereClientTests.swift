//
//  ThereClientTests.swift
//  thereTests
//
//  Created by Tommaso Piazza on 08/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import UIKit
import XCTest

class ThereClientTests: ThereTestCase {
    
    func testThatSearchReturnsALocation() {
        
        let requestCompletedExpectation = self.expectationWithDescription("Request did complete")
        
        self.defaultClient.searchWithTerm("Simon-Dach Straße 20, 10245, Berlin, Germany", onCompletion: { (locations, error) -> () in
            
            requestCompletedExpectation.fulfill()
            println(locations)
            XCTAssertTrue(error == nil, "No locations where returned")
        })
        
        self.waitForExpectationsWithTimeout(3) { (error) -> Void in
            
            if (error != nil) {
                println("Expectation Failed")
            }
        }
    }
    
    func testThatSearchHandlesApiError() {
        
        let requestCompletedExpectation = self.expectationWithDescription("Request did complete")
        
        self.defaultClient.searchWithTerm("", onCompletion: { (locations, error) -> () in
            
            requestCompletedExpectation.fulfill()
            println(error)
            XCTAssertTrue(error != nil, "Expected and error but none was raised")
        })
        
        self.waitForExpectationsWithTimeout(3) { (error) -> Void in
            
            if (error != nil) {
                println("Expectation Failed")
            }
        }
    }
    
    func testThatRouteReturnsSomeWayPoints() {
        
        let requestCompletedExpectation = self.expectationWithDescription("Request did complete")
        
        self.defaultClient.routeWithWayPoins(
            [(52.5083774,13.4527931),
                (52.5100621,13.4556041),
                (52.5109893,13.4413884)],
            mode: .FastestCar) { (wayPoints, error) -> () in
                
                requestCompletedExpectation.fulfill()
                
                XCTAssertTrue(wayPoints?.count > 0, "No waypoints were returned")
        }
        
        self.waitForExpectationsWithTimeout(100) { (error) -> Void in
            
            if (error != nil) {
                println("Expectation Failed")
            }
        }
    }
    
    func testThatRouteHandlesApiError() {
        
        let requestCompletedExpectation = self.expectationWithDescription("Request did complete")
        
        self.defaultClient.routeWithWayPoins(
            [(52.5083774,13.4527931),
                (53.6152324,4.2193782)], //This is in the middle of the sea
            mode: .FastestCar) { (wayPoints, error) -> () in
                
                requestCompletedExpectation.fulfill()
                println(error)
                XCTAssertTrue(error != nil, "No waypoints were returned")
        }
        
        self.waitForExpectationsWithTimeout(100) { (error) -> Void in
            
            if (error != nil) {
                println("Expectation Failed")
            }
        }
    }
}
