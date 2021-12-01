//
//  ViewController.swift
//  WebSocket
//
//  Created by Coolbeans on 11/29/21.
//

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {
    
    private var locationManager = LocationManager()
    
    private let startButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Start delivery", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        locationManager.requestBackgroundLocation()
        
        closeButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.center = view.center
        
        startButton.frame = CGRect(x: 107, y: 330, width: 200, height: 50)
        view.addSubview(startButton)
        startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
    }

    
    @objc func close() {
        locationManager.stopUpdatingLocation()
    }
    
    @objc func start() {
        locationManager.requestBackgroundLocation()
    }
}

