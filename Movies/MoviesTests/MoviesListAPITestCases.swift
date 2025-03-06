//
//  MoviesListAPITestCases.swift
//  MoviesTests
//
//  Created by Baljeet Singh Raghav on 06/03/25.
//

import XCTest
@testable import Movies

final class MoviesListAPITestCases: XCTestCase {
    var viewModel:ProtocolMovieLIstVM?
    
    
    override func setUp() async throws {
        let urlSession =  URLSession(configuration: .default)
        let networkManager = NetworkManager(session: urlSession)  // Dependency injection
        viewModel = MovieLIstVM(networkManager: networkManager)
    }
    
    override  func tearDown() {
        viewModel =  nil
        super.tearDown()
    }
    func testFetchMovies_success() async {
        let expectation =  expectation(description: "movies")
        await viewModel?.apiCallingForFetchList(pageNo: 1, completionBlock: { [weak self] in
            guard let self =  self else{return}
            XCTAssertGreaterThan(self.viewModel?.list.count ?? 0, 0, "Movies count should be greater than 0")
            expectation.fulfill()
            
        })
        await waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testfetchMovieEmptyResult() async {
        
        let expectation =  expectation(description: "movies List Empty")
        await viewModel?.apiCallingForFetchList(pageNo: 1, completionBlock: { [weak self] in
            guard let self =  self else{return}
           
            XCTAssertTrue(((self.viewModel?.list.isEmpty) != nil), "Movies count should be zero")
            expectation.fulfill()
            
        })
        await waitForExpectations(timeout: 2.0, handler: nil)
        
    }
    
    func testFetchMovieFailure() async {
        let expectation =  expectation(description: "movies List Empty")
        viewModel?.didFetchError = { [weak self] error in
            guard let self =  self else{return}
           XCTAssertNotNil(error)
            expectation.fulfill()
        }
        viewModel?.didFetchError?(NSError(domain: "TestErro", code: 1001))
       await waitForExpectations(timeout: 2, handler: nil)
    }
    

}
