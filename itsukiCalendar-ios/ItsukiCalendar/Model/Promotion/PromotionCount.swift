//
//  PromotionCount.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/04.
//

import Foundation


struct PromotionCount: Codable {
    var amazon: Int
    var apple: Int
    var googlePlay: Int
    var nintendo: Int
    
    init() {
        self.amazon = 0
        self.apple = 0
        self.googlePlay = 0
        self.nintendo = 0
    }
    
    func count(_ type: PromotionType) -> Int {
        switch type {
        case .amazon:
            self.amazon
        case .apple:
            self.apple
        case .googlePlay:
            self.googlePlay
        case .nintendo:
            self.nintendo
        }
    }
}

