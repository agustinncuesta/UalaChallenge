//
//  CityRowView.swift
//  UalaChallenge
//
//  Created by Agustin Nicolas Cuesta on 04/01/2025.
//

import SwiftUI
import MapKit

struct CityRowView: View {
    
    @ObservedObject var city: City
    
    var didTapFavoriteAction: (City) -> ()
    var didTapInfoAction: (City) -> ()
    
    var body: some View {
        HStack {
            Button(action: {
                city.isFavorite.toggle()
                didTapFavoriteAction(city)
            }) {
                Image(systemName: city.isFavorite ? "star.fill" : "star")
                    .foregroundColor(city.isFavorite ? Color(red: 0.96, green: 0.36, blue: 0.47) : .white)
                    .font(.system(size: 20, weight: .medium))
                    .animation(.easeInOut(duration: 0.2), value: city.isFavorite)
            }
                .buttonStyle(PlainButtonStyle())
                .accessibilityIdentifier("cityRowFav")
            VStack {
                HStack {
                    Text("\(city.name), \(city.country)")
                        .font(.system(size: 20, weight: .medium))
                        .accessibilityIdentifier("cityNameLabel")
                    Spacer()
                }
                HStack {
                    Text("Lat: \(parseCoordinate(city.coordinates.latitude)), Long: \(parseCoordinate(city.coordinates.longitude))")
                        .font(.system(size: 14, weight: .light))
                        .accessibilityIdentifier("cityRowCoord")
                    Spacer()
                }
            }
                .padding(.leading, 10)
            Spacer()
            HStack {
                Button(action: {
                    didTapInfoAction(city)
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                }
            }
                .padding(.trailing, 20)
                .accessibilityIdentifier("infoButton")
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .medium))
                .frame(width: 20, height: 20, alignment: .center)
                .accessibilityIdentifier("cityRowChev")
        }
        .accessibilityIdentifier("cityRow")
    }
    
}

public func parseCoordinate(_ input: CLLocationDegrees) -> String {
    let coordinate = String(input)
    if let commaIndex = coordinate.firstIndex(of: ".") {
        let endIndex = coordinate.index(commaIndex, offsetBy: 2)
        let substring = coordinate[..<endIndex]
        return String(substring)
    } else {
        return ""
    }
}
