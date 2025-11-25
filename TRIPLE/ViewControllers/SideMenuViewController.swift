//
//  SideMenuViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/25/25.
//

import UIKit

class SideMenuViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        embedSideMenuDetail()
    }

    private func embedSideMenuDetail() {
        let detailView = SideMenuDetailView()
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
