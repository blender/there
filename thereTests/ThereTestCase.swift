//
//  ThereTestCase.swift
//  there
//
//  Created by Tommaso Piazza on 08/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import XCTest
import there

class ThereTestCase: XCTestCase {

    var defaultClient:ThereClient!
    
    override func setUp() {
        super.setUp()
        
        ThereClient.logLevel = ThereLogLevel.Debug
        self.defaultClient = ThereClient(appId: "WGs9hKOLMAlWsDoYHFh8", appCode: "GlF6ZfXv0uJfuJ0kSEILvw")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
}
