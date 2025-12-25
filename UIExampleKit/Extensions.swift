//
//  Extensions.swift
//  UIExampleKit
//
//  Created by Aditya Sharma on 11/12/25.
//
import UIKit

extension UIColor {
    // HEX initializer
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    // 🎨 App Colors
    static let appLight       = UIColor(hex: "#FF9B99")  // light
    static let appDark        = UIColor(hex: "#FF6578")  // dark
    static let lightGray      = UIColor(hex: "#F5F5F5") //
    static let appText        = UIColor(hex: "#212121")
    static let appBackground  = UIColor(hex: "#FFEDED")
}
