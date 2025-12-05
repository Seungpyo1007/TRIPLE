//
//  ProfileEditViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/28/25.
//

import UIKit

class ProfileEditViewController: UIViewController {
    
    // MARK: - @IBAction
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - 스와이프 변수
    var swipeRecognizer: UISwipeGestureRecognizer!
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRecognizer)
    }
    
    // MARK: - Action
    @objc func swipeAction(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
