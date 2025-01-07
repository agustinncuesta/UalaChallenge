//
//  CityListAPIModel.swift
//  UalaChallenge
//
//  Created by Agustin Nicolas Cuesta on 04/01/2025.
//

struct CityListAPIModel: Codable {
    
    let country: String
    let name: String
    let id: Int
    let coord: Coordinates
    
    init(country: String, name: String, id: Int, coord: Coordinates) {
        self.country = country
        self.name = name
        self.id = id
        self.coord = coord
    }
        
    enum CodingKeys: String, CodingKey {
        case country = "country"
        case name = "name"
        case id = "_id"
        case coord = "coord"
    }
    
}

struct Coordinates: Codable {
    let lon: Double
    let lat: Double
}
