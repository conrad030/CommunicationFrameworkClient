//
//  CallingViewModelTests.swift
//  CommunicationFrameworkTests
//
//  Created by Conrad Felgentreff on 10.06.22.
//

import XCTest
@testable import CommunicationFramework

class CallingViewModelTests: XCTestCase {
    var sut: CallingViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.sut = CallingViewModel(callingModel: MockCallingModel())
    }
    
    override func tearDownWithError() throws {
        self.sut = nil
        try super.tearDownWithError()
    }
}
