//
//  Extenstions.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/04.
//

import Foundation
import UIKit

extension UIView {
    
    func roundCorners(cornerRadius: CGFloat,
                      maskedCorners: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = CACornerMask(arrayLiteral: maskedCorners)
    }
}

extension Date {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        return dateFormatter
    }()
    
    static func createdDateTimeToDate(_ dateString: String) -> Date {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: dateString) {
            return date
        } else {
            return Date()
        }
    }
    
}
