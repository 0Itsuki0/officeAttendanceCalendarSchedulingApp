//
//  StringExtensions.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/21.
//

import UIKit

extension String {
    
    func width(font: UIFont) -> CGFloat {
        let constraintRectangle = CGSize(width: .greatestFiniteMagnitude, height: 0.0)
        let boundingBox = self.boundingRect(with: constraintRectangle, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.width)
    }
    
    var trim: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
