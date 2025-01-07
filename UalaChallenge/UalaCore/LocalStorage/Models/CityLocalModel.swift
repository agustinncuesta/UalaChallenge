//
//  CityLocalModel.swift
//  UalaChallenge
//
//  Created by Agustin Nicolas Cuesta on 05/01/2025.
//

import SwiftData

import MapKit

@Model
class CityLocalModel: Identifiable {
    
    var id: UUID
    var name: String
    var country: String
    var coordinates: Coordinate
    var isFavorite: Bool
    
    init(id: UUID, name: String, country: String, coordinates: Coordinate, isFavorite: Bool) {
        self.id = id
        self.name = name
        self.country = country
        self.coordinates = coordinates
        self.isFavorite = isFavorite
    }
    
}

@Model
class Coordinate {
    var latitude: Double
    var longitude: Double

    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
