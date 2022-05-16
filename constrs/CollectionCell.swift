//
//  CollectionCell.swift
//  constrs
//
//  Created by Олег Рубан on 14.02.2022.
//

import UIKit

class CollectionCell: UICollectionViewCell {
     var imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    weak var imageService: ImageService?
    private var imageModel: ImageModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let imageModel = imageModel {
            imageService?.cancelPreviewImageDownload(model: imageModel)
        }
        
        imageModel = nil
        imageView.image = nil
    }
    
    deinit {
        if let imageModel = imageModel {
            imageService?.cancelPreviewImageDownload(model: imageModel)
        }
    }
    
    func setup() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func update(withImageModel imageModel: ImageModel) {
        self.imageModel = imageModel
        imageService?.previewImage(model: imageModel, completion: { [weak self] result in
            switch result {
            case let .success(image):
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
                
            case .failure:
                return
            }
        })
    }
}
