//
//  Utility.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/07.
//

import Foundation

class Utility {
    
    private static let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    static func randomString(_ length: Int) -> String{
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

}
