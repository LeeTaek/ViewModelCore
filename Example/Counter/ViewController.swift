//
//  ViewController.swift
//  MacroTest
//
//  Created by 이택성 on 4/3/25.
//

import UIKit
import Combine
import ViewModelCore

class ViewController: UIViewController {
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var textfieldLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let viewModel = ViewModel()
    var datasource: UICollectionViewDiffableDataSource<Int, Int>!

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setUI()
        configureDatasource()
    }
    
    @IBAction func tapPlusButton(_ sender: Any) {
        viewModel.send(.increase)
    }
    
    @IBAction func tapMinusButton(_ sender: Any) {
        viewModel.send(.decrease)
    }
    
    @IBAction func tapAddCellButton(_ sender: Any) {
        viewModel.send(.increaseDatasourceItems)
    }
    
    @IBAction func tapSubtractCellButton(_ sender: Any) {
        viewModel.send(.decreaseDatasourceItems)
    }
    
    private func bind() {
        self.viewModel.$state
            .map { $0.count.description }
            .bind(on: self) { [weak self] text in
                self?.count.text = text
            }
        
        self.viewModel.$state
            .map { $0.text }
            .bind(on: self) { [weak self] text in
                self?.textfieldLabel.text = text
            }
        
        self.textField
            .textPublisher
            .bind(on: self) { [weak self] text in
                guard let text else { return }
                self?.viewModel.send(.inputTextfield(text))
            }
        
        self.viewModel.$state
            .map { $0.datasourceItem }
            .bind(on: self) { [weak self] items in
                self?.applySnapshot(items: items)
            }
    }
    
    private func setUI() {
        collectionView.register(CollectionViewCell.self,
                                forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collectionView.collectionViewLayout = configureCollectionVIewLayout()
    }
    
    private func configureDatasource() {
        datasource = UICollectionViewDiffableDataSource<Int, Int>(
            collectionView: collectionView
        ) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier,
                                                                for: indexPath) as? CollectionViewCell else {
                fatalError("Cannot create CollectionViewCell")
            }
            cell.numberLabel.text = itemIdentifier.description
            return cell
        }
        
        applySnapshot(items: viewModel.state.datasourceItem)
    }
    

    private func applySnapshot(items: [Int]) {
        var snapshot = datasource.snapshot()
        
        if snapshot.sectionIdentifiers.isEmpty {
            snapshot.appendSections([0])
        }
        
        snapshot.deleteItems(snapshot.itemIdentifiers)
        snapshot.appendItems(items, toSection: 0)
        
        datasource.apply(snapshot, animatingDifferences: true) { [weak self] in
            guard let collectionView = self?.collectionView,
                  let lastItem = items.last,
                  let lastIndex = items.firstIndex(of: lastItem),
                  let totalItems = self?.collectionView.numberOfItems(inSection: 0)
            else { return }
            
            let lastIndexPath = IndexPath(item: lastIndex, section: 0)
            let visibleIndexPaths = Set(collectionView.indexPathsForVisibleItems)
            
            if !visibleIndexPaths.contains(lastIndexPath),
               lastIndexPath.item < totalItems {
                collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    private func configureCollectionVIewLayout() -> UICollectionViewCompositionalLayout {
        let leadingItemsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7),
                                              heightDimension: .fractionalHeight(1.0))
        let leadingItem = NSCollectionLayoutItem(layoutSize: leadingItemsize)
        leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let trailingItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(0.5))
        let trailingItem = NSCollectionLayoutItem(layoutSize: trailingItemSize)
        trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                               heightDimension: .fractionalHeight(1.0))
        let nestGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(0.4))
        let trailingGroup: NSCollectionLayoutGroup
        if #available(iOS 16.0, *) {
            trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     repeatingSubitem: trailingItem,
                                                     count: 2)
        } else {
            trailingGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: trailingItem,
                                                       count: 3)
        }
        let nestGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestGroupSize,
                                                       subitems: [leadingItem, trailingGroup])
        
        let section = NSCollectionLayoutSection(group: nestGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

