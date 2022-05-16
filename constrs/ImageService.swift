//
//  ImageService.swift
//  constrs
//
//  Created by Олег Рубан on 03.03.2022.
//

import Foundation
import UIKit

class ImageService {
    typealias ImageListResult = NetworkResult<ImageList, Error?>
    typealias ImageResult = NetworkResult<UIImage, Error?>
    
    private let previewSize: CGSize
    private let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    
    private lazy var sessionConfiguration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 15.0
        
        return config
    }()
    
    private lazy var urlSession = URLSession(configuration: sessionConfiguration)
    
    private lazy var imageCache: [URL: String] = {
        if let data = UserDefaults.standard.data(forKey: "imageCache"),
           let decoded = try? JSONDecoder().decode([URL: String].self, from: data) {
            
            return decoded
        }
        
        return [:]
    }() {
        didSet {
            if let encoded = try? JSONEncoder().encode(imageCache) {
                UserDefaults.standard.set(encoded, forKey: "imageCache")
            }
        }
    }
    
    private let imagesPerPage = 30
    private var downloadTasks: [URL: URLSessionTask] = [:]
    
    init(previewSize: CGSize) {
        self.previewSize = previewSize
    }
    
    deinit {
        downloadTasks.forEach({ $1.cancel() })
        downloadTasks.removeAll()
    }
    
    @discardableResult
    func imageList(page: Int, completion: @escaping (ImageListResult) -> Void) -> URLSessionDataTask {
        let url = URL(string: "https://picsum.photos/v2/list?page=\(page)&limit=\(imagesPerPage)")!
        let dataTask = urlSession.dataTask(with: url) { data, _, error in
            guard let data = data else {
                completion(.failure(error))
                return
            }
            
            do {
                let imageList = try JSONDecoder().decode([ImageModel].self, from: data)
                completion(.success(.init(images: imageList, hasMoreToLoad: imageList.count == self.imagesPerPage)))
            } catch {
                completion(.failure(error))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    func previewImage(model: ImageModel, completion: @escaping (ImageResult) -> Void) {
        image(url: model.url(forSize: previewSize), completion: completion)
    }
    
    func fullImage(model: ImageModel, completion: @escaping (ImageResult) -> Void) {
        image(url: model.fullSizeUrl, completion: completion)
    }
    
    func cancelPreviewImageDownload(model: ImageModel) {
        cancelImageDownload(url: model.url(forSize: previewSize))
    }
    
    func cancelFullImageDownload(model: ImageModel) {
        cancelImageDownload(url: model.fullSizeUrl)
    }
}

private extension ImageService {
    private func cancelImageDownload(url: URL) {
        if let task = downloadTasks[url] {
            task.cancel()
            downloadTasks[url] = nil
        }
    }
    
    private func image(url: URL, completion: @escaping (ImageResult) -> Void) {
        if let cachedFilename = imageCache[url] {
            if let cachedUrl = cachesDir?.appendingPathComponent(cachedFilename) {
                if let image = UIImage(contentsOfFile: cachedUrl.path) {
                    print("Loaded cached image for \(url)")
                    completion(.success(image))
                    return
                } else {
                    
                    do {
                        try FileManager.default.removeItem(at: cachedUrl)
                        self.imageCache[url] = nil
                        
                        print("Failed to load cached image for \(url). Record deleted")
                    } catch {
                        print("Failed to load cached image for \(url). Error deleting record: \(error.localizedDescription)")
                    }
                }
            } else {
                imageCache[url] = nil
            }
        }
        
        let downloadTask = urlSession.downloadTask(with: url) { tempUrl, _, error in
            self.downloadTasks[url] = nil
            
            if let error = error as NSError?, error.code == NSURLErrorCancelled {
                print("Download cancelled for: \(url)")
                return
            }
            
            guard let tempUrl = tempUrl else {
                print("Download finished: \(url). ERROR: \(error?.localizedDescription ?? "UNKNOWN")")
                completion(.failure(error))
                return
            }
            
            guard let cachesDir = self.cachesDir else {
                if let image = UIImage(contentsOfFile: tempUrl.path) {
                    print("Download finished: \(url). Unable to cache image, but image loaded from temporary file")
                    completion(.success(image))
                } else {
                    print("Download finished: \(url). Unable to cache image, image load failed")
                    completion(.failure(nil))
                }
                
                return
            }
            
            do {
                let destUrl = cachesDir.appendingPathComponent("\(UUID().uuidString).png")
                try FileManager.default.moveItem(at: tempUrl, to: destUrl)
                
                if let image = UIImage(contentsOfFile: destUrl.path) {
                    self.imageCache[url] = destUrl.lastPathComponent
                    print("Download finished: \(url). Image cached to: \(destUrl)")
                    completion(.success(image))
                } else {
                    print("Download finished: \(url). Image cached but can't load it from the destination file. URL: \(destUrl)")
                    completion(.failure(nil))
                }
            } catch {
                
                if let image = UIImage(contentsOfFile: tempUrl.path) {
                    print("Download finished: \(url). Failed to move image file to caches dir, but image loaded from temporary file. ERROR: \(error.localizedDescription)")
                    completion(.success(image))
                } else {
                    print("Download finished: \(url). Unable to cache image, image load failed. ERROR: \(error.localizedDescription)")
                    completion(.failure(nil))
                }
                completion(.failure(error))
            }
        }
        
        downloadTasks[url] = downloadTask
        downloadTask.resume()
        
        print("Download started: \(url)")
    }
}
