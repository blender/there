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
            XCTAssertTrue(error == nil, "There was an unexpected error")
        })
        
        self.waitForExpectationsWithTimeout(3) { (error) -> Void in
            
            if (error != nil) {
                println("Expectation Failed")
            }
        }
    }
    
    func testThatRouteReturnsThreeWayPoints() {
        
        let requestCompletedExpectation = self.expectationWithDescription("Request did complete")
        
        self.defaultClient.routeWithWayPoins(
            [(52.5083774,13.4527931),
                (52.5100621,13.4556041),
                (52.5109893,13.4413884)],
            mode: .FastestCar) { (wayPoints, error) -> () in
                
                requestCompletedExpectation.fulfill()
                
                XCTAssertTrue(wayPoints?.count > 0, "There was an unexpected error")
        }
        
        self.waitForExpectationsWithTimeout(100) { (error) -> Void in
            
            if (error != nil) {
                println("Expectation Failed")
            }
        }
    }
}
