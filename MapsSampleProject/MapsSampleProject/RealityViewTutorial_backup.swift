//
//  RealityViewTutorial.swift
//  MapsSampleProject
//
//  Created by Umar Patel on 5/1/24.
//  Updated by Ansh Khurana 6/2/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit
import Foundation

// Note on SIMD3
// (x, y, z)
// x is left and right in the simulator and in world space (left is negative, right is positive)
// y is up and down (up is positive, down is negative)
// z is forward and back (forward is negative, back is positive). 


struct RealityViewTutorial: View {
    @Binding var startCharacterMovement: Bool   // This is basically to start the movement of the zombie and the entire experience
    
    // Create ARSession for plane detection for this ImmersiveSpace
    let arSession = ARKitSession()
    let planeData = PlaneDetectionProvider(alignments: [.horizontal, .vertical])
    
    @State var planeAnchors: [UUID:PlaneAnchor] = [:]
    @State var entityMap: [UUID:Entity] = [:]
    
    let handTracking = HandTrackingProvider()
    
    let rootEntity = Entity()
    
    // Create an animation controller
    @State var zombieAnimation: AnimationPlaybackController?
    @State var currentZombieDirection: String = "right"
    @State var animationStarted: Bool = false
    
    
    @State var timer: Timer?
    
    var body: some View {
        VStack {
            Text("")
        }
        .onChange(of: startCharacterMovement) {
            if startCharacterMovement {
                if startCharacterMovement {
                    timer = Timer.scheduledTimer(withTimeInterval: 4.05, repeats: true) { _ in
                        moveZombie(amount: 4.0, direction: currentZombieDirection)
                    }
                }
            }
        }
        
        RealityView { content in
            
            // Create an entity that will move from one side of the room to another.
            let zombieEntity = try! Entity.loadModel(named: "zombie.usdz")
            
//            let zombieCharacter = ModelEntity(
//                mesh:.generateCylinder(height: 1, radius: 0.4),
//                materials: 
//                    [SimpleMaterial(color: .blue, isMetallic: false)]
//            )
                
//           let's load a real zombie
            
            let zombieCharacter = ModelEntity()
                zombieCharacter.addChild(zombieEntity)

            
            zombieCharacter.name = "Zombie Character"
            
            zombieCharacter.collision = CollisionComponent(shapes: [.generateBox(width: 0.8, height: 1.0, depth: 0.8)])
            
            zombieCharacter.components.set(InputTargetComponent())  // This is to detect gestures on objects
            
            zombieCharacter.position = SIMD3<Float>(-3, 0.1, -3)
            
            rootEntity.addChild(zombieCharacter)

            content.add(rootEntity)

        }
        .onAppear {
            // Start the zombie animation (going right)
            // moveZombie(amount: 4.0, direction: "right")
            // print("London")
            
        }
        .gesture(SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded({ value in
                print(rootEntity)
                // moveZombie(amount: 4.0, direction: currentZombieDirection)
                print("currentZombieDirection")
            })
        )
        
        
        
    }
    
    /*
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 4.05, repeats: true) { _ in
            moveZombie(amount: 4.0, direction: currentZombieDirection)
        }
    }
    */
    
    func moveZombie(amount: Float, direction: String) {
        // Access the Zombie Character entity and then move it
        // Access through root child
        print("Manchester")
        if let zombieCharacter = findEntityByName(named: "Zombie Character", in: rootEntity) {
            let currentTransform = zombieCharacter.transform.matrix
            print("Dover")
            
            var newTransform = currentTransform
            
            if direction == "right" {
                newTransform.columns.3.x += amount
                currentZombieDirection = "back"
            }
            else if direction == "back" {
                newTransform.columns.3.z += amount
                currentZombieDirection = "left"

            }
            else if direction == "left" {
                newTransform.columns.3.x -= amount
                currentZombieDirection = "forward"
            }
            else if direction == "forward" {
                newTransform.columns.3.z -= amount
                currentZombieDirection = "right"
            }
            
            
            zombieAnimation = zombieCharacter.move(
                to: newTransform,
                relativeTo: nil,
                duration: 4.0,
                timingFunction: .easeInOut
            )
            print("Notting Hill")
            print(zombieAnimation!.duration)
            
            // Run this function again? It will only stop when
            
                    
        }
    }
    
    
    
    /*
     This function finds an entity in the scene by name.
     */
    func findEntityByName(named targetName: String, in rootEntity: Entity) -> Entity? {
        var stack = [Entity]()
        stack.append(rootEntity)
        print(rootEntity.children)
        
        while !stack.isEmpty {
            let current = stack.removeLast()
            
            if current.name == targetName {
                print("Liverpool")
                return current
            }
            
            stack.append(contentsOf: current.children)
        }
        
        
        return nil
    }
    
}


/*
#Preview {
    RealityViewTutorial(startCharacterMovement: <#Binding<Bool>#>)
}
*/
