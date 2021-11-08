//
//  DisplayMovieMainViewController.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-07.
//

import UIKit

class DisplayMovieMainViewController: UIViewController {

    @IBOutlet weak var ShowMovieDetailButton: UIButton!
    @IBOutlet weak var MovieNameLabel: UILabel!
    @IBOutlet weak var MovieYearLabel: UILabel!
    @IBOutlet weak var DislikeButton: UIButton!
    @IBOutlet weak var LikeButton: UIButton!
    var currentMovie: Int!
    public var moviesArray: [Int] = [];
    override func viewDidLoad() {
        print("DisplayMovieMainView Loaded")
        super.viewDidLoad()
        self.currentMovie = 0;
    }
    
    @IBAction func DislikeButtonClick(_ sender: UIButton) {
    }
    
    @IBAction func LikeButtonClick(_ sender: UIButton) {
    }
    
    
    func updateViewWithNextMovie() {
        self.currentMovie += 1;
    }
    
    func fetchNewMovie(currentMovie: Int) {
        var targetMovieId: Int = moviesArray[self.currentMovie];
        var targetMovie = fetchMovieData(movieId: targetMovieId);
        return;
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
