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
    
    private let viewModel = ViewModel()
    
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
        self.viewModel.$state
            .map { $0.count.description }
            .bind(storeIn: &cancellables) { [weak self] text in
                self?.count.text = text
            }
    }
}

