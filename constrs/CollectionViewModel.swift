//
//  CollectionViewModel.swift
//  constrs
//
//  Created by Олег Рубан on 24.03.2022.
//

import Foundation
import Combine

class CollectionViewModel: ObservableObject {
    let imageService: ImageService
    
    @Published private(set) var imageList: [ImageModel] = []
    @Published private(set) var imageToOpen: ImageModel?
    
    private var currentTask: URLSessionDataTask?
    
    private(set) var currentPage = 0
    private(set) var hasMoreToLoad = false
    
    deinit {
        currentTask?.cancel()
    }
    
    init(imageService: ImageService) {
        self.imageService = imageService
    }
}

extension CollectionViewModel {
    func viewDidLoadTrigger() {
        fetchImages(page: 1)
    }
    
    func paginateTrigger() {
        fetchImages(page: currentPage + 1)
    }
    
    func imageTapTrigger(index: Int) {
        guard index >= 0, index < imageList.count else { return }
        
        imageToOpen = imageList[index]
    }
}

private extension CollectionViewModel {
    func fetchImages(page: Int) {
        currentTask?.cancel()
        currentTask = imageService.imageList(page: page) { [weak self] result in
            switch result {
            case let .success(imageList):
                print("Fetched \(imageList.images.count) images, hasMore: \(imageList.hasMoreToLoad)")
                self?.currentPage = page
                self?.imageList.append(contentsOf: imageList.images)
                self?.hasMoreToLoad = imageList.hasMoreToLoad
            case let .failure(error):
                print("Error: \(error?.localizedDescription ?? "UNKNOWN")")
            }
        }
    }
}
