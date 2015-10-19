//
//  IosContinuousIntegrationUITests.swift
//  IosContinuousIntegrationUITests
//
//  Created by Adrien Nicolet on 14/10/15.
//  Copyright © 2015 Adrien Nicolet. All rights reserved.
//

import XCTest

class IosContinuousIntegrationUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testExample() {
        
        let app = XCUIApplication()
        app.navigationBars["Master"].buttons["Add"].tap()
        let tablesQuery = app.tables
        
        XCTAssertEqual(tablesQuery.cells.count, 1)

        let staticText = tablesQuery.cells.elementBoundByIndex(0)
        staticText.tap()
        app.navigationBars.matchingIdentifier("Detail").buttons["Master"].tap()
        staticText.swipeLeft()
        tablesQuery.buttons["Delete"].tap()
        
        XCTAssertEqual(tablesQuery.cells.count, 0)
    }
    
}
