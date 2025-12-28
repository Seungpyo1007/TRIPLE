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
    
    // MARK: - 속성
    private let viewModel = SideMenuViewModel()
    private weak var detailView: SideMenuDetailView?
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        embedSideMenuDetail()
        viewModel.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }
    
    // MARK: - @IBActions
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
    
    @IBAction func closeSideMenu(_ sender: Any) {
        let alert = UIAlertController(title: "닫기", message: "기능이 아직 미완성입니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func openNotificationMenu(_ sender: Any) {
        let alert = UIAlertController(title: "알림 메뉴", message: "기능이 아직 미완성입니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    // MARK: - 임베딩
    private func embedSideMenuDetail() {
        let detailView = SideMenuDetailView()
        detailView.delegate = self
        self.detailView = detailView
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
        bindViewModel()
    }
    
    // MARK: - 바인딩
    private func bindViewModel() {
        viewModel.onProfileChanged = { [weak self] profile in
            guard let self = self else { return }
            
            let currentImage = self.detailView?.profileImageView.image ?? UIImage(systemName: "person.circle.fill")
            self.detailView?.configure(name: profile.name, image: currentImage)
            
            if let urlString = profile.profileImage, let url = URL(string: urlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let newImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.detailView?.configure(name: profile.name, image: newImage)
                        }
                    }
                }
            } else {
                self.detailView?.configure(name: profile.name, image: UIImage(systemName: "person.circle.fill"))
            }
        }
        
        viewModel.reload()
    }
    
    // MARK: - SideMenuDetailViewDelegate
    func sideMenuDetailViewDidTapProfileEditLabel(_ view: SideMenuDetailView) {
        let profileVC = ProfileEditViewController()
        if let nav = self.navigationController {
            nav.pushViewController(profileVC, animated: true)
        }
    }
}
