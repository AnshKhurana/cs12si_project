//
//  MapExperience.swift
//  MapsSampleProject
//
//  Created by Umar Patel on 3/20/24.
//

import SwiftUI
import RealityKit
import ARKit


struct MapExperience: View {
    
    let arSession = ARKitSession()
    let planeData = PlaneDetectionProvider(alignments: [.horizontal, .vertical])
    
    @State var planeAnchors: [UUID:PlaneAnchor] = [:]
    @State var entityMap: [UUID:Entity] = [:]
    
    // Root Entity to attach all
    let rootEntity = Entity()
    
    // For handtracking
    let handTracking = HandTrackingProvider()
    
    
    
    var body: some View {
        RealityView { content in
            // Load model
            
            let model = ModelEntity(
                mesh: .generateSphere(radius: 1),
                materials: [SimpleMaterial(color: .blue, isMetallic: false)]
                
            )
            model.name = "sample sphere"
            model.collision = CollisionComponent(shapes: [.generateSphere(radius: 1)])
            // You might want to set the component (kind of like furniture when you were doing Environment or furniture component.
            model.position = SIMD3<Float>(0, 1, -3)
            
            rootEntity.addChild(model)
            content.add(rootEntity)
            
            /*
            Task {
                try await arSession.run([planeData, handTracking])
                
                for await update in planeData.anchorUpdates {
                    if update.anchor.classification == .window {
                        continue
                    }
                    switch update.event {
                    case .added, .updated:  // Maybe put await here if it doesn't work
                        updatePlane(update.anchor)
                    case .removed:
                        removePlane(update.anchor)  // Maybe put await here if it doesn't work.
                    }
                    
                }
                
            }
             */
            
            /*
            if let MapEntity = try? await Entity(named: "toy_biplane_idle") {
                content.add(MapEntity)
            }
            */
            // Add entity to RealityView
            
            
            
           
            
        }
        .onDisappear {
            arSession.stop()
        }
    }
    
    // Add update plane and remove plane functions
    
    @MainActor
    func updatePlane(_ anchor: PlaneAnchor) {
        if planeAnchors[anchor.id] == nil {
                // Add a new entity to represent this plane.
                let entity = ModelEntity(mesh: .generateText(anchor.classification.description))
                entityMap[anchor.id] = entity
                rootEntity.addChild(entity)
            }
            
            entityMap[anchor.id]?.transform = Transform(matrix: anchor.originFromAnchorTransform)
    }
    
    @MainActor
    func removePlane(_ anchor: PlaneAnchor) {
        entityMap[anchor.id]?.removeFromParent()
        entityMap.removeValue(forKey: anchor.id)
        planeAnchors.removeValue(forKey: anchor.id)
    }
}

#Preview {
    MapExperience()
}
