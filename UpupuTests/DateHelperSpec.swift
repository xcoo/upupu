//
//  DateHelperSpec.swift
//  UpupuTests
//
//  Created by Toshiki Takeuchi on 2017/07/25.
//  Copyright © 2017 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Quick
import Nimble

@testable import Upupu

class DateHelperSpec: QuickSpec {

    override func spec() {
        describe("dateString") {
            it("returns yyyyMMdd") {
                let date = Date(timeIntervalSince1970: 0)
                expect(DateHelper.dateString(date)).to(match("^[0-9]{8}$"))
            }
        }

        describe("dateTimeString") { 
            it("returns yyyyMMdd_HHmmss") {
                let date = Date(timeIntervalSince1970: 0)
                expect(DateHelper.dateTimeString(date)).to(match("^[0-9]{8}_[0-9]{6}$"))
            }
        }
    }

}
