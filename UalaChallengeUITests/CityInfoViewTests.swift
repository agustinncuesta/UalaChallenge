//
//  CityInfoViewTests.swift
//  UalaChallenge
//
//  Created by Agustin Nicolas Cuesta on 06/01/2025.
//

import XCTest
@testable import UalaChallenge

import MapKit

class CityInfoViewTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testCityInfoViewDisplaysCorrectData() {
        
        // GIVEN
        let firstCityRow = app.buttons["cityRow-cityRow-cityRow-cityRow-cityRow"].firstMatch
        XCTAssertTrue(firstCityRow.waitForExistence(timeout: 15), "City list did not load in time.")
        let cityNameLabel = firstCityRow.staticTexts.firstMatch
        XCTAssertTrue(cityNameLabel.exists, "City name label should exist in the first row.")
        var cityNameInRow = cityNameLabel.label

        // WHEN
        let buttonsInFirstCityRow = firstCityRow.buttons
        if buttonsInFirstCityRow.count > 1 {
            let secondButton = buttonsInFirstCityRow.element(boundBy: 1)
            secondButton.tap()
        }
    
        // THEN
        let cityInfoNameLabel = app.staticTexts["cityInfo.name"]
        if let commaIndex = cityNameInRow.firstIndex(of: ",") {
            cityNameInRow = String(cityNameInRow.prefix(upTo: commaIndex))
        }
        XCTAssertTrue(cityInfoNameLabel.waitForExistence(timeout: 5), "CityInfoView did not appear in time.")
        XCTAssertEqual(cityInfoNameLabel.label, cityNameInRow, "City name in CityInfoView does not match the name from the list.")
        
    }
    
}
