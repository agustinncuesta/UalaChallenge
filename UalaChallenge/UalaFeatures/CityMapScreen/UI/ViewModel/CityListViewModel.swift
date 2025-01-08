//
//  CityListViewModel.swift
//  UalaChallenge
//
//  Created by Agustin Nicolas Cuesta on 04/01/2025.
//

import Foundation
import SwiftData
import SwiftUI

import CoreData

import MapKit

@MainActor
class CityListViewModel: ObservableObject {
    
    var localStorage: ModelContext?
    
    let cityListModel = CityListModel()
    
    @Published var cities: [City] = []
    @Published var filteredCities: [City] = []
    var cityIndexMap: [UUID: Int] = [:]
    
    @Published var inputText: String = ""
    @Published var isFavoriteFilterActive = false
    @Published var selectedCity: City?
    var loading: Bool = true
    var networkError: Bool = false
    
    func setLocalStorage(localStorage: ModelContext) {
        self.localStorage = localStorage
    }
    
    func viewDidAppear() async {
        let favoriteCities = await getFavoriteCities()
        await fetchCities(withFavorites: favoriteCities)
    }
    
    func didTapFavoriteAction(city: City) {
        if city.isFavorite {
            saveCity(city: city)
        } else {
            deleteCity(city: city)
        }
        if let index = self.cityIndexMap[city.id] {
            self.cities[index].isFavorite = city.isFavorite
            filterCities()
        }
    }
    
    func fetchCities(withFavorites: [City]) async {
        Task.detached {
            await MainActor.run {
                self.loading = true
            }
            do {
                let cityListAPIModel: [CityListAPIModel] = try await self.cityListModel.fetchCities()
                let orderedCities = await self.orderCities(
                    cities: self.mapCityListAPIModel(cities: cityListAPIModel, withFavorites: withFavorites)
                )
                await MainActor.run {
                    self.cityIndexMap = orderedCities.enumerated().reduce(into: [:]) { result, pair in
                        result[pair.element.id] = pair.offset
                    }
                    self.cities = orderedCities
                    self.filteredCities = orderedCities
                    if !orderedCities.isEmpty {
                        self.selectedCity = orderedCities[0]
                    }
                    self.loading = false
                }
            } catch {
                await MainActor.run {
                    self.networkError = true
                    self.loading = false
                }
            }
        }
    }
    
    func filterCities() {
        let lowercasedPrefix = inputText.lowercased()
        filteredCities = cities.filter { city in
            city.name.lowercased().hasPrefix(lowercasedPrefix) &&
            (isFavoriteFilterActive == true ? city.isFavorite == true : true)
        }
    }
    
    func orderCities(cities: [City]) async -> [City] {
        await Task.detached { [weak self] in
            guard let self = self else { return [] }
            
            let sortedCities = cities.sorted {
                if $0.name == $1.name {
                    return $0.country < $1.country
                }
                return $0.name < $1.name
            }
            
            return sortedCities
        }.value
    }
    
}

extension CityListViewModel {
    
    func getFavoriteCities() async -> [City] {
        if let localStorage = self.localStorage {
            do {
                let descriptor = FetchDescriptor<CityLocalModel>()
                var localCities: [CityLocalModel]
                localCities = try localStorage.fetch(descriptor)
                for city in localCities {
                    print("ID: \(city.id), NAME: \(city.name)")
                }
                return self.mapLocalCityListToViewModel(cities: localCities)
            } catch {
                print("Unable to fetch favorites from Local Storage.")
                return []
            }
        } else {
            print("Local Storage not available.")
            return []
        }
    }
    
    func saveCity(city: City) {
        DispatchQueue.main.async {
            if let localStorage = self.localStorage {
                do {
                    localStorage.insert(self.mapCityToLocalModel(city: city))
                    try localStorage.save()
                } catch {
                    print("Failed to save city.")
                }
            }
        }
    }
    
    func deleteCity(city: City) {
        DispatchQueue.main.async {
            if let localStorage = self.localStorage {
                do {
                    let descriptor = FetchDescriptor<CityLocalModel>(predicate: #Predicate<CityLocalModel> { $0.name == city.name })
                    let results = try localStorage.fetch(descriptor)
                    guard let cityToDelete = results.first else {
                        print("No city found with the name \(city.name).")
                        return
                    }
                    localStorage.delete(cityToDelete)
                    print("City deleted successfully.")
                    try localStorage.save()
                    print("Changes saved successfully.")
                } catch {
                    print("Failed to delete city: \(error.localizedDescription)")
                }
            } else {
                print("Local storage is not initialized.")
            }
        }
    }

}

extension CityListViewModel {
    
    func mapCityListAPIModel(cities: [CityListAPIModel], withFavorites: [City]) -> [City] {
        var cityList: [City] = []
        for city in cities {
            let cityId = UUID(uuidString: String(city.id)) ?? UUID()
            let newCity = City(
                id: cityId,
                name: city.name,
                country: city.country,
                coordinates: CLLocationCoordinate2D(latitude: city.coord.lat, longitude: city.coord.lon),
                isFavorite: withFavorites.contains() { $0.name == city.name }
            )
            cityList.append(newCity)
        }
        return cityList
    }
    
    func mapCityToLocalModel(city: City) -> CityLocalModel {
        return CityLocalModel(
            id: city.id,
            name: city.name,
            country: city.country,
            coordinates: Coordinate(city.coordinates),
            isFavorite: city.isFavorite
        )
    }
    
    func mapLocalCityListToViewModel(cities: [CityLocalModel]) -> [City] {
        var cityList: [City] = []
        for city in cities {
            let newCity = City(
                id: city.id,
                name: city.name,
                country: city.country,
                coordinates: CLLocationCoordinate2D(latitude: city.coordinates.latitude, longitude: city.coordinates.longitude),
                isFavorite: city.isFavorite
            )
            cityList.append(newCity)
        }
        return cityList
    }
    
}
