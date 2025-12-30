//
//  SettingsViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/3/25.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - @IBOutlet
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - 속성
    private let viewModel = SettingsViewModel()
    private var swipeRecognizer: UISwipeGestureRecognizer!
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwipe()
        embedSettingsView()
    }
    
    // MARK: - 설정 메서드
    private func setupSwipe() {
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRecognizer.direction = .right
        view.addGestureRecognizer(swipeRecognizer)
    }

    private func embedSettingsView() {
        let detailView = SettingsView()
        detailView.delegate = self // 중요: Delegate 연결
        detailView.translatesAutoresizingMaskIntoConstraints = false
        
        let target = containerView ?? view
        target?.addSubview(detailView)

        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: target!.topAnchor),
            detailView.bottomAnchor.constraint(equalTo: target!.bottomAnchor),
            detailView.leadingAnchor.constraint(equalTo: target!.leadingAnchor),
            detailView.trailingAnchor.constraint(equalTo: target!.trailingAnchor)
        ])
    }
    
    // MARK: - 화면 전환 (XIB 기반)
    private func switchToIntro() {
        // IntroViewController가 XIB 파일명이 "IntroViewController"라고 가정
        let introVC = IntroViewController(nibName: "IntroViewController", bundle: nil)
        let navigationController = UINavigationController(rootViewController: introVC)
        
        navigationController.isNavigationBarHidden = true
        
        // SceneDelegate를 통해 RootViewController 교체 (애니메이션 효과 포함)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = navigationController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }

    // MARK: - Actions
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func swipeAction(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - SettingsViewDelegate 구현
extension SettingsViewController: SettingsViewDelegate {
    func didTapLogout() {
        let alert = UIAlertController(title: "로그아웃", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.viewModel.logout { success in
                if success {
                    self?.switchToIntro()
                }
            }
        })
        present(alert, animated: true)
    }
}
