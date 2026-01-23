//
//  GifticonView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 10/24/25.
//

import SwiftUI
import KongUIKit
import SwiftData
import KongUIKit
import jkdsUtility
import CoreLocation

fileprivate extension String {
    /// 문자열이 4자 이상이면 4글자씩 공백으로 구분해 반환
      var groupedBy4: String {
          let text = self.replacingOccurrences(of: " ", with: "")
          guard text.count > 4 else { return text }
          
          var result = ""
          for (index, char) in text.enumerated() {
              if index > 0 && index % 4 == 0 {
                  result.append(" ")
              }
              result.append(char)
          }
          return result
      }
}


struct GifticonView : View {
    let locationManager = LocationManager()
    
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let model: GifticonModel
    let isNew:Bool
    let isUsed:Bool
    
    @State var memo:String = ""
    @State var tagItem: KSelectView.Item? = nil
    @State var willUsed:Bool = false
    @State var willRestore:Bool = false
    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    @State var isAlert:Bool = false
    @State var location:CLLocation? = nil
    
    @State var isScheduledNotify:Bool = false
    
    func barcodeView(width: CGFloat)-> some View {
        VStack(alignment: .center) {
            KBarcodeView(text: model.barcode, conerRadius: 20)
                .blur(radius: isUsed ? 3 : 0)
                .padding(isUsed ? 5 : 0)


            HStack (alignment: .center) {
                Text(model.barcode.groupedBy4)
                    .font(.headline)
                    .foregroundStyle(.black)
                    .blur(radius: isUsed ? 3 : 0)
                
                NavigationLink {
                    Image(uiImage: model.image)
                        .resizable()
                        .scaledToFit()
                        .navigationTitle("Gifticon Image")
                    
                } label: {
                    Image(systemName: "text.rectangle.page")
                        .foregroundStyle(.teal)
                }
                
            }
            .frame(width: width > 0 ? width : 100)
            .padding(.top, -35)
        }
    }
    
    var brandImageView: some View {
        HStack {
            Spacer()
            model.brandImage
                .resizable()
                .scaledToFit()
                .frame(minHeight: 50)
            Spacer()

        }
    }
    
    var inputView : some View {
        VStack {
            if isUsed {
                Text(memo)
                    .font(.largeTitle)
            } else {
                TextField(text: $memo) {
                    Text("memo")
                }.textFieldStyle(.roundedBorder)
                KSelectView(items: GifticonModel.tags, selected: $tagItem)
            }

        }
    }
    
    var infoView: some View {
        HStack {
            Text(String(format: NSLocalizedString("until %@", comment: "까지"), model.limitDateYMD))
                .foregroundStyle(model.isLimitOver ? .red : .primary)
            Spacer()
            if model.isLimitOver {
                Text("Limit over")
                    .foregroundStyle(.red)
            }
            else {
                Text(String(format: NSLocalizedString("%d days left", comment: "%d 일 남음"), model.daysUntilLimit))
            }
        }
    }
    
    var urlView: some View {
        Group {
            if !model.urlString.isEmpty {
                Button {
                    guard let url = URL(string: model.urlString) else {
                        return
                    }
                    UIApplication.shared.open(url)
                } label: {
                    Text(model.urlString)
                        .lineLimit(1)
                }
            }
        }
    }
    
    var toggleScheduleSwitch : some View {
        Toggle(isOn: $isScheduledNotify) {
            Text("notify expired")
        }
    }
    
