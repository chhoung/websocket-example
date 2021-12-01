//
//  ViewController.swift
//  WebSocketListener
//
//  Created by Coolbeans on 11/29/21.
//

import UIKit

class ViewController: UIViewController {

    private lazy var webSocketManager = WebSocketManager()
    private let listenButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Receive driver location", for: .normal)
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
        view.backgroundColor = .cyan
        webSocketManager.initiateConnection()
        
        closeButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.center = view.center
        
        listenButton.frame = CGRect(x: 107, y: 330, width: 200, height: 50)
        view.addSubview(listenButton)
        listenButton.addTarget(self, action: #selector(listen), for: .touchUpInside)
    }

    
    @objc func close() {
        webSocketManager.close()
    }
    
    @objc func listen() {
        webSocketManager.initiateConnection()
    }
    
}

