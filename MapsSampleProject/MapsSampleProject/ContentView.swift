//
//  ContentView.swift
//  MapsSampleProject
//
//  Created by Umar Patel on 3/20/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    // Specific to VisionPro (this is to actually open a window or immersive space
    @Environment(\.openWindow) var openWindow
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    
    
    // Create State variables to indicate which immersive space is open. Also ensures only one is open at a single time.
    // Only one or none will ever be open at a single time
    
    // There are three combinations of possible states:
    // Both off
    // 1 is on, 2 is off
    // 1 is off, 2 is on
    @State var ImmersiveSpace1Toggle: Bool = false
    @State var ImmersiveSpace2Toggle: Bool = false
    
    @State var DebugText: String = "Choose an Immersive Space to Enter!"
    
    // For starting to move the character from one part of the room to another
    
    @Binding var startExperience: Bool
    @State var experienceButtonTitle: String = "Start Experience"
    
    var body: some View {
        ZStack {
            
            // Map Image
            Image("Turgot Map")
                .resizable()
                .scaledToFill()
            // Button
            VStack {
                Button {
                    // Do something
                    
                    // If 1 is not open and 2 is not open
                
                    Task {
                        if (!ImmersiveSpace1Toggle && !ImmersiveSpace2Toggle) {
                            await openImmersiveSpace(id: "Volume")
                            ImmersiveSpace1Toggle.toggle()
                        }
                        else if (ImmersiveSpace1Toggle && !ImmersiveSpace2Toggle) {
                            await dismissImmersiveSpace()
                            ImmersiveSpace1Toggle.toggle()
                        }
                        else if (!ImmersiveSpace1Toggle && ImmersiveSpace2Toggle) {
                            // Cannot have two immersive spaces open at the same time
                            // Display text here explaining that you cannot have two immersive spaces open at once
                            DebugText = "Can only have 1 immersive space open at once. Please close the current Immersive space before opening a new one."
                        }
                        
                    }
                    } label: {
                        Image(systemName: "visionpro")
                        Text("Immersive Space 1")
                    }
                    
                    
                
                Button {
                    Task {
                        
                        if (!ImmersiveSpace1Toggle && !ImmersiveSpace2Toggle) {
                            await openImmersiveSpace(id: "RealityKitTutorial")
                            ImmersiveSpace2Toggle.toggle()
                        }
                        else if (!ImmersiveSpace1Toggle && ImmersiveSpace2Toggle) {
                            await dismissImmersiveSpace()
                            ImmersiveSpace2Toggle.toggle()
                        }
                        else if (ImmersiveSpace1Toggle && !ImmersiveSpace2Toggle) {
                            // Cannot have two immersive spaces open at the same time
                            // Display text here explaining that you cannot have two immersive spaces open at once
                            DebugText = "Can only have 1 immersive space open at once. Please close the current Immersive space before opening a new one."
                        }
                        
                    }
                } label: {
                    Image(systemName: "visionpro")
                    Text("Immersive Space 2")
                }
                
                Button(experienceButtonTitle) {
                    if !startExperience {
                        experienceButtonTitle = "Stop Experience"
                    } else {
                        experienceButtonTitle = "Start Experience"
                    }
                    startExperience.toggle()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Text(DebugText)
                    .padding()
                    .font(.extraLargeTitle)
                    .bold()
                
                Text("The current value of startExperience is \(startExperience)")
                    
            }
            
        }
    }
}

/*
#Preview(windowStyle: .automatic) {
    ContentView()
}
*/
