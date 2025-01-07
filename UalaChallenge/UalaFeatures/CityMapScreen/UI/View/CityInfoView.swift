//
//  CityInfoView.swift
//  UalaChallenge
//
//  Created by Agustin Nicolas Cuesta on 06/01/2025.
//

import SwiftUI

struct CityInfoView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let city: City
    let isPortrait: Bool
    
    init(city: City, isPortrait: Bool) {
        self.city = city
        self.isPortrait = isPortrait
    }
    
    var body: some View {
        NavigationView {
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
                VStack {
                    Spacer()
                    VStack {
                        Text(city.name)
                            .font(.title)
                            .italic()
                            .padding(.bottom)
                            .accessibilityIdentifier("cityInfo.name")
                        Text(city.country)
                            .font(.headline)
                            .padding(.bottom)
                        Text("Lat: \(parseCoordinate(city.coordinates.latitude)), Long: \(parseCoordinate(city.coordinates.longitude))")
                            .font(.subheadline)
                    }
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(.all)
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
    
}
