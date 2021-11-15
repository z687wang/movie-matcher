//
//  UserProfileViewController.swift
//  moivematcher
//
//  Created by Yalu Cai on 11/14/21.
//

import UIKit
import SwiftUI

struct ContentView: View {
    
    @ObservedObject var vm = GenreViewModel()
    
    var body: some View {
        
        VStack {
            ProfileHeader()
            Text("Favorite Genres")
                .font(.system(size: 20, weight: .bold))
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 100, maximum: 200), spacing: 16),
                GridItem(.flexible(minimum: 100, maximum: 200), spacing: 16),
                GridItem(.flexible(minimum: 50, maximum: 200)),
            ], spacing: 12, content: {
                ForEach(genresLikedArray[...2], id: \.self) { genre in
//                    AppInfo(app: app)
                    VStack() {
                        SwiftUI.Image(genre)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .clipped()
        //                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .padding()
//                        Spacer()
//                            .frame(width: 100, height: 100)
//                            .background(SwiftUI.Color.blue)
                        Text(genre)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding()
//                    .background(SwiftUI.Color.red)
                }
            }).padding(.horizontal, 12)
                .navigationTitle("Favorite Genres")
        }
    }
}

class UserProfileViewController: UIHostingController<ContentView>, UICollectionViewDelegate {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder,rootView: ContentView());
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        let v : ContentView = ContentView()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
