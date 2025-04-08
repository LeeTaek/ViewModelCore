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
    }
}

