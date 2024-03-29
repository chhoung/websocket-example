//
//  WebSocketManager.swift
//  WebSocket
//
//

import Foundation
import CoreLocation

final class WebSocketManager: NSObject {
    private var webSocket: URLSessionWebSocketTask?
    
    //add websocket url here
    private let url = URL(string: "wss://")
    private var session: URLSession?
    
    func initiateConnection() {
        session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        
        guard webSocket?.state != .running else {
            print("a connection has been astablished")
            return }
        webSocket = session?.webSocketTask(with: url!)
        webSocket?.resume()
    }
    
    private func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        })
    }
    
    func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    
    func send(location: CLLocationCoordinate2D) {
        self.webSocket?.send(.string("Send new coordinate: lat: \(location.latitude), long: \(location.longitude)"), completionHandler: { error in
                if let error = error {
                    print("Send error: \(error)")
                }
        })
    }
    
    private func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Listening to data: \(data)")
                case .string(let message):
                    print("Listening to string: \(message)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive error: \(error)")
            }
            
            self?.receive()
        })
    }
}


extension WebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        ping()
        receive()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection with socket")
    }
}
