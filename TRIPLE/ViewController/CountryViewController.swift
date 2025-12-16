//
//  CountryViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import UIKit
import RiveRuntime

class CountryViewController: UIViewController {
    @IBOutlet weak var mainView: RiveView!
    var sampleVM = RiveViewModel(fileName: "Snow")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sampleVM.setView(mainView)

    }
    
}
