//
//  MovieDetailViewController.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-08.
//

import UIKit

class MovieDetailViewController: UIViewController {
    var movieData: MovieWithGenres!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.movieData)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dissmissSelf))
    }
    
    @objc private func dissmissSelf() {
        dismiss(animated: true, completion: nil)
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
