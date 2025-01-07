//
//  City.swift
//  UalaChallenge
//
//  Created by Agustin Nicolas Cuesta on 06/01/2025.
//

import SwiftUI

import MapKit

class City: Identifiable, Hashable, ObservableObject, Codable {
    
    var id: UUID
    var name: String
    var country: String
    var coordinates: CLLocationCoordinate2D
    @Published var isFavorite: Bool
    
    init(id: UUID = UUID(), name: String, country: String, coordinates: CLLocationCoordinate2D, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.country = country
        self.coordinates = coordinates
        self.isFavorite = isFavorite
    }
    
    static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case country
        case coordinates
        case isFavorite
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        country = try container.decode(String.self, forKey: .country)
        coordinates = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinates)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(country, forKey: .country)
        try container.encode(coordinates, forKey: .coordinates)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
}

extension CLLocationCoordinate2D: Codable {
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.latitude, forKey: .latitude)
        try container.encode(self.longitude, forKey: .longitude)
    }
    
}
