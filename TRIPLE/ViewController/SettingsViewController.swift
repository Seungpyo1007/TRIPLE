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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.preservesSuperviewLayoutMargins = false
        view.directionalLayoutMargins = .zero
        containerView?.preservesSuperviewLayoutMargins = false
        containerView?.directionalLayoutMargins = .zero
        embedSettingsView()
    }

    private func embedSettingsView() {
        let detailView = SettingsView()
        detailView.translatesAutoresizingMaskIntoConstraints = false
        let targetContainer = containerView ?? view
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
