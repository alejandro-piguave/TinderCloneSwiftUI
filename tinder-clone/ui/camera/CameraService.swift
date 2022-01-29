//
//  CameraModel.swift
//  Marcianito GO
//
//  Created by Alejandro Piguave on 23/12/21.
//

import Foundation
import AVFoundation

class CameraService: ObservableObject{
    var session: AVCaptureSession?
    
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    func setUpCamera(){
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video){
            do{
                let input = try AVCaptureDeviceInput(device: device)
                if(session.canAddInput(input)){
                    session.addInput(input)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                
                session.startRunning()
                self.session = session
            }catch{
                print(error)
            }
        }
    }
}
