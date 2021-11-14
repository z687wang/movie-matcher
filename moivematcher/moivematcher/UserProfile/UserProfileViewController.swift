//
//  UserProfileViewController.swift
//  moivematcher
//
//  Created by Yalu Cai on 11/14/21.
//

import UIKit
import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel = GenreViewModel()
    
    var body: some View {
        VStack {
            ProfileHeader()
            
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
