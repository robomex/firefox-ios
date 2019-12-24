/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

let mozDeveloperWebsite = "https://developer.mozilla.org/en-US"
let searchFieldPlaceholder = "Search MDN"
class ThirdPartySearchTest: BaseTestCase {
    fileprivate func dismissKeyboardAssistant(forApp app: XCUIApplication) {
        app.buttons["Done"].tap()
    }

    func testCustomSearchEngines() {
        navigator.performAction(Action.AddCustomSearchEngine)
        app.navigationBars["Search"].buttons["Settings"].tap()
        app.navigationBars["Settings"].buttons["AppSettingsTableViewController.navigationItem.leftBarButtonItem"].tap()
            
        // Perform a search using a custom search engine
        app.textFields["url"].tap()
        waitForExistence(app.buttons["urlBar-cancel"])
        app.typeText("window")
        app.scrollViews.otherElements.buttons["Mozilla Engine search"].tap()
        waitUntilPageLoad()

        var url = app.textFields["url"].value as! String
        if url.hasPrefix("https://") == false {
            url = "https://\(url)"
        }
        XCTAssert(url.hasPrefix("https://developer.mozilla.org/en-US"), "The URL should indicate that the search was performed on MDN and not the default")
    }

    func testCustomSearchEngineAsDefault() {
        navigator.performAction(Action.AddCustomSearchEngine)
        
        // Go to settings and set MDN as the default
        waitForExistence(app.tables.cells.element(boundBy: 0))
        app.tables.cells.element(boundBy: 0).tap()
        waitForExistence(app.tables.staticTexts["Mozilla Engine"])
        app.tables.staticTexts["Mozilla Engine"].tap()
        DismissSearchScreen()

        // Perform a search to check
        app.textFields["url"].tap()
        waitForExistence(app.buttons["urlBar-cancel"])
        app.typeText("window")
        app.typeText("\r")
        waitUntilPageLoad()

        // Ensure that the default search is MDN
        var url = app.textFields["url"].value as! String
        if url.hasPrefix("https://") == false {
            url = "https://\(url)"
        }
        XCTAssert(url.hasPrefix("https://developer.mozilla.org/en-US/search"), "The URL should indicate that the search was performed on MDN and not the default")
    }

    func testCustomSearchEngineDeletion() {
        navigator.performAction(Action.AddCustomSearchEngine)
        app.navigationBars["Search"].buttons["Settings"].tap()
        app.navigationBars["Settings"].buttons["AppSettingsTableViewController.navigationItem.leftBarButtonItem"].tap()
        app.textFields["url"].tap()
        waitForExistence(app.buttons["urlBar-cancel"])
        app.typeText("window")
        waitForExistence(app.scrollViews.otherElements.buttons["Mozilla Engine search"])
        XCTAssertTrue(app.scrollViews.otherElements.buttons["Mozilla Engine search"].exists)
                                
        // Need to go step by step to Search Settings. The ScreenGraph will fail to go to the Search Settings Screen
        app.buttons["urlBar-cancel"].tap()
        app.buttons["TabToolbar.menuButton"].tap()
        app.tables["Context Menu"].staticTexts["Settings"].tap()
        app.tables.staticTexts["Google"].tap()
        navigator.performAction(Action.RemoveCustomSearchEngine)
        DismissSearchScreen()
        
        // Perform a search to check
        waitForExistence(app.textFields["url"], timeout: 3)
        app.textFields["url"].tap()
        waitForExistence(app.buttons["urlBar-cancel"])
        app.typeText("window")
        waitForNoExistence(app.scrollViews.otherElements.buttons["Mozilla Engine search"])
        XCTAssertFalse(app.scrollViews.otherElements.buttons["Mozilla Engine search"].exists)
    }
    
    private func DismissSearchScreen() {
        waitForExistence(app.navigationBars["Search"].buttons["Settings"])
        app.navigationBars["Search"].buttons["Settings"].tap()
        app.navigationBars["Settings"].buttons["AppSettingsTableViewController.navigationItem.leftBarButtonItem"].tap()
    }

    func testCustomEngineFromIncorrectTemplate() {
        navigator.goto(AddCustomSearchSettings)
        app.textViews["customEngineTitle"].tap()
        app.typeText("Feeling Lucky")
        app.textViews["customEngineUrl"].tap()
        app.typeText("http://www.google.com/search?q=&btnI") //Occurunces of %s != 1

        app.navigationBars.buttons["customEngineSaveButton"].tap()

        waitForExistence(app.alerts.element(boundBy: 0))
        XCTAssert(app.alerts.element(boundBy: 0).label == "Failed")
    }
}
