//
//  SideMenuViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/25/25.
//

import UIKit

class SideMenuViewController: UIViewController, SideMenuDetailViewDelegate {
    
    // MARK: - @IBOutlet
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - @IBAction
    @IBAction func openSettingsMenu(_ sender: Any) {
        let vc: UIViewController
        
        if Bundle.main.path(forResource: "SettingsViewController", ofType: "nib") != nil {
            vc = SettingsViewController(nibName: "SettingsViewController", bundle: .main)
        } else {
            vc = SettingsViewController()
        }
        
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        embedSideMenuDetail()
    }

    // MARK: - UIView 초기세팅
    private func embedSideMenuDetail() {
        let detailView = SideMenuDetailView() // SideMenuDetailView 가져오기
        detailView.delegate = self
        detailView.translatesAutoresizingMaskIntoConstraints = false // Auto Layout을 사용하기 위해 기본 설정을 비활성화
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
    
    // MARK: - SideMenuDetailViewDelegate (ProfileEditLabel)
    func sideMenuDetailViewDidTapProfileEditLabel(_ view: SideMenuDetailView) {
        let profileVC = ProfileEditViewController()
        if let nav = self.navigationController {
            nav.pushViewController(profileVC, animated: true)
        }
    }
}
