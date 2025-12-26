//
//  IntroViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/24/25.
//

import UIKit
import RiveRuntime

class IntroViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var riveView: RiveView!
    
    // MARK: - Properties
    var riveVM = RiveViewModel(fileName: "Globe")
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        riveVM.setView(riveView)
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: - Actions
    @IBAction func loginButton(_ sender: Any) {
        let vc: UIViewController
        if Bundle.main.path(forResource: "LoginViewController", ofType: "nib") != nil {
            vc = LoginViewController(nibName: "LoginViewController", bundle: .main)
        } else {
            vc = LoginViewController()
        }
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        }
    }
}
