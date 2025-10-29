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
        let brands: [String] = [
            "스타벅스",
            "투썸플레이스",
            "이디야커피",
            "메가커피",
            "파스쿠찌",
            "파리바게뜨",
            "뚜레쥬르",
            "배스킨라빈스",
            "던킨",
            "맥도날드",
            "롯데리아",
            "버거킹",
            "맘스터치",
            "교촌치킨",
            "BHC치킨",
            "BBQ",
            "굽네치킨",
            "네네치킨",
            "피자헛",
            "도미노피자",
            "미스터피자",
            "파파존스",
            "서브웨이",
            "올리브영",
            "GS25",
            "CU",
            "세븐일레븐",
            "미니스톱",
            "이마트24",
            "커피빈",
            "탐앤탐스",
            "할리스커피",
            "엔제리너스",
            "빽다방",
            "공차",
            "이삭토스트",
            "한스케익",
            "크리스피크림",
            "카페베네",
            "폴바셋",
            "이마트",
            "다이소",
            "홈플러스",
        ]
        
        let detectedBrand = brands.first { self.contains($0) }
        return detectedBrand
    }
    
    var getMenuName:String? {
        let menuKeywords: [String] = [
            // ☕️ 커피 & 음료
            "아메리카노",
            "카페라떼",
            "바닐라라떼",
            "카라멜마끼아또",
            "카푸치노",
            "에스프레소",
            "플랫화이트",
            "콜드브루",
            "돌체라떼",
            "오트라떼",
            "디카페인아메리카노",
            "헤이즐넛라떼",
            "민트초코라떼",
            "초코라떼",
            "녹차라떼",
            "홍차라떼",
            "밀크티",
            "복숭아아이스티",
            "유자차",
            "레몬티",
            "스무디",
            "요거트스무디",
            "프라푸치노",
            "딸기라떼",
            "딸기요거트",
            "아이스아메리카노",
            "아이스라떼",
            "아이스바닐라라떼",
            "아이스티",
            "핫초코",

            // 🍰 디저트 & 베이커리
            "치즈케이크",
            "뉴욕치즈케이크",
            "초코케이크",
            "생크림케이크",
            "조각케이크",
            "티라미수",
            "마카롱",
            "쿠키",
            "스콘",
            "머핀",
            "도넛",
            "글레이즈드도넛",
            "초코도넛",
            "잼도넛",
            "크루아상",
            "샌드위치",
            "햄치즈샌드위치",
            "베이컨에그머핀",
            "불고기버거세트",
            "치즈버거세트",
            "더블불고기버거세트",
            "빅맥세트",
            "1955버거세트",
            "새우버거세트",
            "통새우버거세트",
            "와퍼세트",
            "기네스와퍼세트",
            "싸이순살버거세트",
            "맘스터치싸이버거세트",
            "치킨버거세트",
            "핫크리스피치킨버거세트",
            "맥스파이시상하이세트",
            "불고기버거단품",
            "햄버거단품",

            // 🍗 치킨
            "후라이드치킨",
            "양념치킨",
            "간장치킨",
            "마늘치킨",
            "뿌링클",
            "허니콤보",
            "황금올리브치킨",
            "고추바사삭",
            "크리스피치킨",
            "치킨무",
            "콜라1.25L",
            "사이다1.25L",

            // 🍕 피자
            "페퍼로니피자",
            "콤비네이션피자",
            "불고기피자",
            "포테이토피자",
            "치즈피자",
            "슈퍼디럭스피자",
            "골드포테이토피자",
            "핫치킨피자",

            // 🍦 아이스크림
            "싱글레귤러",
            "더블주니어",
            "파인트",
            "쿼터",
            "패밀리",
            "하프갤런",
            "컵아이스크림",
            "콘아이스크림",
            "아이스케이크",

            // 🏪 편의점 / 상품권
            "1만원 교환권",
            "2만원 교환권",
            "5만원 교환권",
            "10만원 교환권",
            "교환권 1,000원권",
            "교환권 3,000원권",
            "교환권 5,000원권",
            "교환권 10,000원권",
            "모바일상품권 10,000원권",
            "모바일상품권 20,000원권",
            "모바일상품권 30,000원권",
            "모바일금액권 50,000원권",
            "편의점상품권",
            "기프트카드",
            "문화상품권",
            "해피머니",
            "컬쳐캐쉬"
        ]
        let detectedMenu = menuKeywords.first { self.contains($0) }
        return detectedMenu
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
    var imageData: Data
    /** 저장일시 */
    var createdAt: Date
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
            title.getBrandName
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
