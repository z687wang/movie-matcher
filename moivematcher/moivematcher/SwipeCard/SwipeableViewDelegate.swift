//
//  SwipeableViewDelegate.swift
//  moivematcher
//
//  Created by Zhe Wang on 2021-11-08.
//

import Foundation

protocol SwipeableViewDelegate: class {

    func didTap(view: SwipeableView)

    func didBeginSwipe(onView view: SwipeableView)

    func didEndSwipe(onView view: SwipeableView)

}
