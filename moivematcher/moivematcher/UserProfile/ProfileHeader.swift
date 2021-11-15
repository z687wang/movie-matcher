//
//  ProfileHeader.swift
//  moivematcher
//
//  Created by Yalu Cai on 11/14/21.
//

import SwiftUI

struct ProfileHeader: View {
    let gradient = Gradient(colors: [.green, .blue])
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                VStack {
                SwiftUI.Image("clouds")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .clipped()
//                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .padding(.top, 44)
                    
                    Text("Yalu Cai").font(.system(size: 20)).bold().foregroundColor(.white)
                        .padding(.top, 12)
                    
                    Text("@yc468").font(.system(size: 18)).foregroundColor(.white)
                    .padding(.top, 4)
                }
                Spacer()
            }
            Spacer()
        }
        .background(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
    }
}
