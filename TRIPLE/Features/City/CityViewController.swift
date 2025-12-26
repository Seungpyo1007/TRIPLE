//
//  CountryViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import UIKit
import RiveRuntime

class CityViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var riveView: RiveView!
    @IBOutlet weak var cityKorLabel: UILabel!
    @IBOutlet weak var cityEngLabel: UILabel!
    @IBOutlet weak var cityTownLabel: UILabel!
    @IBOutlet weak var cityFirstCityLabel: UILabel!
    @IBOutlet weak var citySecondCityLabel: UILabel!
    
    // MARK: - State & Dependencies
    var viewModel: CityViewModel?
    var riveVM = RiveViewModel(fileName: "Snow")
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        riveVM.setView(riveView)
        setupCityDisplay()
        setupGesture()
    }
    
    // MARK: - UI Setup
    private func setupCityDisplay() {
        guard let vm = viewModel else { return }
        
        // 기본 타이틀 설정
        self.title = vm.cityNameText

        // 상세 표기 정보 조회
        let model = CityRecModel()
        let info: CityDisplayInfo? = {
            if !vm.placeIDText.isEmpty { return model.displayInfo(forPlaceID: vm.placeIDText) }
            else { return model.displayInfo(for: vm.cityNameText) }
        }()

        if let info = info {
            self.title = info.cityKoreanName
            cityKorLabel.text = info.cityKoreanName
            cityEngLabel.text = info.cityEnglishName
            cityTownLabel.text = info.famousTownKorean
            cityFirstCityLabel.text = info.firstFamousCityKorean
            citySecondCityLabel.text = info.secondFamousCityKorean
            
            [cityKorLabel, cityEngLabel, cityTownLabel, cityFirstCityLabel, citySecondCityLabel].forEach {
                $0?.isHidden = ($0?.text?.isEmpty ?? true)
            }
        } else {
            cityKorLabel.text = vm.cityNameText
            [cityEngLabel, cityTownLabel, cityFirstCityLabel, citySecondCityLabel].forEach { $0?.isHidden = true }
        }
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapRiveView))
        riveView.isUserInteractionEnabled = true
        riveView.addGestureRecognizer(tap)
    }
    
    // MARK: - Navigation
    @objc private func didTapRiveView() {
        let cityName: String
        if let vm = viewModel {
            if let info = CityRecModel().displayInfo(forPlaceID: vm.placeIDText).flatMap({ $0 }) ?? CityRecModel().displayInfo(for: vm.cityNameText) {
                cityName = info.cityEnglishName
            } else {
                cityName = vm.cityNameText
            }
        } else {
            cityName = cityKorLabel.text?.isEmpty == false ? (cityEngLabel.text?.isEmpty == false ? (cityEngLabel.text ?? "") : (cityKorLabel.text ?? "")) : "Tokyo"
        }
        
        let weatherVM = WeatherViewModel(cityName: cityName)
        let weatherVC = WeatherViewController.instantiate(with: weatherVM)
        self.navigationController?.pushViewController(weatherVC, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func closeButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openSideMenu(_ sender: Any) {
        let alert = UIAlertController(title: "사이드 메뉴", message: "기능이 아직 미완성입니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func openMapsMenu(_ sender: Any) {
        let vc: CityPlacesViewController = Bundle.main.path(forResource: "CityPlacesViewController", ofType: "nib") != nil
            ? CityPlacesViewController(nibName: "CityPlacesViewController", bundle: .main)
            : CityPlacesViewController()
        
        if let vm = viewModel {
            let info = CityRecModel().displayInfo(for: vm.cityNameText)
            vc.initialCityName = info?.cityKoreanName ?? vm.cityNameText
            vc.initialPlaceID = vm.placeIDText.isEmpty ? nil : vm.placeIDText
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - External Factory
extension CityViewController {
    static func instantiate(with viewModel: CityViewModel) -> CityViewController {
        let nibName = "CityViewController"
        let vc = Bundle.main.path(forResource: nibName, ofType: "nib") != nil
            ? CityViewController(nibName: nibName, bundle: .main)
            : CityViewController()
        
        vc.viewModel = viewModel
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}
