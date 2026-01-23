//
//  UserNotificationManager.swift
//  MyGifticon
//
//  Created by 서창열 on 1/23/26.
//

import UserNotifications

struct UserNotificationManager {
    static func requestNotificationPermission(complete:@escaping(Bool, Error?)->Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            Task { @MainActor in
                complete(granted, error)
            }
        }
    }
    
    static func scheduleExpireNotification(model: GifticonModel) {
        for idx in 1...3 {
            scheduleExpireNotification(model: model, daysBefore: idx)
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

        // 과거 방지
        guard let triggerDate = Calendar.current.date(from: components),
              triggerDate > Date.now
        else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "기프트콘 만료 알림"
        content.body = "\(model.memo) 기프트콘이 \(daysBefore)일 후 만료됩니다."
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
