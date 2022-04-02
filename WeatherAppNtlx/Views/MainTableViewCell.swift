//
//  MainTableViewCell.swift
//  WeatherAppNtlx
//
//  Created by Юрий Чекалюк on 29.03.2022.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    var delegate: MainViewControllerDelegate?
    
    //MARK: - IB Outlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var loadHistoryButton: UIButton!
    
    
    
    func configure(city: String, temperature: String, date: String, historyButtonVisible: Bool) {
        cityLabel.text = city
        temperatureLabel.text = temperature
        dateLabel.text = date
        loadHistoryButton.isHidden = historyButtonVisible
    }
    
    @IBAction func loadHistoryButtonTapped(_ sender: UIButton) {
        delegate?.fetchHistoryCities(city: cityLabel.text ?? "")
    }
    
    
}

