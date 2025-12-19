//
//  CountryViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import UIKit
import RiveRuntime

class CityViewController: UIViewController {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var riveView: RiveView!
    @IBOutlet weak var cityKorLabel: UILabel!
    @IBOutlet weak var cityEngLabel: UILabel!
    @IBOutlet weak var cityTownLabel: UILabel!
    @IBOutlet weak var cityFirstCityLabel: UILabel!
    @IBOutlet weak var citySecondCityLabel: UILabel!
    
    // MARK: - 변수 Data & State (의존성 및 상태 관리)
    var viewModel: CityViewModel?
    var riveVM = RiveViewModel(fileName: "Snow")
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        riveVM.setView(riveView)
        // ViewModel 데이터에 따른 UI 렌더링 로직 수행
        setupCityDisplay()
    }
    
    // MARK: - UI Setup
    private func setupCityDisplay() {
        guard let vm = viewModel else { return }
        
        // 1. 기본 타이틀 설정
        self.title = vm.cityNameText

        // 2. 모델을 통해 도시 상세 정보(한국어명, 유명 마을 등) 조회
        let model = CityRecModel()
        let info: CityDisplayInfo? = {
            if !vm.placeIDText.isEmpty { return model.displayInfo(forPlaceID: vm.placeIDText) }
            else { return model.displayInfo(for: vm.cityNameText) }
        }()

        // 3. 조회된 정보가 있을 경우 UI 업데이트 (없으면 Fallback 처리)
        if let info = info {
            self.title = info.cityKoreanName
            cityKorLabel.text = info.cityKoreanName
            cityEngLabel.text = info.cityEnglishName
            cityTownLabel.text = info.famousTownKorean
            cityFirstCityLabel.text = info.firstFamousCityKorean
            citySecondCityLabel.text = info.secondFamousCityKorean
            
            // 데이터 존재 여부에 따른 Hidden 처리 (생략 가능하지만 코드 가독성을 위해 유지)
            [cityKorLabel, cityEngLabel, cityTownLabel, cityFirstCityLabel, citySecondCityLabel].forEach {
                $0?.isHidden = ($0?.text?.isEmpty ?? true)
            }
        } else {
            // 정보가 없는 경우 기본 이름만 표시
            cityKorLabel.text = vm.cityNameText
            [cityEngLabel, cityTownLabel, cityFirstCityLabel, citySecondCityLabel].forEach { $0?.isHidden = true }
        }
    }
    
    // MARK: - @IBActions
    @IBAction func closeButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openSideMenu(_ sender: Any) {
        // TODO: - 여기다가 SideMenuViewController 넣어야함
        let alert = UIAlertController(title: "사이드 메뉴", message: "기능이 아직 미완성입니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func openMapsMenu(_ sender: Any) {
        // 지도 화면 초기화 및 데이터 전달
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

// MARK: - Extension (외부 호출용 생성자)
extension CityViewController {
    /// 외부(Main 등)에서 CityViewController를 안전하고 간편하게 생성하기 위한 헬퍼 함수
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
