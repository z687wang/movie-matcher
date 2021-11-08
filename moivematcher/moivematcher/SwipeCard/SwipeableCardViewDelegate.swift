//
//  SwipeableCardViewDelegate.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-08.
//

import Foundation

import Foundation

protocol SwipeableCardViewDelegate: class {

    func didSelect(card: SwipeableCardViewCard, atIndex index: Int)

}
