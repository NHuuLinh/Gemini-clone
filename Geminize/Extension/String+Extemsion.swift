//  String+Extemsion.swift
//  Geminize
//
//  Created by LinhMAC on 28/07/2024.
//

import Foundation
extension String {

  func decode() -> String {
      let data = self.data(using: .utf8)!
      return String(data: data, encoding: .nonLossyASCII) ?? self
  }

  func encode() -> String {
      let data = self.data(using: .nonLossyASCII, allowLossyConversion: true)!
      return String(data: data, encoding: .utf8)!
  }
    func stringToDate(dateFormat: String) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: self)
        return date
    }
    
}
