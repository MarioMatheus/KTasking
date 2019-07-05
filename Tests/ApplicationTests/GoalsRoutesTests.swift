////
////  GoalsRoutesTests.swift
////  Application
////
////  Created by Mario Matheus on 22/06/19.
////
//
//import XCTest
//import KituraNet
//import Foundation
//
//@testable import Application
//
//class TestGetRoutes: KituraTest {
//
//    static var allTests: [(String, (TestGetRoutes) -> () throws -> Void)] {
//        return [
//            ("testGetGoalsWithoutParams", testGetGoalsWithoutParams),
//            ("testGetGoalsWithParamsMatching", testGetGoalsWithParamsMatching),
//            ("testGetGoalsWithParamsNotMatching", testGetGoalsWithParamsNotMatching),
//        ]
//    }
//
//    func testGetGoalsWithoutParams() {
//        let goalTest = Goal(id: "0", createdAt: Date.distantPast, name: "GoalTest", tasks: [])
//        performServerTest(asyncTasks: { expectation in
//            self.performRequest("get", path: "/goals", expectation: expectation) { response in
//                self.checkCodableResponse(response: response, expectedResponseArray: [goalTest])
//                expectation.fulfill()
//            }
//        })
//    }
//
//    func testGetGoalsWithParamsMatching() {
//        let goalTest = Goal(id: "0", createdAt: Date.distantPast, name: "GoalTest", tasks: [])
//        performServerTest(asyncTasks: { expectation in
//            self.performRequest("get", path: "/goals?name=GoalTest", expectation: expectation) { response in
//                self.checkCodableResponse(response: response, expectedResponseArray: [goalTest])
//                expectation.fulfill()
//            }
//        })
//    }
//
//    func testGetGoalsWithParamsNotMatching() {
//        performServerTest(asyncTasks: { expectation in
//            self.performRequest("get", path: "/goals?name=Test", expectation: expectation) { response in
//                self.checkCodableResponse(response: response, expectedResponseArray: [Goal]())
//                expectation.fulfill()
//            }
//        })
//    }
//
//
//    func testPostGoals() {
//        let goalTest = Goal(id: "0", createdAt: Date.distantPast, name: "GoalTest", tasks: [])
//        let goal2TestBody: String = "{\"name\": \"Goal 2 Test\",\"createdAt\": -63114076800}"
//        let goal2Test = Goal(id: "1", createdAt: Date.distantPast, name: "Goal 2 Test", tasks: [])
//        performServerTest(asyncTasks: { expectation in
//            self.performRequest("post", path: "/goals", body: goal2TestBody, expectation: expectation, headers: ["Content-Type":"application/json"]) { response in
//                print(response)
//                self.checkCodableResponse(response: response, expectedResponse: goal2Test, expectedStatusCode: HTTPStatusCode.created)
//                self.performRequest("get", path: "/goals", expectation: expectation, headers: ["Content-Type":"application/json"]) { response in
//                    self.checkCodableResponse(response: response, expectedResponse: [goalTest, goal2Test])
//                    expectation.fulfill()
//                }
//            }
//        })
//    }
//
//}
