//
//  MapsSampleProjectApp.swift
//  MapsSampleProject
//
//  Created by Umar Patel on 3/20/24.
//

import SwiftUI
import ARKit

@main
struct MapsSampleProjectApp: App {
    
    // @State var session = ARKitSession()
    @State var immersionState: ImmersionStyle = .mixed
    
    // State variables for moving objects
    @State var startExperience: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(startExperience: $startExperience)
        }
        
        ImmersiveSpace (id: "Volume") {
            MapExperience()
        }
        .immersionStyle(selection: $immersionState, in: .mixed)
        
        ImmersiveSpace (id: "RealityKitTutorial") {
            RealityViewTutorial(startCharacterMovement: $startExperience)
        }
        .immersionStyle(selection: $immersionState, in: .mixed)
        
    }
}
