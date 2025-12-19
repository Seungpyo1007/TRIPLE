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
    
    // MARK: - 상수 & 변수
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
    
    @IBAction func closeSideMenu(_ sender: Any) {
        // TODO: - 여기다가 닫기 구현
        let alert = UIAlertController(title: "닫기", message: "기능이 아직 미완성입니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func openNotificationMenu(_ sender: Any) {
        // TODO: - 여기다가 알림메뉴 구현
        let alert = UIAlertController(title: "알림 메뉴", message: "기능이 아직 미완성입니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    // MARK: - UIView 초기세팅
    private func embedSideMenuDetail() {
        let detailView = SideMenuDetailView() // SideMenuDetailView 가져오기
        detailView.delegate = self
        self.detailView = detailView
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
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.onProfileChanged = { [weak self] profile in
            self?.detailView?.configure(name: profile.name, image: self?.imageFromData(profile.imageData))
        }
        viewModel.onProfileImageChanged = { [weak self] image in
            guard let name = self?.viewModel.profile.name else { return }
            self?.detailView?.configure(name: name, image: image)
        }
        // 현재 프로필로 초기화
        let current = viewModel.profile
        detailView?.configure(name: current.name, image: imageFromData(current.imageData))
    }
    
    private func imageFromData(_ data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        return UIImage(data: data)
    }
    
    // MARK: - SideMenuDetailViewDelegate (ProfileEditLabel)
    func sideMenuDetailViewDidTapProfileEditLabel(_ view: SideMenuDetailView) {
        let profileVC = ProfileEditViewController()
        if let nav = self.navigationController {
            nav.pushViewController(profileVC, animated: true)
        }
    }
}

