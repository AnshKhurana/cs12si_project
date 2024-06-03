//
//  RealityViewTutorial.swift
//  MapsSampleProject
//
//  Created by Umar Patel on 5/1/24.
//  Updated by Ansh Khurana on 6/2/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit
import Foundation
import AVFoundation

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
                timer = Timer.scheduledTimer(withTimeInterval: 4.05, repeats: true) { _ in
                    moveZombie(amount: 4.0, direction: currentZombieDirection)
                }
            }
        }
        
        RealityView { content in
            
            // Create an entity that will move from one side of the room to another.
            let zombieEntity = try! Entity.loadModel(named: "zombie.usdz")
            
            let zombieCharacter = ModelEntity()
            zombieCharacter.addChild(zombieEntity)
            zombieCharacter.name = "Zombie Character"
            zombieCharacter.collision = CollisionComponent(shapes: [.generateBox(width: 1.2, height: 1.2, depth: 1.2)])
            zombieCharacter.components.set(InputTargetComponent())  // This is to detect gestures on objects
            zombieCharacter.position = SIMD3<Float>(-3, 0, -7)
            rootEntity.addChild(zombieCharacter)

            // Load the gun model
            Task {
                if let gunEntity = await loadGunModel() {
                    gunEntity.name = "Gun"
                    gunEntity.position = SIMD3<Float>(0, 0.4, -1.4) // Adjust position relative to user
                    
                    gunEntity.setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: nil)
                    let rotation = simd_quatf(angle: 3 * .pi / 2, axis: SIMD3<Float>(0, 1, 0)) // Rotate 90 degrees around the Y-axis
                    gunEntity.setOrientation(rotation, relativeTo: nil)
                    rootEntity.addChild(gunEntity)
                }
            }

            content.add(rootEntity)
        }
        .onAppear {
            // Handle any additional setup when view appears
        }
        .gesture(SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                let entity = value.entity
                shoot(at: entity)
            }
        )
    }
    
    func loadGunModel() async -> ModelEntity? {
        do {
            let gunEntity = try await ModelEntity.init(named: "Walther_P88_Gun.usdz")
            return gunEntity
        } catch {
            print("Failed to load the gun model: \(error)")
            return nil
        }
    }
    
    func moveZombie(amount: Float, direction: String) {
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
        }
    }
    
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
    
    // Function to handle tap gesture
    func shoot(at entity: Entity) {
        print(entity.name)
        if entity.name == "Zombie Character" {
            print("Hit the zombie!")
            
            // Get the zombie's current position
            let zombiePosition = entity.position
            
            
            // Add muzzle flash
            if let gunEntity = rootEntity.findEntity(named: "Gun") {
               
                
//                let flash = createMuzzleFlash(pos: gunEntity.position, r: 0.2)
//                rootEntity.addChild(flash)
                let flash2 = createMuzzleFlash(pos: zombiePosition, r: 2.0)
                
                // Remove flash after a short delay
                rootEntity.addChild(flash2)
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    flash2.removeFromParent()
                }
                
                
            }
        
            
            
        }
    }
    
    // Create a muzzle flash effect
    func createMuzzleFlash(pos: SIMD3<Float>, r: Float) -> ModelEntity {
        
        print("Created muzzle flash.")
//        let flashEntity = ModelEntity(mesh: .generateSphere(radius: 0.4), materials: [SimpleMaterial(color: .orange, isMetallic: true)])
        let flashEntity =  try! ModelEntity.load(named: "Timeframe_Explosion.usdz")
        flashEntity.position = pos // Position the flash at the  gun's muzzle
        flashEntity.setScale(SIMD3<Float>(r, r, r), relativeTo: flashEntity)
        let flashE = ModelEntity()
        flashE.addChild(flashEntity)
        return flashE
    }
    
    
}

/*
#Preview {
    RealityViewTutorial(startCharacterMovement: <#Binding<Bool>#>)
}
*/

