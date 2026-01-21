//
//  MapView.swift
//  MyGifticon
//
//  Created by 서창열 on 1/21/26.
//
import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {

    let location: CLLocation
    let title:String
    
    @State private var position: MapCameraPosition

    init(location: CLLocation, title:String) {
        self.location = location
        self.title = title
        self._position = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.01,
                        longitudeDelta: 0.01
                    )
                )
            )
        )
    }

    var body: some View {
        Map(position: $position) {
            Marker(title, coordinate: location.coordinate)
        }
        .mapStyle(.standard)
        .ignoresSafeArea(edges: .all)
    }
}

#Preview {
    MapView(location: .init(latitude: 37.7749, longitude: -122.4194),
            title: NSLocalizedString("location", comment: "test")
    )
}
