//
//  ARSwiftUIView.swift
//  MobileBook
//
//  Created by 丁予哲 on 4/14/22.
//

import SwiftUI
import ARKit
import RealityKit
import FocusEntity

struct ARSwiftUIView: View {
    var body: some View {
        RealityKitView()
            .ignoresSafeArea()
    }
}

struct ARSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ARSwiftUIView()
    }
}

struct RealityKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let view = ARView()
        
        // Start AR session
        let session = view.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        
        // Add coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        view.addSubview(coachingOverlay)
        
        // Handle ARSession events via delegate
        context.coordinator.view = view
        session.delegate = context.coordinator
        
        // Handle taps
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleTap)
            )
        )
        
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        weak var view: ARView?
        var focusEntity: FocusEntity?

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let view = self.view else { return }
            debugPrint("Anchors added to the scene: ", anchors)
            self.focusEntity = FocusEntity(on: view, style: .classic(color: .yellow))
        }
        
        @objc func handleTap() {
            guard let view = self.view, let focusEntity = self.focusEntity else { return }

            // Create a new anchor to add content to
            let anchor = AnchorEntity()
            view.scene.anchors.append(anchor)

            // Add a book entity
            let bookEntity = try! ModelEntity.loadModel(named: "Paladins_book")
            bookEntity.scale = [0.02, 0.02, 0.02]
            bookEntity.position = focusEntity.position

            anchor.addChild(bookEntity)
        }
    }

    func updateUIView(_ view: ARView, context: Context) {
    }
}

class ARHostingController: UIHostingController<ARSwiftUIView> {

    required init?(coder: NSCoder) {
        super.init(coder: coder,rootView: ARSwiftUIView());
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // fetch data from database to get the position information
        
    }

}
