//
//  ColaCupSearchBar.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/22.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Search bar in `ColaCupController`
open class ColaCupSearchBar: UIView {
    
    public init() {
        super.init(frame: .zero)
        config()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    /// The parent view of all the views below. Responsible for layout constraints.
    open lazy var stackView: UIStackView = {
        
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        
        return stackView
    }()
    
    /// Custom view displayed on the right side of the search bar.
    open lazy var footerView: UIView? = nil {
        didSet {
            guard let view = footerView else { return }
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.insertArrangedSubview(view, at: stackView.arrangedSubviews.count)
        }
    }
    
    /// Search bar.
    open lazy var searchBar: UISearchBar = {
        
        let searchBar = UISearchBar()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.placeholder = "Search with keyword"
        searchBar.tintColor = .theme
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.textColor = .normalText
        
        return searchBar
    }()
}

// MARK: - Config

private extension ColaCupSearchBar {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(stackView)
        stackView.addArrangedSubview(searchBar)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
