//
//  MapViewWithMultipleLocationInfo.swift
//  MyGifticon
//
//  Created by 서창열 on 1/21/26.
//
import SwiftUI
import CoreLocation
import MapKit

struct MapViewWithMultipleLocationInfo: View {
    struct Info : Hashable {
        static func == (lhs: MapViewWithMultipleLocationInfo.Info, rhs: MapViewWithMultipleLocationInfo.Info) -> Bool {
            lhs.title == rhs.title && lhs.location == rhs.location
        }
        let title: String
        let location: CLLocation
    }
    
    let infos: [Info]
    
    init(infos: [Info]) {
        self.infos = infos
        
        self._position = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: infos.last?.location.coordinate ?? CLLocation(
                        latitude: 0,
                        longitude: 0
                    ).coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.01,
                        longitudeDelta: 0.01
                    )
                )
            )
        )
        
    }
    @State private var position: MapCameraPosition

    var body: some View {
        Map(position: $position) {
            ForEach(infos, id : \.self) { item in
                Marker(item.title, coordinate: item.location.coordinate)
            }
        }
        .mapStyle(.standard)
        .ignoresSafeArea(edges: .all)
    }
}

#Preview {
    MapViewWithMultipleLocationInfo(infos: [
        .init(title: "1", location: .init(latitude: 37.7749, longitude: -122.4194)),
        .init(title: "2", location: .init(latitude: 37.7749, longitude: -122.4185)),
        .init(title: "3", location: .init(latitude: 37.7749, longitude: -122.4176)),
    ])
}
