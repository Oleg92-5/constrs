//
//  ViewController.swift
//  constrs
//
//  Created by Олег Рубан on 14.02.2022.
//

import UIKit

class ViewController: UIViewController {
    //MARK: - UI
    private lazy var label: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "0"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 24.0)
        
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(configuration: .tinted())
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Click me", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var viewGroup: UIView = {
        let viewGroup = UIView()
        
        viewGroup.translatesAutoresizingMaskIntoConstraints = false
        
        viewGroup.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
        
        return viewGroup
    }()
    //
    
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .systemBackground
        navigationItem.title = "Counter"
        
        setupUI()
    }

    private func setupUI() {
        view.addSubview(viewGroup)
        view.addSubview(label)
        view.addSubview(button)
        
        //1 - OK
        NSLayoutConstraint.activate([
            .init(item: label, attribute: .leading, relatedBy: .equal, toItem: viewGroup, attribute: .leading, multiplier: 1.0, constant: 0.0),
            .init(item: label, attribute: .trailing, relatedBy: .equal, toItem: viewGroup, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            .init(item: label, attribute: .top, relatedBy: .equal, toItem: viewGroup, attribute: .top, multiplier: 1.0, constant: 0.0),
        ])
        
        //2 - +/-
        let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1.0, constant: 16.0)
        topConstraint.isActive = true
        
        NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: viewGroup, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: viewGroup, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        //3
        NSLayoutConstraint.activate([
            .init(item: viewGroup, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1.0, constant: 16),
            .init(item: viewGroup, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1.0, constant: -16),
            .init(item: viewGroup, attribute: .centerY, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        counter += 1
        label.text = "\(counter)"
    }
}

