//
//  MainUINavigationController.swift
//  WeatherAppNtlx
//
//  Created by Юрий Чекалюк on 29.03.2022.
//

import UIKit

class MainUINavigationController: UINavigationController {

    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .white
        navigationBar.standardAppearance = navBarAppearance
        navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.layoutIfNeeded()
    }
}
