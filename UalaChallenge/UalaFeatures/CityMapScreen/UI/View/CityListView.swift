//
//  CityListView.swift
//  UalaChallenge
//
//  Created by Agustin Nicolas Cuesta on 04/01/2025.
//

import SwiftUI

struct CityListView: View {
    @Environment(\.modelContext) private var localStorage
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @State private var isPortrait: Bool = true
    @FocusState private var isTextFieldFocused: Bool

    @StateObject private var cityListViewModel = CityListViewModel()

    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            if isPortrait {
                getPortraitView()
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                    .navigationDestination(for: Destination.self) { destination in
                        switch destination {
                            case .mapView(let city):
                                CityMapView(city: city, isPortrait: isPortrait)
                            case .infoView(let city):
                                CityInfoView(city: city, isPortrait: isPortrait)
                        }
                    }
            } else {
                getLandscapeView()
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                    .navigationDestination(for: Destination.self) { destination in
                        switch destination {
                            case .mapView(let city):
                                CityMapView(city: city, isPortrait: isPortrait)
                            case .infoView(let city):
                                CityInfoView(city: city, isPortrait: isPortrait)
                        }
                    }
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                self.orientation = UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight ? UIDevice.current.orientation : self.orientation
                self.isPortrait = self.orientation.isPortrait
            }
            self.cityListViewModel.setLocalStorage(localStorage: localStorage)
            Task {
                await self.cityListViewModel.viewDidAppear()
            }
        }
    }

    @ViewBuilder
    func getPortraitView() -> some View {
        VStack {
            getNavBarView(isPortrait: true)
            if cityListViewModel.loading {
                Spacer()
                ProgressView().tint(.white)
                Spacer()
            } else {
                getSearchBar()
                getListView()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }

    @ViewBuilder
    func getLandscapeView() -> some View {
        VStack {
            getNavBarView(isPortrait: false)
            HStack {
                VStack {
                    getSearchBar()
                    getListView()
                }
                if let selectedCity = cityListViewModel.selectedCity {
                    CityMapView(city: selectedCity, isPortrait: isPortrait)
                }
            }
                .padding(.leading, 30)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func getListView() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(cityListViewModel.filteredCities) { city in
                    Button(action: {
                        if isPortrait {
                            navigationPath.append(Destination.mapView(city: city))
                        } else {
                            cityListViewModel.selectedCity = city
                        }
                    }) {
                        CityRowView(
                            city: city,
                            didTapFavoriteAction: { city in
                                cityListViewModel.didTapFavoriteAction(city: city)
                            },
                            didTapInfoAction: { city in
                                navigationPath.append(Destination.infoView(city: city))
                            }
                        )
                    }
                }
                .foregroundColor(.white)
            }
            .listStyle(PlainListStyle())
            .scrollIndicators(.hidden)
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal)
    }

    @ViewBuilder
    func getSearchBar() -> some View {
        HStack {
            Button(action: {
                cityListViewModel.isFavoriteFilterActive.toggle()
                cityListViewModel.filterCities()
            }) {
                Image(systemName: cityListViewModel.isFavoriteFilterActive ? "star.fill" : "star")
                    .foregroundColor(cityListViewModel.isFavoriteFilterActive ? Color(red: 0.96, green: 0.36, blue: 0.47) : .white)
                    .font(.system(size: 20, weight: .medium))
                    .animation(.easeInOut(duration: 0.2), value: cityListViewModel.isFavoriteFilterActive)
            }
                .buttonStyle(PlainButtonStyle())
            TextField("", text: $cityListViewModel.inputText)
                .frame(height: 40)
                .padding(.horizontal, 10)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(15)
                .shadow(radius: 10)
                .onChange(of: cityListViewModel.inputText) { newValue in
                    cityListViewModel.filterCities()
                }
                .focused($isTextFieldFocused)
        }
        .padding(.all)
    }

    @ViewBuilder
    func getNavBarView(isPortrait: Bool) -> some View {
        NavigationBar(title: "", isPortrait: isPortrait)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.02, green: 0.16, blue: 0.59), Color(red: 0.33, green: 0.42, blue: 0.74)]),
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
}


enum Destination: Hashable, Codable {
    
    case mapView(city: City)
    case infoView(city: City)

    enum CodingKeys: String, CodingKey {
        case mapView
        case infoView
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let city = try? container.decode(City.self) {
            self = .mapView(city: city)
        } else if let city = try? container.decode(City.self) {
            self = .infoView(city: city)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid Destination type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .mapView(let city):
            try container.encode(city)
        case .infoView(let city):
            try container.encode(city)
        }
    }
    
}
