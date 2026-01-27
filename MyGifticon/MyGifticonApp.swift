//
//  MyGifticonApp.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 8/19/25.
//

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      
      MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [ "91ac842a45543bdb19f6b31decdf6240" ]
      MobileAds.shared.start()
      GoogleAdPrompt.promptWithDelay {
          
      }
    
    return true
  }
}


@main
struct MyGifticonApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([GifticonModel.self])
        let modelConfiguration = ModelConfiguration(
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .identifier("group.net.kongbaguni.mygifticon"),
            cloudKitDatabase: .private("myGifticon")
        )

        do {
            // 1. 정상적인 컨테이너 생성 시도
            return try ModelContainer(
                for: schema,
                migrationPlan: AppMigrationPlan.self,
                configurations: [modelConfiguration]
            )
        } catch {
            print("Migration failed: \(error.localizedDescription). Purging store...")
            
            // 2. 마이그레이션 실패 시 파일 삭제 로직
            let url = modelConfiguration.url
            let fileManager = FileManager.default
            // sqlite 파일과 관련 저널 파일들 삭제
            let sqliteFiles = [url, url.appendingPathExtension("shm"), url.appendingPathExtension("wal")]
            
            for fileURL in sqliteFiles {
                try? fileManager.removeItem(at: fileURL)
            }
            
            do {
                // 3. 파일 삭제 후 다시 생성 (완전히 깨끗한 상태)
                return try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
            } catch {
                // 여기서도 실패하면 정말 답이 없는 상황이므로 앱 종료 (혹은 메모리 전용으로 우회)
                fatalError("Failed to reset and create ModelContainer: \(error)")
            }
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        
    }
}

