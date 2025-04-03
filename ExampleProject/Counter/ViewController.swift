//
//  ViewController.swift
//  MacroTest
//
//  Created by 이택성 on 4/3/25.
//

import UIKit
import Combine

class ViewController: UIViewController {
    @IBOutlet weak var count: UILabel!
    
    private let viewModel = ViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    @IBAction func tapPlusButton(_ sender: Any) {
        viewModel.send(.increase)
    }
    
    @IBAction func tapMinusButton(_ sender: Any) {
        viewModel.send(.decrease)
    }
    
    private func bind() {
        viewModel.$state
            .map { $0.count.description }
            .sink { [weak self] countText in
                self?.count.text = countText
            }
            .store(in: &cancellable)      
    }
}

