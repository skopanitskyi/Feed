//
//  HTTPClient.swift
//  Feed
//
//  Created by Сергей Копаницкий on 25.01.2023.
//

import Foundation

public protocol HTTPClient {
    typealias Response = Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Response) -> Void)
}
