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
        [AppSchemaV1.self, AppSchemaV2.self, AppSchemaV3.self, AppSchemaV4.self]
    }
    
    static var stages: [MigrationStage] {
        [
            .lightweight(
                fromVersion: AppSchemaV1.self,
                toVersion: AppSchemaV2.self
            ),
            .lightweight(
                fromVersion: AppSchemaV2.self,
                toVersion: AppSchemaV3.self
            ),
            .lightweight(
                fromVersion: AppSchemaV3.self,
                toVersion: AppSchemaV4.self
            )
            
        ]
    }
}
