//
//  SettingsViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/3/25.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    var swipeRecognizer: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRecognizer)
        embedSettingsView()
    }
    
    @objc func swipeAction(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func embedSettingsView() {
        let detailView = SettingsView() // SettingView 가져오기
        detailView.translatesAutoresizingMaskIntoConstraints = false // Auto Layout 필수
        let targetContainer = containerView ?? view // containerView에 넣기
        targetContainer?.addSubview(detailView)

        if let target = targetContainer {
            NSLayoutConstraint.activate([
                detailView.topAnchor.constraint(equalTo: target.topAnchor),
                detailView.bottomAnchor.constraint(equalTo: target.bottomAnchor),
                detailView.leadingAnchor.constraint(equalTo: target.leadingAnchor),
                detailView.trailingAnchor.constraint(equalTo: target.trailingAnchor)
            ])
        }
    }
}
