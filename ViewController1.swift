//
//  ViewController1.swift
//  TestVisionML
//
//  Created by zz on 2023/5/5.
//

import UIKit
import Photos
import PhotosUI
import CoreML
import Vision

extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: .init(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self
    }
}

extension UIImageView : NSSecureCoding {
    public static var supportsSecureCoding: Bool {
        false
    }
}

class ViewController1: UIViewController {
    public var isQian = true
    let imageView = UIImageView()
    let image = UIImage(named: "elang")!
    lazy var request = VNCoreMLRequest(model: try! VNCoreMLModel(for: self.model.model)) { [unowned self] request, error in
        if let results = request.results as? [VNCoreMLFeatureValueObservation] {
            if let feature = results.first?.featureValue, let arrayValue = feature.multiArrayValue {
                let width = arrayValue.shape[0].intValue
                let height = arrayValue.shape[1].intValue
                let stride = arrayValue.strides[0].intValue
                let components = 4
                var bitmapData1 = Data(count: arrayValue.count * components)
                var bitmapData2 = Data(count: arrayValue.count * components)
                for var i in 0..<width {
                    for var j in 0..<height {
                        let label = arrayValue[j * stride + i].intValue
                        switch label {
                        case 0:
                            bitmapData1[j * stride * components + i * components + 0] = 0x0
                            bitmapData1[j * stride * components + i * components + 1] = 0x0
                            bitmapData1[j * stride * components + i * components + 2] = 0x0
                            if (self.isQian) {
                                bitmapData1[j * stride * components + i * components + 3] = 0x0
                            } else {
                                bitmapData1[j * stride * components + i * components + 3] = 0xff
                            }
                            
                        default:
                            bitmapData1[j * stride * components + i * components + 0] = 0x0
                            bitmapData1[j * stride * components + i * components + 1] = 0x0
                            bitmapData1[j * stride * components + i * components + 2] = 0x0
                            if (self.isQian) {
                                bitmapData1[j * stride * components + i * components + 3] = 0xff
                            } else {
                                bitmapData1[j * stride * components + i * components + 3] = 0x0
                            }
                           
                        }
                    }
                }
                let bitmapImage1 = CGImage(width: width,
                                          height: height,
                                          bitsPerComponent: 8,
                                          bitsPerPixel: 8 * components,
                                          bytesPerRow: width * components,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: .init(rawValue: CGImageAlphaInfo.last.rawValue),
                                          provider: .init(data: bitmapData1 as CFData)!,
                                          decode: nil,
                                          shouldInterpolate: false,
                                          intent: .defaultIntent)
                let image1 = UIImage(cgImage: bitmapImage1!).resize(to: self.imageSize)
                DispatchQueue.main.async {
                    self.maskImage = image1
                }
            }
            
        }
    }
    lazy var model = try! DeepLabV3(configuration: {
        let config = MLModelConfiguration()
        config.allowLowPrecisionAccumulationOnGPU = true
        config.computeUnits = .cpuAndGPU
        return config
    }())
    
    var imageSize: CGSize = .zero
    var maskImage: UIImage? {
        didSet {
            replicateView = UIImageView(image: self.imageView.image)
            let mask = UIImageView(image: maskImage)
            mask.contentMode = .scaleAspectFill
            mask.frame = self.imageView.bounds
            replicateView?.mask = mask
        }
    }
    var replicateView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let view = replicateView {
                view.frame = self.imageView.bounds
                view.contentMode = self.imageView.contentMode
                self.view.addSubview(view)
            }
        }
    }
    
    init() {
            super.init(nibName: nil, bundle: nil)
        }
    
    required init(leftViewController: UIViewController, contentViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.imageView.frame = self.view.bounds
        self.imageView.image = UIImage(named: "elang")
        self.imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageSize = image.size
        DispatchQueue.global().async { [unowned self] in
            self.request.imageCropAndScaleOption = .scaleFill
            let handler = VNImageRequestHandler(cgImage: image.cgImage!)
            try? handler.perform([self.request])
        }
    }
}
