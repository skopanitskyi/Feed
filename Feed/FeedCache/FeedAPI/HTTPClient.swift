//
//  HTTPClient.swift
//  Feed
//
//  Created by Сергей Копаницкий on 25.01.2023.
//

import Foundation

public enum HTTPClientResponse {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void)
}
