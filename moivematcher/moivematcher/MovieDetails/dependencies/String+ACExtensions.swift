//
//  String+ACExtensions.swift
//
//  Created by Alejandro Cotilla on 3/3/18.
//  Copyright © 2018 Carolco LLC. All rights reserved.
//

import Foundation
import UIKit

extension String {

    func stringsBetweenText(_ txt1: String, andText txt2: String, startingFromOccurenceOf startPointStr: String) -> [String] {
        let startPointStrRange = (self as NSString).range(of: startPointStr)
        if startPointStrRange.location != NSNotFound {
            let searchOnStr = (self as NSString).substring(from: startPointStrRange.location + startPointStrRange.length)
            return searchOnStr.stringsBetweenText(txt1, andText: txt2)
        }
        return stringsBetweenText(txt1, andText: txt2)
    }
    
    func stringsBetweenText(_ txt1: String, andText txt2: String, allowDuplicates duplicates: Bool = true) -> [String] {
        var strings = [String]()

        var beforeRange = (self as NSString).range(of: txt1)
        while beforeRange.location != NSNotFound {
            var enclosedRange = NSMakeRange(beforeRange.location + beforeRange.length, (self as NSString).length - (beforeRange.location + beforeRange.length))
            let afterRange = (self as NSString).range(of: txt2, options: String.CompareOptions.literal, range: enclosedRange, locale: nil)
            if afterRange.location != NSNotFound {
                let betweenRange = NSMakeRange(beforeRange.location + beforeRange.length, afterRange.location - (beforeRange.location + beforeRange.length))
                let string = (self as NSString).substring(with: betweenRange)
                if duplicates || (!duplicates && !strings.contains(string)) {
                    strings.append(string)
                }
            }
            else {
                return strings
            }
            
            enclosedRange = NSMakeRange(afterRange.location + afterRange.length, (self as NSString).length - (afterRange.location + afterRange.length))
            beforeRange = (self as NSString).range(of: txt1, options: String.CompareOptions.literal, range: enclosedRange, locale: nil)
        }

        return strings
    }
    
    var isInt: Bool {
        return Int(self) != nil
    }
    
    func contains(_ charSet: CharacterSet) -> Bool {
        return self.rangeOfCharacter(from: charSet) != nil
    }
    
    /// SwifterSwift: Safely subscript string with index.
    ///
    ///        "Hello World!"[3] -> "l"
    ///        "Hello World!"[20] -> nil
    ///
    /// - Parameter i: index.
    public subscript(safe i: Int) -> Character? {
        guard i >= 0 && i < count else { return nil }
        return self[index(startIndex, offsetBy: i)]
    }
    
    /// SwifterSwift: Safely subscript string within a half-open range.
    ///
    ///        "Hello World!"[6..<11] -> "World"
    ///        "Hello World!"[21..<110] -> nil
    ///
    /// - Parameter range: Half-open range.
    public subscript(safe range: CountableRange<Int>) -> String? {
        guard let lowerIndex = index(startIndex, offsetBy: max(0, range.lowerBound), limitedBy: endIndex) else { return nil }
        guard let upperIndex = index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) else { return nil }
        return String(self[lowerIndex..<upperIndex])
    }
    
    /// SwifterSwift: Safely subscript string within a closed range.
    ///
    ///        "Hello World!"[6...11] -> "World!"
    ///        "Hello World!"[21...110] -> nil
    ///
    /// - Parameter range: Closed range.
    public subscript(safe range: ClosedRange<Int>) -> String? {
        guard let lowerIndex = index(startIndex, offsetBy: max(0, range.lowerBound), limitedBy: endIndex) else { return nil }
        guard let upperIndex = index(lowerIndex, offsetBy: range.upperBound - range.lowerBound + 1, limitedBy: endIndex) else { return nil }
        return String(self[lowerIndex..<upperIndex])
    }
    
    /// SwifterSwift: Sliced string from a start index with length.
    ///
    ///        "Hello World".slicing(from: 6, length: 5) -> "World"
    ///
    /// - Parameters:
    ///   - i: string index the slicing should start from.
    ///   - length: amount of characters to be sliced after given index.
    /// - Returns: sliced substring of length number of characters (if applicable) (example: "Hello World".slicing(from: 6, length: 5) -> "World")
    public func slicing(from i: Int, length: Int) -> String? {
        guard length >= 0, i >= 0, i < count  else { return nil }
        guard i.advanced(by: length) <= count else {
            return self[safe: i..<count]
        }
        guard length > 0 else { return "" }
        return self[safe: i..<i.advanced(by: length)]
    }
    
    // https://stackoverflow.com/a/31727051/1792699
    func slicing(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    /// SwifterSwift: Slice given string from a start index with length (if applicable).
    ///
    ///        var str = "Hello World"
    ///        str.slice(from: 6, length: 5)
    ///        print(str) // prints "World"
    ///
    /// - Parameters:
    ///   - i: string index the slicing should start from.
    ///   - length: amount of characters to be sliced after given index.
    public mutating func slice(from i: Int, length: Int) {
        if let str = self.slicing(from: i, length: length) {
            self = String(str)
        }
    }
    
    /// SwifterSwift: Slice given string from a start index to an end index (if applicable).
    ///
    ///        var str = "Hello World"
    ///        str.slice(from: 6, to: 11)
    ///        print(str) // prints "World"
    ///
    /// - Parameters:
    ///   - start: string index the slicing should start from.
    ///   - end: string index the slicing should end at.
    public mutating func slice(from start: Int, to end: Int) {
        guard end >= start else { return }
        if let str = self[safe: start..<end] {
            self = str
        }
    }
    
    /// SwifterSwift: Slice given string from a start index (if applicable).
    ///
    ///        var str = "Hello World"
    ///        str.slice(at: 6)
    ///        print(str) // prints "World"
    ///
    /// - Parameter i: string index the slicing should start from.
    public mutating func slice(at i: Int) {
        guard i < count else { return }
        if let str = self[safe: i..<count] {
            self = str
        }
    }
    
    /// SwifterSwift: Check if string starts with substring.
    ///
    ///        "hello World".starts(with: "h") -> true
    ///        "hello World".starts(with: "H", caseSensitive: false) -> true
    ///
    /// - Parameters:
    ///   - suffix: substring to search if string starts with.
    ///   - caseSensitive: set true for case sensitive search (default is true).
    /// - Returns: true if string starts with substring.
    public func starts(with prefix: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return lowercased().hasPrefix(prefix.lowercased())
        }
        return hasPrefix(prefix)
    }
    
    // Based on: https://stackoverflow.com/a/30450559/1792699
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    // Based on: https://stackoverflow.com/a/30450559/1792699
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    /// - Note: Stack Overflow: [How do I decode HTML entities in swift?](https://stackoverflow.com/a/25607542/2108547)
    func decodeHTML() -> String? {
        guard let data = self.data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else { return nil }
        return attributedString.string
    }
}

