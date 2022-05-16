//
//  CollectionController.swift
//  constrs
//
//  Created by Олег Рубан on 14.02.2022.
//

import UIKit
import Combine

class CollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private lazy var layoutConfiguration: UICollectionViewCompositionalLayoutConfiguration = {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        config.contentInsetsReference = .none
        
        return config
    }()
    
    private lazy var collectionLayout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { idx, env in
            let numberOfColumns: CGFloat
            if env.traitCollection.horizontalSizeClass == .compact {
                numberOfColumns = 3
            } else {
                numberOfColumns = 5
            }

            let itemSizeFraction = 1 / numberOfColumns
            let insets = self.itemSpacing / 2.0
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(itemSizeFraction), heightDimension: .fractionalHeight(1)))
            item.contentInsets = .init(top: insets, leading: insets, bottom: insets, trailing: insets)

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(itemSizeFraction)), subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            return section
        }, configuration: layoutConfiguration)

        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        
        collection.alwaysBounceVertical = false
        collection.showsHorizontalScrollIndicator = false
        
        collection.clipsToBounds = false

        return collection
    }()
    
    //
    private let viewModel: CollectionViewModel
    private let itemSpacing: CGFloat = 2.0
    private var cancellables: Set<AnyCancellable> = .init()
    
    private var imageList: [ImageModel] = [] {
        didSet {
            let wasPaginated = viewModel.currentPage > 1
            let newItemsCount = imageList.count - oldValue.count + (viewModel.hasMoreToLoad ? 1 : 0)

            DispatchQueue.main.async {
                self.collectionView.performBatchUpdates {
                    if wasPaginated {
                        self.collectionView.deleteItems(at: [.init(item: oldValue.count, section: 0)])
                    }

                    self.collectionView.insertItems(at: (0..<newItemsCount).map({ .init(item: oldValue.count + $0, section: 0) }))
                }
            }
        }
    }
    
     var animController: AnimController!
    
    required init(viewModel: CollectionViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: "loading")
        
        setup()
        
        viewModel.viewDidLoadTrigger()
    }
    
    func setup() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func bind() {
        self.viewModel.$imageList
            .filter({ !$0.isEmpty })
            .sink { [weak self] imageList in
                print("GET VALUE")
                self?.imageList = imageList
            }
            .store(in: &self.cancellables)
        
        self.viewModel.$imageToOpen
            .compactMap({ $0 })
            .receive(on: RunLoop.main)
            .sink { [weak self] image in
                print("GET VALUE 1")
                print(image)
                
                self!.openImageDetails(imageModel: image)
            }
            .store(in: &self.cancellables)
    }
    
    func openImageDetails(imageModel: ImageModel) {
        let imageModel = imageModel
        let controller = DetailViewController(imageService: self.viewModel.imageService, imageModel: imageModel)
        let navController = UINavigationController(rootViewController: controller)
        
        navController.transitioningDelegate = self
        navController.modalPresentationStyle = .custom
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count + (viewModel.hasMoreToLoad ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.hasMoreToLoad, indexPath.item == imageList.count {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "loading", for: indexPath)
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionCell else { fatalError() }
            
            cell.imageService = viewModel.imageService
            cell.update(withImageModel: imageList[indexPath.item])

            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionCell else { return }
        
        viewModel.imageTapTrigger(index: indexPath.row)

        let frame = collectionView.convert(cell.frame, to: view)
        animController = AnimController(imageView: cell.imageView, imageFrame: frame)

    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard cell is LoadingCell else { return }
        
        viewModel.paginateTrigger()
    }
}

extension CollectionController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animController.isDismissing = false
        return animController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animController.isDismissing = true
        return animController
    }
}
