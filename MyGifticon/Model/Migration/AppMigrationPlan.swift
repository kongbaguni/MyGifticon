//
//  AppMigrationPlan.swift
//  MyGifticon
//
//  Created by 서창열 on 1/20/26.
//
import Foundation
import SwiftData


enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [AppSchemaV1.self, AppSchemaV2.self, AppSchemaV3.self]
    }

    static var stages: [MigrationStage] {
        [
            .custom(
                fromVersion: AppSchemaV1.self,
                toVersion: AppSchemaV2.self,
                willMigrate: { context in
                    let oldArticles = try context.fetch(
                        FetchDescriptor<AppSchemaV1.GifticonModel>()
                    )

                    for old in oldArticles {
                        let new = AppSchemaV2.GifticonModel(
                            title: old.title,
                            memo: old.memo,
                            barcode: old.barcode,
                            limitDateYMD: old.limitDateYMD,
                            imageData: old.imageData,
                            createdAt: old.createdAt,
                            used: old.deleted,
                            tag: old.tag,
                            urlString: old.urlString
                        )
                        context.insert(new)
                    }
                },
                didMigrate: { context in
                    // 필요 시 정리 작업
                }
            )
            ,
            .custom(
                fromVersion: AppSchemaV2.self,
                toVersion: AppSchemaV3.self,
                willMigrate: { context in
                    
                },
                didMigrate: { context in
                    
                }
            )
        ]
    }
}
