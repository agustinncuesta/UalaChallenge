//
//  NavigationBar.swift
//  UalaChallenge
//
//  Created by Agustin Nicolas Cuesta on 04/01/2025.
//

import SwiftUI

struct NavigationBar: View {
    
    var title: String
    var leftAction: (() -> Void)? = nil
    var rightAction: (() -> Void)? = nil
    var isPortrait: Bool

    var body: some View {
        VStack {
            if isPortrait {
                Spacer()
                    .frame(height: 50)
                getNavBar()
                    .padding(.vertical)
            } else {
                getNavBar()
            }
        }
    }
    
    @ViewBuilder
    func getNavBar() -> some View {
        HStack {
            if let leftAction = leftAction {
                Button(action: leftAction) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                .padding(.leading)
            } else {
                Spacer()
            }
            
            Spacer()
            
            Image("UalaIcon")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
            
            Spacer()
            
            if let rightAction = rightAction {
                Button(action: rightAction) {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                }
                .padding(.trailing)
                .hidden()
            } else {
                Spacer()
            }
        }
        .foregroundColor(.white)
    }
    
}
