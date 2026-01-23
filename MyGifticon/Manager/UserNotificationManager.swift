//
//  UserNotificationManager.swift
//  MyGifticon
//
//  Created by 서창열 on 1/23/26.
//

import UserNotifications
import jkdsUtility

struct UserNotificationManager {
    fileprivate static func requestNotificationPermission(complete:@escaping(Bool, Error?)->Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            Task { @MainActor in
                complete(granted, error)
            }
        }
    }
    
    fileprivate static func checkPendingNotifications() {
#if DEBUG
        UNUserNotificationCenter.current()
            .getPendingNotificationRequests { requests in
                print("📬 Pending notifications count:", requests.count)

                for req in requests {
                    print(
                    """
                    notification 등록
                    🔔 id: \(req.identifier)
                    ⏰ trigger: \(String(describing: req.trigger))
                    📄 title: \(req.content.title)
                    📝 body: \(req.content.body)
                    """)
                }
            }
#endif
    }
    
    fileprivate static func isRegisteredForRemoteNotifications(model: GifticonModel, complete:@escaping(Bool)->Void){
#if DEBUG
        complete(false)
#else
        let barcode = model.barcode
        UNUserNotificationCenter.current()
            .getPendingNotificationRequests { requests in
                let identifiers = requests
                    .filter { $0.identifier.contains("gifticon_\(barcode)_") }
                    .map { $0.identifier }
                complete(identifiers.count > 0)
            }
        
#endif
    }
    
    
    static func scheduleExpireNotification(model: GifticonModel) {
        UserNotificationManager.requestNotificationPermission { granted, error in
            if granted {
                isRegisteredForRemoteNotifications(model: model) { isRegistered in
                    if !isRegistered {
                        for idx in 1...3 {
                            scheduleExpireNotification(model: model, daysBefore: idx)
                        }
                        checkPendingNotifications()
                    }
                }
            }
        }
    }
    
    fileprivate static func scheduleExpireNotification(model: GifticonModel, daysBefore: Int) {
        guard let limitDate = model.limitDate,
              let baseDate = Calendar.current.date(
                  byAdding: .day,
                  value: -daysBefore,
                  to: limitDate
              )
        else {
            return
        }

        // 날짜 컴포넌트만 추출
        var components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: baseDate
        )

        // 🔥 점심시간 
        components.hour = 12
        components.minute = 0
        components.second = 0
#if DEBUG
        components.hour = Calendar.current.component(.hour, from: Date())
        components.minute = Calendar.current.component(.minute, from: Date()) + 1
#endif

        // 과거 방지
        guard let triggerDate = Calendar.current.date(from: components),
              triggerDate > Date.now
        else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Gifticon Expire Alert", comment: "gifticon notitication")
        switch daysBefore {
        case 1:
            content.body = model.memo
                .trimmingCharacters(in: .whitespacesAndNewlines) + " " +
            NSLocalizedString(
                "The Gifticon is Expire Today",
                comment: "gifticion notification"
            )
        default:
            content.body = model.memo.trimmingCharacters(in: .whitespacesAndNewlines) + " " +
            String(format:
                    NSLocalizedString(
                        "The Gifticon expires in %d days",
                        comment: "gifticion notification"
                    ), daysBefore)

        }
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let identifier = "gifticon_\(model.barcode)_\(daysBefore)"

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
     
        Log
            .debug(
                "notification 등록",
                model.memo,
                model.limitDateYMD,
                daysBefore,
                triggerDate
            )
    }
    
    static func removeScheduledNotifications(for model: GifticonModel) {
        let barcode = model.barcode

        UNUserNotificationCenter.current()
            .getPendingNotificationRequests { requests in
                let identifiers = requests
                    .filter { $0.identifier.contains("gifticon_\(barcode)_") }
                    .map { $0.identifier }

                if !identifiers.isEmpty {
                    UNUserNotificationCenter.current()
                        .removePendingNotificationRequests(withIdentifiers: identifiers)
                }
            }
    }
}
