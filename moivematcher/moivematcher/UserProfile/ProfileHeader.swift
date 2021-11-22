//
//  ProfileHeader.swift
//  moivematcher
//
//  Created by Yalu Cai on 11/14/21.
//

import SwiftUI

struct ProfileHeader: View {
    let gradient = Gradient(colors: [.black, .red])
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                VStack {
                SwiftUI.Image("Joker")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .clipped()
//                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .padding(.top, 44)
                    
                    Text("Joker").font(.system(size: 20)).bold().foregroundColor(.white)
                        .padding(.top, 12)
                }
                Spacer()
            }
            Spacer()
        }
        .background(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
    }
}
