//
//  DetailViewController.swift
//  constrs
//
//  Created by Олег Рубан on 06.03.2022.
//

import UIKit

class DetailViewController: UIViewController {
    weak var imageService: ImageService?
    var imageModel: ImageModel
    
    private lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissAction(_:)))

        return button
    }()
    
    init(imageService: ImageService, imageModel: ImageModel) {
        self.imageService = imageService
        self.imageModel = imageModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        imageService?.cancelFullImageDownload(model: imageModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setup()
        update()
    }
    
    func setup() {
        navigationItem.rightBarButtonItem = closeButton
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func update() {
        imageService?.fullImage(model: imageModel, completion: { [weak self] result in
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
    
    @objc func dismissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)   
    }
    
}
