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
    
    @Published var inputText: String = ""
    @Published var isFavoriteFilterActive = false
    @Published var selectedCity: City?
    var loading: Bool = true
    var networkError: Bool = false
    
    func setLocalStorage(localStorage: ModelContext) {
        self.localStorage = localStorage
    }
    
    func viewDidAppear() async {
        let favoriteCities = await getFavoriteCity()
        await fetchCities(withFavorites: favoriteCities)
    }
    
    func didTapFavoriteAction(city: City) {
        if city.isFavorite {
            saveCity(city: city)
        } else {
            deleteCity(city: city)
        }
        
        Task.detached {
            await MainActor.run {
                var updatedCities = self.cities
                if let index = updatedCities.firstIndex(where: { $0.id == city.id }) {
                    updatedCities[index].isFavorite = city.isFavorite
                }
                self.cities = updatedCities
            }
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
        Task.detached { [weak self] in
            guard let self = self else { return }
            
            let (bgCities, bgInputText, bgIsFavoriteFilterActive): ([City], String, Bool) = await MainActor.run {
                (self.cities, self.inputText, self.isFavoriteFilterActive)
            }

            let filteredResults: [City] = {
                var results = bgInputText.isEmpty ? bgCities : bgCities.filter {
                    $0.name.range(of: bgInputText, options: [.caseInsensitive, .anchored]) != nil
                }

                if bgIsFavoriteFilterActive {
                    results = results.filter { $0.isFavorite }
                }

                return results
            }()

            await MainActor.run {
                self.filteredCities = filteredResults
                self.selectedCity = filteredResults.first
            }
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
    
    func getFavoriteCity() async -> [City] {
        if let localStorage = self.localStorage {
            do {
                let descriptor = FetchDescriptor<CityLocalModel>()
                var localCities: [CityLocalModel]
                localCities = try localStorage.fetch(descriptor)
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
    
    func getFavoriteCities() -> [City] {
        var favoriteCities: [City] = []
        DispatchQueue.main.async {
            if let localStorage = self.localStorage {
                do {
                    let descriptor = FetchDescriptor<CityLocalModel>()
                    var localCities: [CityLocalModel]
                    localCities = try localStorage.fetch(descriptor)
                    favoriteCities = self.mapLocalCityListToViewModel(cities: localCities)
                } catch {
                    print("Unable to fetch favorites from Local Storage.")
                }
            } else {
                print("Local Storage not available.")
            }
        }
        return favoriteCities
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
                    let localModel = self.mapCityToLocalModel(city: city)
                    print("Attempting to delete local model: \(localModel)")
                    
                    localStorage.delete(localModel)
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
        for fav in withFavorites {
            print(fav.name)
        }
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
