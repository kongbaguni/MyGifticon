//
//  Gifticon.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 8/19/25.
//
import UIKit
import SwiftData
fileprivate extension String {
    var dateValue:Date? {
        // 1. DateFormatter 설정
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        // 2. 문자열 → Date 변환 (자정 기준)
        guard let date = formatter.date(from: self) else {
            return nil
        }
        
        // 3. "저녁 12시 00분" = 24:00 = 다음날 0시
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        
        return calendar.date(byAdding: .day, value: 1, to: date)?
            .addingTimeInterval(0) // 선택적: 명시적 0초 추가
    }
}


@Model
final class GifticonModel {
    // Persisted properties
    var title: String
    var barcode: String
    var limitDateYMD: String
    var imageData: Data
    var createdAt: Date

    // Transient convenience accessor for UIImage
    @Transient
    var image: UIImage {
        get { UIImage(data: imageData) ?? UIImage() }
        set { imageData = newValue.pngData() ?? Data() }
    }

    @Transient
    var limitDate:Date? {
        get {
            return limitDateYMD.dateValue
        }
    }
    
    // Required initializer for @Model types
    init(title: String, barcode: String, limitDate: String, image: UIImage) {
        self.title = title
        self.barcode = barcode
        self.limitDateYMD = limitDate
        self.imageData = image.pngData() ?? Data()
        self.createdAt = Date()
    }
}
