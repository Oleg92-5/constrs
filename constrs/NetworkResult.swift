//
//  NetworkResult.swift
//  constrs
//
//  Created by Олег Рубан on 03.03.2022.
//

import Foundation

enum NetworkResult<Success, Failure> {
    case success(Success)
    case failure(Failure)
}
