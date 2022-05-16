//
//  ImageModel.swift
//  constrs
//
//  Created by Олег Рубан on 03.03.2022.
//

import Foundation
import UIKit

struct ImageModel: Decodable {
    private static let baseUrl: URL = .init(string: "https://picsum.photos")!
    
    var id: String
    var author: String
    var width: Int
    var height: Int
    
    var fullSizeUrl: URL {
        return url(forSize: .init(width: width, height: height))
    }
    
    func url(forSize size: CGSize) -> URL {
        return Self.baseUrl.appendingPathComponent("id/\(id)/\(Int(size.width))/\(Int(size.height))")
    }
}
