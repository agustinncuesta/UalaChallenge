//
//  CityMapView.swift
//  UalaChallenge
//
//  Created by Agustin Nicolas Cuesta on 04/01/2025.
//

import SwiftUI
import MapKit

struct CityMapView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var city: City
    let isPortrait: Bool
    
    @State private var region: MKCoordinateRegion

    init(city: City, isPortrait: Bool) {
        self.city = city
        _region = State(initialValue: MKCoordinateRegion(
            center: city.coordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        self.isPortrait = isPortrait
    }

    var body: some View {
        NavigationView {
            ZStack() {
                Map(coordinateRegion: $region, annotationItems: [city]) { city in
                    MapMarker(coordinate: city.coordinates, tint: .red)
                }
                .onChange(of: city.coordinates) { newCoordinates in
                    region.center = newCoordinates
                }
                if isPortrait {
                    VStack() {
                        NavigationBar(
                            title: "",
                            leftAction: { presentationMode.wrappedValue.dismiss() },
                            rightAction: { print("") },
                            isPortrait: isPortrait
                        )
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.02, green: 0.16, blue: 0.59), Color(red: 0.33, green: 0.42, blue: 0.74)]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
    
}


import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
