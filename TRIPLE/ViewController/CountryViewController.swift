//
//  CountryViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import UIKit
import RiveRuntime

class CountryViewController: UIViewController {
    @IBOutlet weak var riveView: RiveView!
    
    @IBOutlet weak var countryKorLabel: UILabel!
    @IBOutlet weak var countryEngLabel: UILabel!
    @IBOutlet weak var countryTownLabel: UILabel!
    @IBOutlet weak var countryFirstCityLabel: UILabel!
    @IBOutlet weak var countrySecondCityLabel: UILabel!
    
    var sampleVM = RiveViewModel(fileName: "Snow")
        
    @IBAction func closeButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func openSideMenu(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        sampleVM.setView(riveView)
        
    }
    
}