    var buttonView : some View {
        DirectionReader { isLandScape in
            HStack {
                Spacer()
                if isNew {
                    KImageButton(
                        image: .init(systemName: "plus"),
                        title: .init("save"),
                        style: .simple) {
                            do {
                                try modelContext.insertIfNotExists(model: model)
                                try modelContext.save()
                                UserNotificationManager.scheduleExpireNotification(for: model)
                            } catch {
                                self.error = error
                                Log
                                    .debug(
                                        "Failed to save model",
                                        error.localizedDescription
                                    )
                                return
                            }
                            dismiss()
                        }
                }
                else if isUsed {
                    if !isLandScape {
                        usedTime
                        Spacer()
                    }
                    KImageButton(
                        image: .init(systemName: "arrow.uturn.backward.circle"),
                        title: .init("restore"),
                        style: .simple) {
                            willRestore = true
                            dismiss()
                        }
                }
                else {
                    KImageButton(
                        image: .init(systemName: "checkmark.shield"),
                        title: .init("use"),
                        style: .simple) {
                            locationManager.getLocation { location in
                                self.location = location
                                self.willUsed = true
                                dismiss()
                            }
                        }
                }
            }
            .frame(height: 90)
        }
    }
    
    var mapView : some View {
        Group {
            if model.used {
                if let location = model.usedLocation {
                    MapViewWithSingleLocationInfo(
                        location: location,
                        title: NSLocalizedString("used location", comment: "기프티콘 사용 처리한 위치 표시")
                    )
                }
            }
        }
    }
    
    var usedTime : some View {
        Group {
            if let dt = model.usedDateTime {
                let str = dt
                    .formatted(
                        date: .numeric,
                        time: .standard
                    )
                Text(
                    String(format: NSLocalizedString("used date time : %@", comment: "used label"), str)
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
    var body: some View {
        GeometryReader { proxy in
            DirectionReader { isLandscape in
                if !isLandscape {
                    
                    VStack (alignment: .leading) {
                        barcodeView(width: proxy.size.width)
                            .frame(minHeight: 150)
                        
                        brandImageView
                        
                        urlView
                        inputView
                        infoView
                        
                        toggleScheduleSwitch.disabled(model.used)
                        mapView
                        Spacer()
                        buttonView
                    }
                } else {
                    HStack {
                        VStack {
                            brandImageView
                                .padding()
                            Spacer()
                        }.frame(width: 100)
                        
                        barcodeView(width: proxy.size.width - 200)
                        
                        VStack {
                            Spacer()
                            buttonView
                        }.frame(width: 80)
                        
                    }
                }
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.background)
        }
        .navigationTitle(Text("Gifticon"))
        .padding()
        .onAppear {
            memo = model.memo
            tagItem = model.tagItem
            UserNotificationManager.isRegisteredForRemoteNotifications(model: model) { isReg in
                isScheduledNotify = isReg
            }
        }
        .onDisappear {
            do {
                model.memo = memo
                model.tag = tagItem?.id ?? 0
                if isUsed {
                    model.used = willRestore ? false : true
                }
                
                else if willUsed {
                    model.used = true
                    if let location = self.location {
                        model.used_latitude = location.coordinate.latitude
                        model.used_longitude = location.coordinate.longitude
                        model.hasLocation = true
                    }
                    model.usedDateTime = .now
                }
                try modelContext.save()
                if model.used {
                    UserNotificationManager.removeScheduledNotifications(for: model)
                }
                else if isUsed == true && willUsed == false {
                    UserNotificationManager.scheduleExpireNotification(for: model)
                }
                NotificationCenter.default
                    .post(name: .didChangeUsedGifticon, object: model.used)
            } catch {
                Log.debug("Failed to save model: \(error)")
            }
        }
        .alert(isPresented: $isAlert) {
            return .init(title: .init("alert"), message: .init(error?.localizedDescription ?? ""))
        }
        .onChange(of: isScheduledNotify) { oldValue, newValue in
            if newValue {
                UserNotificationManager.scheduleExpireNotification(for: model)
            } else {
                UserNotificationManager.removeScheduledNotifications(for: model)
            }
        }

    }
}

#Preview {
    GifticonView(model: .init(title: "투썸플레이스 치즈케이크 test", barcode: "124312", limitDate: "2026.04.04", image: .init(systemName: "circle")!), isNew: true, isUsed: false)
    
    
}
