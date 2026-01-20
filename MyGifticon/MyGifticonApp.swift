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
        do {
            let modelConfiguration = ModelConfiguration(
                isStoredInMemoryOnly: false,
                allowsSave: true,
                groupContainer: .identifier("group.net.kongbaguni.mygifticon"),
                cloudKitDatabase: .private("myGifticon")
            )

            let schema = Schema([GifticonModel.self])
            return try ModelContainer(
                for: schema,
                migrationPlan: AppMigrationPlan.self,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        
    }
}

