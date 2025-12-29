//
//  WeatherViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/23/25.
//

import UIKit
import RiveRuntime

class WeatherViewController: UIViewController {

    // MARK: - @IBOutlets
    @IBOutlet weak var riveView: RiveView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!

    // MARK: - 속성
    var viewModel: WeatherViewModel
    var riveVM = RiveViewModel(fileName: "Snow")

    // MARK: - 초기화
    /// 의존성 주입을 통한 초기화 (뷰모델을 외부에서 주입)
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    /// XIB 파일로부터 초기화 (뷰모델은 기본값으로 생성)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = WeatherViewModel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    /// XIB에서 로드될 때 사용되는 초기화
    required init?(coder: NSCoder) {
        self.viewModel = WeatherViewModel()
        super.init(coder: coder)
    }

    // MARK: - 팩토리 함수
    /// XIB 파일이 있으면 XIB로, 없으면 코드로 뷰 컨트롤러를 생성하는 팩토리 메서드
    static func instantiate(with viewModel: WeatherViewModel) -> WeatherViewController {
        let nibName = "WeatherViewController"
        let vc: WeatherViewController
        if Bundle.main.path(forResource: nibName, ofType: "nib") != nil {
            vc = WeatherViewController(nibName: nibName, bundle: Bundle.main)
            vc.viewModel = viewModel
        } else {
            vc = WeatherViewController(viewModel: viewModel)
        }
        vc.modalPresentationStyle = .fullScreen
        return vc
    }

    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        riveVM.setView(riveView)

        setupBindings()
        viewModel.loadWeather()
    }

    // MARK: - 바인딩
    /// 뷰모델의 출력을 UI 라벨에 연결하는 바인딩 메서드
    private func setupBindings() {
        viewModel.onUpdated = { [weak self] in
            guard let self = self else { return }
            self.cityLabel.text = self.viewModel.cityName
            self.tempLabel.text = self.viewModel.temperature
            self.weatherLabel.text = self.viewModel.description
        }
    }

    // MARK: - @IBActions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
