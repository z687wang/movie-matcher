//
//  UserProfileViewController.swift
//  moivematcher
//
//  Created by Yalu Cai on 11/14/21.
//

import UIKit
import SwiftUI

extension Array where Element: Comparable & Hashable {
    func sortByNumberOfOccurences() -> [Element] {
        let occurencesDict = self.reduce(into: [Element:Int](), { currentResult, element in
            currentResult[element, default: 0] += 1
        })
        return self.sorted(by: { current, next in occurencesDict[current]! < occurencesDict[next]!})
    }
}

class ActorViewModel: ObservableObject {
    
    @Published var actors = [Actor]()

    init() {
        var length = 0
        
        if actorsLikedArray.count >= 3 {
            length = 2
        }
        else {
            length = actorsLikedArray.count
        }
        
        if actorsLikedArray.count > 0 {
            self.actors = Array(Array(Set(actorsLikedArray.sortByNumberOfOccurences()))[...length])
//            print(Array(Set(genresLikedArray.sortByNumberOfOccurences())))
        }
        else {
            print("less than 3 movies")
//            self.genres = ["Animation"]
        }
    }
}

struct ContentView: View {
    
    var vm = ActorViewModel()
    var body: some View {
        
        VStack {
            ProfileHeader()
            Text("Favorite Genres")
                .font(.system(size: 20, weight: .bold))
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 100, maximum: 180), spacing: 12),
                GridItem(.flexible(minimum: 100, maximum: 180), spacing: 12),
                GridItem(.flexible(minimum: 50, maximum: 180)),
            ], spacing: 12, content: {
                ForEach(Array(Set(genresLikedArray.sortByNumberOfOccurences()))[...2], id: \.self) { genre in
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
            Text("Favorite Actors")
                .font(.system(size: 20, weight: .bold))
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 100, maximum: 180), spacing: 12),
                GridItem(.flexible(minimum: 100, maximum: 180), spacing: 12),
                GridItem(.flexible(minimum: 100, maximum: 180)),
            ], spacing: 12, content: {
                ForEach(vm.actors, id: \.self) { a in
//                    AppInfo(app: app)
                    VStack() {
                        AsyncImage(url: a.profileURL) {
                            phase in
                                 if let image = phase.image {
                                     image.resizable()
                                         .aspectRatio(contentMode: .fill)
                                } else if phase.error != nil {
                                    Text("Error!")
                                } else {
                                    Text("Loading...")
                                }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .clipped()
//                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .padding()
//                        Spacer()
//                            .frame(width: 100, height: 100)
//                            .background(SwiftUI.Color.blue)
                        Text(a.name)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding()
//                    .background(SwiftUI.Color.red)
                    
                }
            }).padding(.horizontal, 12)
        }
    }
}

class UserProfileViewController: UIHostingController<ContentView>{
    
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: ContentView());
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("At profile view")
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("At profile view")
        self.rootView = ContentView()
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
