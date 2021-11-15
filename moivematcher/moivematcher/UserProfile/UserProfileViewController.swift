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

class GridViewModel: ObservableObject {
    
    @Published var genres = [String]()

    init() {
        var length = 0
        
        if genresLikedArray.count >= 3 {
            print("length is 2")
            length = 2
        }
        else {
            length = genresLikedArray.count
        }
        
        if genresLikedArray.count > 0 {
            self.genres = Array(genresLikedArray[...length])
            print(Array(Set(genresLikedArray.sortByNumberOfOccurences())))
        }
        else {
            print("less than 3 movies")
//            self.genres = ["Animation"]
        }
    }
}

struct ContentView: View {
    
    var vm = GridViewModel()
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
                .navigationTitle("Favorite Genres")
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
