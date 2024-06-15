//
//  Constants.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/06/09.
//

import Foundation

class Constants {
    enum PromotionConstants {
        static let promotionValue = 500
        static let exchangePoints = 50
    }
    
    enum NFCConstants {
        static let secretKey = "123"
    }
    
    enum Connection {
        static let scheme = "http"
        static let host = "10.24.231.207"
        static let port: Int? = 9000
    }
}
