//
//  CountryViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import UIKit
import RiveRuntime

class CityViewController: UIViewController {
    @IBOutlet weak var riveView: RiveView!
    @IBOutlet weak var cityKorLabel: UILabel!
    @IBOutlet weak var cityEngLabel: UILabel!
    @IBOutlet weak var cityTownLabel: UILabel!
    @IBOutlet weak var cityFirstCityLabel: UILabel!
    @IBOutlet weak var citySecondCityLabel: UILabel!
    
    var viewModel: CityViewModel?
    var sampleVM = RiveViewModel(fileName: "Snow")
        
    @IBAction func closeButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func openSideMenu(_ sender: Any) {
    }
    @IBAction func openMapsMenu(_ sender: Any) {
        let vc: CityPlacesViewController
        if Bundle.main.path(forResource: "CityPlacesViewController", ofType: "nib") != nil {
            vc = CityPlacesViewController(nibName: "CityPlacesViewController", bundle: .main)
        } else {
            vc = CityPlacesViewController()
        }
        // 현재 도시 정보 전달
        if let vm = viewModel {
            // Try to resolve Korean name from CityRecModel
            let model = CityRecModel()
            let info: CityDisplayInfo? = {
                if !vm.placeIDText.isEmpty { return model.displayInfo(forPlaceID: vm.placeIDText) }
                else { return model.displayInfo(for: vm.cityNameText) }
            }()
            vc.initialCityName = info?.cityKoreanName ?? vm.cityNameText
            vc.initialPlaceID = vm.placeIDText.isEmpty ? nil : vm.placeIDText
        }
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        sampleVM.setView(riveView)
        
        if let vm = viewModel {
            // Prefer Korean city name for the navigation title
            // Temporarily set to vm.cityNameText; we'll override below if display info exists
            self.title = vm.cityNameText

            // Resolve display info from CityRecModel using placeID first, then fallback to title
            let model = CityRecModel()
            let info: CityDisplayInfo? = {
                if !vm.placeIDText.isEmpty {
                    return model.displayInfo(forPlaceID: vm.placeIDText)
                } else {
                    return model.displayInfo(for: vm.cityNameText)
                }
            }()

            // cityKorLabel: 도시 한국어 이름
            if let info = info {
                // Set navigation title to Korean name
                self.title = info.cityKoreanName

                cityKorLabel.text = info.cityKoreanName
                cityKorLabel.isHidden = info.cityKoreanName.isEmpty

                // cityEngLabel: 도시 영어 이름
                cityEngLabel.text = info.cityEnglishName
                cityEngLabel.isHidden = info.cityEnglishName.isEmpty

                // cityTownLabel: 나라 유명한 마을 한국어
                if let town = info.famousTownKorean, !town.isEmpty {
                    cityTownLabel.text = town
                    cityTownLabel.isHidden = false
                } else {
                    cityTownLabel.text = nil
                    cityTownLabel.isHidden = true
                }

                // cityFirstCityLabel, citySecondCityLabel: 나라 유명한 도시 한국어 2개
                if let first = info.firstFamousCityKorean, !first.isEmpty {
                    cityFirstCityLabel.text = first
                    cityFirstCityLabel.isHidden = false
                } else {
                    cityFirstCityLabel.text = nil
                    cityFirstCityLabel.isHidden = true
                }
                if let second = info.secondFamousCityKorean, !second.isEmpty {
                    citySecondCityLabel.text = second
                    citySecondCityLabel.isHidden = false
                } else {
                    citySecondCityLabel.text = nil
                    citySecondCityLabel.isHidden = true
                }
            } else {
                // Fallback when no info is available
                cityKorLabel.text = vm.cityNameText
                cityKorLabel.isHidden = vm.cityNameText.isEmpty

                cityEngLabel.text = nil
                cityEngLabel.isHidden = true

                cityTownLabel.text = nil
                cityTownLabel.isHidden = true
                cityFirstCityLabel.text = nil
                cityFirstCityLabel.isHidden = true
                citySecondCityLabel.text = nil
                citySecondCityLabel.isHidden = true
            }
        }
    }
    
}

extension CityViewController {
    static func instantiate(with viewModel: CityViewModel) -> CityViewController {
        let vc: CityViewController
        if Bundle.main.path(forResource: "CityViewController", ofType: "nib") != nil {
            vc = CityViewController(nibName: "CityViewController", bundle: .main)
        } else {
            vc = CityViewController()
        }
        vc.viewModel = viewModel
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

