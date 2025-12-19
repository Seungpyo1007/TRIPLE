//
//  CityRecCollectionDelegate.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/10/25.
//

import UIKit

final class CityRecCollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var viewModel: CityRecCollectionViewModel
    private weak var presentingViewController: UIViewController?

    convenience init(viewModel: CityRecCollectionViewModel, presentingViewController: UIViewController) {
        self.init(viewModel: viewModel)
        self.presentingViewController = presentingViewController
    }

    func attachPresenter(_ vc: UIViewController) {
        self.presentingViewController = vc
    }

    init(viewModel: CityRecCollectionViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    // MARK: - Public API
    func reload(with viewModel: CityRecCollectionViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityRecCollectionViewCell.reuseIdentifier, for: indexPath) as? CityRecCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of CityRecCollectionViewCell.")
        }
        let placeholder = viewModel.item(at: indexPath.item).title
        // Prefer configuring with City model for clarity
        let city = CityService().city(forName: placeholder)
        cell.configure(with: city)
        cell.configureImage(viewModel: viewModel, indexPath: indexPath, collectionView: collectionView)
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        let verticalInset: CGFloat = 0
        let adjustedHeight = max(0, height - verticalInset * 2)
        return CGSize(width: adjustedHeight, height: adjustedHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let city = viewModel.cityForItem(at: indexPath.item)
        let vm = CityViewModel(city: city)
        let vc = CityViewController.instantiate(with: vm)

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

extension UIView {
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }
}
