//
//  extension.swift
//  SerranoYOLO
//
//  Created by ZHONGHAO LIU on 11/25/17.
//  Copyright © 2017 Serrano. All rights reserved.
//

import UIKit
import AVFoundation
import Serrano
import CoreVideo

extension CVPixelBuffer {
    
	func tensor(attachTensor: Tensor) {
		CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags.readOnly)
		guard let baseAddres = CVPixelBufferGetBaseAddress(self) else {
			print("empyt address")
			return
		}
		let height = CVPixelBufferGetHeight(self) // 480
		let width = CVPixelBufferGetWidth(self) // 640
		let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
		CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags.readOnly)
		
        print("height: ", height)
        print("width: ", width)
		let reader = baseAddres.assumingMemoryBound(to: UInt8.self)
		
		// order kCVPixelFormatType_32BGRA
		let pixelPerRowInBuffer = width * 4
		for i in 0..<height {
			for j in 0..<width {
				for c in 0..<3 {
                    attachTensor[withoutChecking: [i, j, 2 - c]] = Float(reader[i * pixelPerRowInBuffer + j * 4 + c]) / 255.0
				}
			}
		}
        
//        for i in 0..<416 {
//            for j in 0..<416 {
//                print(attachTensor[[i,j,0]], attachTensor[[i, j, 1]], attachTensor[[i, j, 2]])
//            }
//        }
        
	}
}

// Convert CMSampleBuffer to tensor
// https://stackoverflow.com/questions/15726761/make-an-uiimage-from-a-cmsamplebuffer
extension CMSampleBuffer {
	func image(orientation: UIImageOrientation = .up, scale: CGFloat = 1.0) -> UIImage? {
		if let buffer = CMSampleBufferGetImageBuffer(self) {
			let ciImage = CIImage(cvPixelBuffer: buffer)
			return UIImage(ciImage: ciImage, scale: scale, orientation: orientation)
		}
		return nil
	}
	
	func tensor() {
		guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(self) else {
			return
		}
		
		CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
		
		guard let baseAddres = CVPixelBufferGetBaseAddress(pixelBuffer) else {
			print("empyt address")
			return
		}
		
		let height = CVPixelBufferGetHeight(pixelBuffer)
		let width = CVPixelBufferGetWidth(pixelBuffer)
		let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
		CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)

		let tensor = Tensor(repeatingValue: 0.0, tensorShape: TensorShape(dataType: .int, shape: [height, width, 3]))
		memcpy(tensor.contentsAddress, baseAddres, bytesPerRow*height)
		
	}
}


