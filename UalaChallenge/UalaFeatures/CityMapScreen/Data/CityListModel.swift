//
//  CityListModel.swift
//  UalaChallenge
//
//  Created by Agustin Nicolas Cuesta on 04/01/2025.
//

import Foundation

class CityListModel {
    
    let urlString = "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json"
    
    func fetchCities() async throws -> [CityListAPIModel] {
        let url = URL(string: urlString)!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([CityListAPIModel].self, from: data)
    }
    
}
