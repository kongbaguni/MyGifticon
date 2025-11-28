//
//  TimmerView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 11/28/25.
//

import SwiftUI
import KongUIKit

extension Duration {
    var timeInterval: TimeInterval {
        let seconds = Double(self.components.seconds)
        let attoseconds = Double(self.components.attoseconds)
        return seconds + (attoseconds / 1_000_000_000_000_000_000.0)
    }
}

struct TimerView : View {
    let time: Duration
    @State var addedTime:Duration = .zero
    
    var totalTime:Duration {
        time + addedTime
    }
    
    let 시작:Date = Date()

    var 경과시간:TimeInterval {
        시작.timeIntervalSince1970 - Date().timeIntervalSince1970
    }
    
    @State var 진행율:Double = 1.0
    
    func check() {
        Task {
            진행율 = 1 - (Double(경과시간 / totalTime.timeInterval) * -1)
            if 진행율 < 0 {
                진행율 = 0
                onOver()
                return
            }
            try await Task.sleep(for: .milliseconds(250))
            check()
        }
    }
    let onOver:() -> Void
    
    func makeSafeFrameWidth(_ width:CGFloat)->CGFloat {
        let value = (width - 20) * 진행율
        if value < 0 {
            return 0
        }
        return value
    }
    
    var body: some View {
        Button {
            addedTime = addedTime + .seconds(10)
        } label: {
            GeometryReader {proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.yellow.opacity(0.2))
                        .safeGlassEffect(inShape:
                                            RoundedRectangle(cornerRadius: 10)
                        )
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.teal.opacity(0.7))
                        .frame(width: makeSafeFrameWidth(proxy.size.width - 20) , height: proxy.size.height * 0.5)
                        .safeGlassEffect(inShape:
                                            RoundedRectangle(cornerRadius: 10)
                        )
                    
                        .padding(10)
                    Text("\(Int(진행율 * 100))%")
                        .padding(.horizontal,20)
                        .font(.caption)
                        .foregroundStyle(.white)
                }
                                
            }
        }
        .onAppear {
            check()
        }.animation(.default, value: 진행율)
    }
    
}

#Preview {
    VStack {
        TimerView(time: .seconds(20)) {
            print("End")
        }
        .frame(height: 50)
        .padding()
    }
}
