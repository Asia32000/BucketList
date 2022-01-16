//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Joanna Staleńczyk on 15/01/2022.
//

import Foundation
import MapKit
import LocalAuthentication

extension ContentView {
    
    @MainActor class ViewModel: ObservableObject {
        @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        @Published private(set) var locations: [Location]
        @Published var selectedLocation: Location?
        @Published var isUnlocked = false
        @Published var authFailed = false
        @Published var errorMEssage = "Unknown error"
        
        let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        
        func addLocation() {
            let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
            locations.append(newLocation)
            save()
        }
        
        func updateLocation(location: Location) {
            guard let selectedLocation = selectedLocation else { return }
            
            if let index = locations.firstIndex(of: selectedLocation) {
                locations[index] = location
                save()
            }
        }
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, autheticationError in
                    Task { @MainActor in
                        if success {
                            self.isUnlocked = true
                        } else {
                            self.errorMEssage = "There was a problem authenticating you; please try again."
                            self.authFailed = true
                        }
                    }
                }
            } else {
                self.errorMEssage = "Sorry, your device does not support biometric authentication."
                self.authFailed = true
            }
        }
    }
}

