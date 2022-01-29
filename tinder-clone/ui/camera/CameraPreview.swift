//
//  CameraPreview.swift
//  Marcianito GO
//
//  Created by Alejandro Piguave on 23/12/21.
//

import SwiftUI
import AVFoundation


struct CameraPreview: UIViewRepresentable{
    let cameraService: CameraService
    
    func makeUIView(context: Context) -> UIView {
        cameraService.setUpCamera()
        
        let view = UIView(frame: UIScreen.main.bounds)
        cameraService.previewLayer.frame = view.bounds
        
        view.layer.addSublayer(cameraService.previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    
    typealias UIViewType = UIView
}
