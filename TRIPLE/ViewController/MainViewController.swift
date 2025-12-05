//
//  MainViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/24/25.
//

import UIKit

class MainViewController: UIViewController, MainViewScrollDelegate {
    
    // MARK: - 변수 & 상수
    // SideMenuViewController 가져오기 변수
    private var sideMenuViewController: SideMenuViewController!
    private var sideMenuShadowView: UIView!
    // 사이드바 가로 넓이 + 회전시 폭
    private var sideMenuRevealWidth: CGFloat = 320
    private let paddingForRotation: CGFloat = 100
    private var isExpanded: Bool = false
    // 사이드메뉴 열기/닫기 설정용
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    // Sticky Range
    private let stickyRange: CGFloat = 120
    private var initialMainTopConstant: CGFloat = 0
    
    // MARK: - @IBOutlets
    // mainView & goneView를 위로 올리기 위한 상단 제약
    @IBOutlet weak var goneViewTopConstraint: NSLayoutConstraint! 
    @IBOutlet weak var mainViewTopConstraint: NSLayoutConstraint!
    // View & NavigationBar
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var goneView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    // MARK: - 생명주기
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.initialMainTopConstant = self.mainViewTopConstraint?.constant ?? 0
        self.setSideMenu() // 사이드바 추가
        embedMainView()
        embedGoneView()
    }
    
    // MARK: - UIView 초기세팅
    private func embedMainView() {
        let detailView = MainView()
        detailView.scrollDelegate = self
        detailView.translatesAutoresizingMaskIntoConstraints = false // AutoLayout과의 충돌 방지용
        let targetContainer = mainView ?? view
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
    
    private func embedGoneView() {
        let detailView = GoneView()
        detailView.translatesAutoresizingMaskIntoConstraints = false // AutoLayout과의 충돌 방지용
        let targetContainer = goneView ?? view
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
    
    // MARK: - @IBActions
    // 누르면 push 방식으로 SearchViewController로 이동
    @IBAction func openSearchMenu(_ sender: Any) {
        let vc: UIViewController
        if Bundle.main.path(forResource: "SearchViewController", ofType: "nib") != nil {
            vc = SearchViewController(nibName: "SearchViewController", bundle: .main)
        } else {
            vc = SearchViewController()
        }
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        }
    }
    // 수동으로 버튼 누르면 만든 뷰 열기
    @IBAction func openSlideMenu(_ sender: Any) {
        self.sideMenuState(expanded: self.isExpanded ? false : true)
    }
    
    //MARK: - SideMenuViewController 설정
    func setSideMenu(){
        self.sideMenuShadowView = UIView(frame: self.view.bounds)
        self.sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // 크기가 변경될때 자동으로 맞춰주는 코드
        self.sideMenuShadowView.backgroundColor = .black
        self.sideMenuShadowView.alpha = 0.0 // 시작할때 투명도 기본값은 0
        // 그림자 영역 클릭시 창 닫기
        let closeShadowClick = UITapGestureRecognizer(target: self, action: #selector(sideMenuState(tapRecog:)))
        self.sideMenuShadowView.addGestureRecognizer(closeShadowClick)
        // 그림자 영역 추가
        view.addSubview(self.sideMenuShadowView)

        if Bundle.main.path(forResource: "SideMenuViewController", ofType: "nib") != nil {
            self.sideMenuViewController = SideMenuViewController(nibName: "SideMenuViewController", bundle: .main)
        } else {
            self.sideMenuViewController = SideMenuViewController()
        }
   
        // 사이드바 영역 추가
        view.addSubview(self.sideMenuViewController!.view)
        addChild(self.sideMenuViewController!) // 뷰가 추가될 영역 설정
        self.sideMenuViewController!.didMove(toParent: self)

        // 사이드 메뉴 레이아웃 잡기
        self.sideMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.sideMenuTrailingConstraint = self.sideMenuViewController.view.trailingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.trailingAnchor,
            constant: self.sideMenuRevealWidth + self.paddingForRotation
        )
        self.sideMenuTrailingConstraint.isActive = true

        NSLayoutConstraint.activate([
            self.sideMenuViewController.view.widthAnchor.constraint(equalToConstant: self.sideMenuRevealWidth),
            self.sideMenuViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            self.sideMenuViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // 그림자 부분 클릭시 닫기 연결용
    @objc func sideMenuState(tapRecog: UITapGestureRecognizer){
        self.sideMenuState(expanded: self.isExpanded ? false : true) // 열려있으면 닫기
    }
    
    // 메뉴를 열거나 닫을지 결정
    func sideMenuState(expanded: Bool) {
        if expanded {
            self.animateSideMenu(targetPosition:  0 ) { _ in
                self.isExpanded = true // 메뉴 열기
            }
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.6 } // 0.5초동안 진행
        }
        else {
            self.animateSideMenu(targetPosition: (self.sideMenuRevealWidth + self.paddingForRotation)) { _ in
                self.isExpanded = false // 메뉴 닫기
            }
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.0 } // 0.5초동안 진행
        }
    }
    
    // 애니메이션으로 이동하는 역할
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            self.sideMenuTrailingConstraint.constant = targetPosition // 뷰의 위치를 이동시킴
            self.view.layoutIfNeeded() // 화면에 바로 보이게 하기
        }, completion: completion)
    }
    
    // MARK: - MainViewScrollDelegate (Sticky Header)
    func mainViewDidScroll(to offsetY: CGFloat) {
        // Sticky 효과를 구현
        self.mainViewTopConstraint?.constant = initialMainTopConstant - max(0, min(stickyRange, offsetY))
        
        // 사용자가 아래로 당길때
        if offsetY < 0 {
            self.mainViewTopConstraint?.constant =
            min(initialMainTopConstant, (self.mainViewTopConstraint?.constant ?? initialMainTopConstant) + min(stickyRange, abs(offsetY)))
        }
        self.view.layoutIfNeeded() // 화면에 바로 보이게 하기
    }
}

