//
//  ViewController.swift
//  TestVisionML
//
//  Created by zz on 2023/5/5.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.image = UIImage(named: "elang")
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.addSubview(imageView)
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        button.backgroundColor = UIColor.red
        button.setTitle("前景", for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonAction1), for: UIControl.Event.touchUpInside)
        self.view.addSubview(button)
        
        let button2 = UIButton(frame: CGRect(x: 100, y: 300, width: 100, height: 100))
        button2.backgroundColor = UIColor.red
        button2.setTitle("背景", for: UIControl.State.normal)
        self.view.addSubview(button2)
        button2.addTarget(self, action: #selector(buttonAction2), for: UIControl.Event.touchUpInside)
    }
}

extension ViewController {
    @objc private func buttonAction1() {
        let controller = ViewController1()
        controller.isQian = true
        self.present(controller, animated: true)
    }
    
    @objc private func buttonAction2() {
        let controller = ViewController1()
        controller.isQian = false
        self.present(controller, animated: true)
    }
}

