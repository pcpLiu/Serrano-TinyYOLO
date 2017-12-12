//
//  YoloModelTest.swift
//  SerranoYOLOTests
//
//  Created by ZHONGHAO LIU on 11/25/17.
//  Copyright © 2017 Serrano. All rights reserved.
//

import XCTest
import SerranoYOLO
import Serrano

class YoloModelTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testModelLoading() {
		SerranoLogging.release = true
		let _ = SerranoEngine.configuredEngine.configureEngine(computationMode: .GPU)
		let model = YOLOModel.yoloModel()
		model.forwardPrepare()
		let start = CFAbsoluteTimeGetCurrent()
		model.forward(mode: .GPU)
		print("Forward Execution Time : \((CFAbsoluteTimeGetCurrent() - start) * 100) ms")
	}
    
}
