//
//  LocationManager.swift
//  sudodal
//
//  Created by 서창열 on 12/3/25.
//


import Foundation
import Combine
import CoreLocation
/**
 위치정부 구하는 클래스
 */
final class LocationManager: NSObject {
    private var manager:CLLocationManager? = nil
    
    private var didUpdateLocation:(CLLocation?)->Void = { _ in }
    private var didUpdateAuthorization:(CLAuthorizationStatus)->Void = { _ in }
    private var reportCount = 0
    
    func initManager() {
        manager = CLLocationManager()
        manager?.delegate = self
    }
    
    func requestAuthorization(callback:@escaping(CLAuthorizationStatus)->Void) {
        guard let manager = manager else {
            initManager()
            requestAuthorization(callback: callback)
            return
        }
        switch manager.authorizationStatus {
        case .notDetermined:
            self.didUpdateAuthorization = callback
            manager.requestWhenInUseAuthorization()
        default:
            callback(manager.authorizationStatus)
            break
        }
    }
    
    func getLocation(callback:@escaping(CLLocation?)->Void) {
        guard let manager = manager else {
            initManager()
            getLocation(callback: callback)
            return
        }
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            didUpdateLocation = callback
            reportCount = 0
            manager.startUpdatingLocation()
        case .notDetermined:
            requestAuthorization { [weak self] status in
                self?.getLocation(callback: callback)
            }
        default:
            callback(nil)
        }
    }
}

extension LocationManager : CLLocationManagerDelegate {
    // 권한 변경 감지
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            getLocation(callback: didUpdateLocation)
        }
        didUpdateAuthorization(status)
    }

    // 위치 업데이트
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        guard reportCount == 0 else {
            manager.stopUpdatingLocation()
            return
        }
        didUpdateLocation(location)
        reportCount += 1
    }
    
    // 위치 업데이트 실패 처리
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed:", error.localizedDescription)
    }
}
