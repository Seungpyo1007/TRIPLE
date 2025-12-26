//
//  WeatherViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/23/25.
//

import UIKit
import RiveRuntime

class WeatherViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var riveView: RiveView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!

    // MARK: - Properties
    /// ViewModel instance (DI-friendly)
    var viewModel: WeatherViewModel
    var riveVM = RiveViewModel(fileName: "Snow")

    // MARK: - Initializers
    // Dependency Injection
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = WeatherViewModel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        // Fallback for storyboard/XIB
        self.viewModel = WeatherViewModel()
        super.init(coder: coder)
    }

    // MARK: - Factory
    /// Convenience factory to load from nib if available
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        riveVM.setView(riveView)

        setupBindings()
        viewModel.loadWeather()
    }

    // MARK: - Binding
    /// Connects ViewModel outputs to UI labels
    private func setupBindings() {
        viewModel.onUpdated = { [weak self] in
            guard let self = self else { return }
            self.cityLabel.text = self.viewModel.cityName
            self.tempLabel.text = self.viewModel.temperature
            self.weatherLabel.text = self.viewModel.description
        }
    }

    // MARK: - Actions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
