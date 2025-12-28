//
//  CityRecCollectionDelegate.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/10/25.
//

import UIKit

final class CityRecCollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - 속성
    /// 컬렉션 뷰에 표시할 데이터를 관리하는 뷰모델
    private var viewModel: CityRecCollectionViewModel
    /// 화면 전환을 수행할 뷰 컨트롤러 (약한 참조로 순환 참조 방지)
    private weak var presentingViewController: UIViewController?

    // MARK: - 초기화
    /// 편의 초기화 메서드: 뷰모델과 프레젠팅 뷰 컨트롤러를 함께 받아 초기화
    convenience init(viewModel: CityRecCollectionViewModel, presentingViewController: UIViewController) {
        self.init(viewModel: viewModel)
        self.presentingViewController = presentingViewController
    }

    /// 기본 초기화 메서드
    init(viewModel: CityRecCollectionViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    // MARK: - API
    /// 뷰 컨트롤러를 나중에 설정할 수 있도록 하는 메서드
    func attachPresenter(_ vc: UIViewController) {
        self.presentingViewController = vc
    }

    /// 뷰모델을 새로 설정하여 컬렉션 뷰 데이터 갱신
    func reload(with viewModel: CityRecCollectionViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - UICollectionViewDataSource
    /// 섹션에 표시할 아이템 개수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }

    /// 특정 인덱스의 셀을 구성하여 반환
    /// dequeueReusableCell: 재사용 가능한 셀을 큐에서 가져오거나 새로 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 재사용 가능한 셀을 큐에서 가져오기 (없으면 새로 생성)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityRecCollectionViewCell.reuseIdentifier, for: indexPath) as? CityRecCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of CityRecCollectionViewCell.")
        }
        // 뷰모델에서 해당 인덱스의 아이템 정보 가져오기
        let placeholder = viewModel.item(at: indexPath.item).title
        // 도시 이름으로 City 모델 조회
        let city = CityService().city(forName: placeholder)
        // 셀에 도시 정보 설정
        cell.configure(with: city)
        // 비동기로 이미지 로드
        cell.configureImage(viewModel: viewModel, indexPath: indexPath, collectionView: collectionView)
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    /// 각 셀의 크기를 반환 (정사각형으로 설정)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 컬렉션 뷰의 높이 가져오기
        let height = collectionView.bounds.height
        // 수직 여백 (현재는 0)
        let verticalInset: CGFloat = 0
        // 여백을 고려한 조정된 높이 계산
        let adjustedHeight = max(0, height - verticalInset * 2)
        // 정사각형 크기 반환 (너비 = 높이)
        return CGSize(width: adjustedHeight, height: adjustedHeight)
    }

    // MARK: - UICollectionViewDelegate
    /// 셀을 선택했을때 선택한 도시의 상세 화면(CityViewController)으로 이동합니다.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 선택한 아이템의 도시 정보 가져오기
        let city = viewModel.cityForItem(at: indexPath.item)
        // CityViewModel 생성
        let vm = CityViewModel(city: city)
        // CityViewController 생성 및 ViewModel 주입
        let vc = CityViewController.instantiate(with: vm)

        // 뷰 컨트롤러 찾기 (직접 설정된 것 또는 컬렉션 뷰에서 찾은 것)
        if let presenter = presentingViewController ?? collectionView.findViewController() {
            if let nav = presenter as? UINavigationController {
                nav.pushViewController(vc, animated: true)
            } else if let nav = presenter.navigationController {
                nav.pushViewController(vc, animated: true)
            } else if let nav = collectionView.findViewController()?.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                presenter.present(vc, animated: true)
            }
        }
    }
}

// MARK: - UIView 도우미
extension UIView {
    /// 현재 뷰가 속한 뷰 컨트롤러를 찾는 메서드
    /// 뷰 계층 구조에서 부모 뷰 컨트롤러를 찾을 때 사용합니다.
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        // Responder Chain을 따라 올라가면서 뷰 컨트롤러 찾기
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            // 다음 응답자로 이동 (부모 뷰 또는 뷰 컨트롤러)
            responder = r.next
        }
        return nil
    }
}
