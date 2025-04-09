//
//  CollectionViewCell.swift
//  Counter
//
//  Created by 이택성 on 4/9/25.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    static let identifier = "collectionViewCell"
    
    let numberLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(numberLabel)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        self.backgroundColor = .purple.withAlphaComponent(0.4)
    }
}
