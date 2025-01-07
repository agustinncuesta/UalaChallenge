//
//  CityListViewModelTests.swift
//  CityListViewModelTests
//
//  Created by Agustin Nicolas Cuesta on 04/01/2025.
//

import XCTest
@testable import UalaChallenge

import MapKit

final class CityListViewModelTests: XCTestCase {

    var viewModel: CityListViewModel!

    
    override func setUp() async throws {
        
        await MainActor.run {
            self.viewModel = CityListViewModel()
            
            let city1 = City(id: UUID(), name: "Buenos Aires", country: "Argentina", coordinates: CLLocationCoordinate2D(latitude: -34.6037, longitude: -58.3816), isFavorite: true)
            let city2 = City(id: UUID(), name: "New York", country: "USA", coordinates: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), isFavorite: false)
            let city3 = City(id: UUID(), name: "Paris", country: "France", coordinates: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), isFavorite: true)
            
            self.viewModel.cities = [city1, city2, city3]
            self.viewModel.filteredCities = self.viewModel.cities
        }
    }

    override func tearDown() {
        viewModel = nil
    }


    func testFilterCities_NoFilters() async {
        
        // GIVEN
        await MainActor.run {
            viewModel.inputText = ""
            viewModel.isFavoriteFilterActive = false
        }
        
        // WHEN
        await viewModel.filterCities()

        // THEN
        await MainActor.run {
            XCTAssertEqual(viewModel.filteredCities.count, 3, "All cities should be returned when no filters are applied.")
        }
        
    }

    func testFilterCities_WithInputText() async {
        
        // GIVEN
        await MainActor.run {
            viewModel.inputText = "New"
            viewModel.isFavoriteFilterActive = false
        }
        let city1 = City(id: UUID(), name: "Buenos Aires", country: "Argentina", coordinates: CLLocationCoordinate2D(latitude: -34.6037, longitude: -58.3816), isFavorite: true)
        let city2 = City(id: UUID(), name: "New York", country: "USA", coordinates: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), isFavorite: false)
        let city3 = City(id: UUID(), name: "Paris", country: "France", coordinates: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), isFavorite: true)
        await MainActor.run {
            viewModel.cities = [city1, city2, city3]
            viewModel.filteredCities = viewModel.cities
        }
        let expectation = XCTestExpectation(description: "Waiting for filterCities to complete")
        
        // WHEN
        await viewModel.filterCities()

        // THEN
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewModel.filteredCities.count, 1, "Only cities with names matching 'New' should be returned.")
            XCTAssertEqual(self.viewModel.filteredCities.first?.name, "New York", "The filtered city should be New York.")
            expectation.fulfill()
        }
        await wait(for: [expectation], timeout: 2)
        
    }

    func testFilterCities_WithFavoriteFilter() async {
        
        // GIVEN
        await MainActor.run {
            viewModel.inputText = ""
            viewModel.isFavoriteFilterActive = true
        }
        let city1 = City(id: UUID(), name: "Buenos Aires", country: "Argentina", coordinates: CLLocationCoordinate2D(latitude: -34.6037, longitude: -58.3816), isFavorite: true)
        let city2 = City(id: UUID(), name: "New York", country: "USA", coordinates: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), isFavorite: false)
        let city3 = City(id: UUID(), name: "Paris", country: "France", coordinates: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), isFavorite: true)
        await MainActor.run {
            viewModel.cities = [city1, city2, city3]
            viewModel.filteredCities = viewModel.cities
        }
        let expectation = XCTestExpectation(description: "Waiting for filterCities to complete")
        
        // WHEN
        await viewModel.filterCities()
        
        // THEN
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewModel.filteredCities.count, 2, "Only cities that are favorites should be returned.")
            XCTAssertTrue(self.viewModel.filteredCities.contains(where: { $0.name == "Buenos Aires" }), "Buenos Aires should be in the filtered list.")
            XCTAssertTrue(self.viewModel.filteredCities.contains(where: { $0.name == "Paris" }), "Paris should be in the filtered list.")
            expectation.fulfill()
        }
        await wait(for: [expectation], timeout: 2)
        
    }

    func testFilterCities_WithBothFilters() async {
        
        // GIVEN
        await MainActor.run {
            viewModel.inputText = "Paris"
            viewModel.isFavoriteFilterActive = true
        }
        let city1 = City(id: UUID(), name: "Buenos Aires", country: "Argentina", coordinates: CLLocationCoordinate2D(latitude: -34.6037, longitude: -58.3816), isFavorite: true)
        let city2 = City(id: UUID(), name: "New York", country: "USA", coordinates: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), isFavorite: false)
        let city3 = City(id: UUID(), name: "Paris", country: "France", coordinates: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), isFavorite: true)
        await MainActor.run {
            viewModel.cities = [city1, city2, city3]
            viewModel.filteredCities = viewModel.cities
        }
        let expectation = XCTestExpectation(description: "Waiting for filterCities to complete")
        
        // WHEN
        await viewModel.filterCities()
        
        // THEN
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewModel.filteredCities.count, 1, "Only one city should match both filters.")
            XCTAssertEqual(self.viewModel.filteredCities.first?.name, "Paris", "The filtered city should be Paris.")
            expectation.fulfill()
        }
        await wait(for: [expectation], timeout: 2)
        
    }
    
}
