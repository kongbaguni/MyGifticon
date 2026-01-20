//
//  AppSchema.swift
//  MyGifticon
//
//  Created by 서창열 on 1/20/26.
//
import Foundation
import SwiftData

enum AppSchemaV1 : VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [GifticonModel.self]
    }
    
    @Model
    final class GifticonModel {
        /** 기프티콘에서 추출한 문자열 */
        var title: String
        /** 사용자가 작성하는 메모 */
        var memo: String
        /** 기프티콘에서 추출한 바코드의 문자열 */
        var barcode: String
        /** 기프티콘에서 추출한 유효기간 종료일 */
        var limitDateYMD: String
        /** 기츠티콘 이미지 저장 */
        var imageData: Data
        /** 저장일시 */
        var createdAt: Date
        /** 삭제처리 Flag */
        var deleted: Bool
        /** 컬러 테그 */
        var tag: Int
        /** 참조 URL  */
        var urlString: String
        init(
            title: String,
            memo: String,
            barcode: String,
            limitDateYMD: String,
            imageData: Data,
            createdAt: Date,
            deleted: Bool,
            tag: Int,
            urlString: String
        ) {
            self.title = title
            self.memo = memo
            self.barcode = barcode
            self.limitDateYMD = limitDateYMD
            self.imageData = imageData
            self.createdAt = createdAt
            self.deleted = deleted
            self.tag = tag
            self.urlString = urlString
        }
    }
}
