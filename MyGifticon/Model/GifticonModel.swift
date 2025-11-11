//
//  Gifticon.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 8/19/25.
//
import UIKit
import SwiftUI
import SwiftData
import KongUIKit

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
    
    var getBrandName: String? {
        let detectedBrand = Consts.brands.first { self.contains($0) }
        return detectedBrand
    }
    
    var getBrandImage:Image? {
        if let name = self.getBrandName {
            return .init("logo_"+name)
        }
        return nil
    }
    
    var getMenuName:String? {
        var result = ""
        let newStr = self.replacingOccurrences(of: "\n", with: "")
        for list in Consts.menuKeywords {
            if result != "" {
                result += " "
            }
            if let txt = list.first(where: { newStr.contains($0) }) {
                result += txt
            }
        }
        return result.isEmpty ? nil : result
    }
}

fileprivate extension Date {
    var daysUntilNow:Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTarget = calendar.startOfDay(for: self)
        
        if let diff = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget).day {
            return max(diff, 0) // 과거 날짜면 0 반환
        } else {
            return 0
        }
    }
}

@Model
final class GifticonModel {
    static let tags : [KSelectView.Item] = [
        .init(id: 0, color: .red),
        .init(id: 1, color: .orange),
        .init(id: 2, color: .yellow),
        .init(id: 3, color: .green),
        .init(id: 4, color: .blue),
        .init(id: 5, color: .purple)
    ]

    /** 기프티콘에서 추출한 문자열 */
    var title: String = ""
    /** 사용자가 작성하는 메모 */
    var memo: String = ""
    /** 기프티콘에서 추출한 바코드의 문자열 */
    var barcode: String = ""
    /** 기프티콘에서 추출한 유효기간 종료일 */
    var limitDateYMD: String = ""
    /** 기츠티콘 이미지 저장 */
    var imageData: Data = Data()
    /** 저장일시 */
    var createdAt: Date = Date.now
    /** 삭제처리 Flag */
    var deleted: Bool = false
    /** 컬러 테그 */
    var tag: Int = 0
    
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
    
    @Transient
    var isLimitOver: Bool {
        if let limitDate = limitDate {
            return Date() > limitDate
        }
        return false
    }
    
    @Transient
    var daysUntilLimit: Int {
        if let limitDate = limitDate {
            return limitDate.daysUntilNow
        }
        return 0
    }
    
    @Transient
    var tagItem: KSelectView.Item {
        get {
            GifticonModel.tags[self.tag]
        }
    }
    
    @Transient
    var brandName: String? {
        get {
            title.getBrandName ?? memo.getBrandName
        }
    }
    
    @Transient
    var brandImage : Image {
        get {
            title.getBrandImage ?? memo.getBrandImage ?? Image("circle")
        }
    }
    
    @Transient
    var menuName: String? {
        get {
            title.getMenuName
        }
    }
    
    // Required initializer for @Model types
    init(title: String, barcode: String, limitDate: String, image: UIImage) {
        self.title = title
        self.barcode = barcode
        self.limitDateYMD = limitDate
        self.imageData = image.pngData() ?? Data()
        self.createdAt = Date()
        self.memo = ""
        if let name = title.getBrandName {
            memo += name
        }
        if let name = title.getMenuName {
            if memo.isEmpty == false {
                memo += " "
            }
            memo += name
        }
        self.deleted = false
        self.tag = 0
    }
    
}



extension GifticonModel {
    /** deleted 마크 된 기프티콘 일괄 삭제*/
    static func deleteMarkedGifticons(context: ModelContext) throws {
        let descriptor = FetchDescriptor<GifticonModel>(
            predicate: #Predicate { $0.deleted == true }
        )

        let markedGifticons = try context.fetch(descriptor)

        for gifticon in markedGifticons {
            context.delete(gifticon)
        }

        try context.save()
    }
}
