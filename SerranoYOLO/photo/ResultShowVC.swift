//
//  ResultShowVC.swift
//  SerranoYOLO
//
//  Created by ZHONGHAO LIU on 12/1/17.
//  Copyright © 2017 Serrano. All rights reserved.
//

import UIKit
import Serrano

struct ARGBPixel {
    var Alpha: UInt8 = 255
    var Red:   UInt8 = 0
    var Green: UInt8 = 0
    var Blue:  UInt8 = 0
}

class ResultShowVC: UIViewController {

    @IBOutlet var doneButton: UIButton!
    @IBOutlet var imageShowView: UIView!
    
    public var rgbTensor: Tensor?
    public var boxes: [BoundingBox]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton.addTarget(self, action: #selector(doneButtonTouched), for: UIControlEvents.touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let image = constructImage()
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0,
                                                  width: self.imageShowView.bounds.height,
                                                  height: self.imageShowView.bounds.height))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        self.imageShowView.insertSubview(imageView, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.plotBoxes(self.boxes!)
    }
    
    func doneButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func constructImage() -> UIImage {
        var pixel = [ARGBPixel]()
        for i in 0..<416 {
            for j in 0..<416 {
                pixel.append(ARGBPixel(Alpha: 255,
                                       Red: UInt8(rgbTensor![i, j, 0] * 255),
                                       Green: UInt8(rgbTensor![i, j, 1] * 255),
                                       Blue: UInt8(rgbTensor![i, j, 2] * 255)))
            }
        }
        
        let image =  imageFromARGB32Bitmap(pixels:pixel, width: 416, height: 416)
       
        return image
    }
    
    //https://stackoverflow.com/questions/30958427/pixel-array-to-uiimage-in-swift
    func imageFromARGB32Bitmap(pixels:[ARGBPixel], width: Int, height: Int)-> UIImage {
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        
        assert(pixels.count == width * height)
        
        var data = pixels // Copy to mutable []
        let providerRef = CGDataProvider(
            data: NSData(bytes: &data, length: data.count * MemoryLayout<ARGBPixel>.size)
        )
        
        let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * Int(MemoryLayout<ARGBPixel>.size),
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent)
        return UIImage(cgImage: cgim!)
    }
    
    func plotBoxes(_ boxes: [BoundingBox]) {
//        let scale = CGFloat(self.imageShowView.bounds.height / 416.0)
        let scale = CGFloat(1.0)
        let layer = self.imageShowView.layer
        for box in boxes {
            var rect = CGRect(x: CGFloat(box.x-box.w/2), y: CGFloat(box.y-box.h/2),
                              width: CGFloat(box.w), height: CGFloat(box.h))
            rect.origin.x *= scale
            rect.origin.x = max(0.0, rect.origin.x)
            
            rect.origin.y *= scale
            rect.origin.y = max(0.0, rect.origin.y)
            
            rect.size.width *= scale
            rect.size.height *= scale
            
            print("rect", rect, "label", box.label)
            box.show(frame: rect, color: UIColor.yellow)
            box.addToLayer(layer)
        }
    }

}
