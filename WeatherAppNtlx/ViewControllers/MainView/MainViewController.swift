//
//  ViewController.swift
//  WeatherAppNtlx
//
//  Created by Юрий Чекалюк on 23.03.2022.
//

import UIKit
import CoreLocation

//MARK: - MainViewControllerProtocol
protocol MainViewControllerDelegate {
    func fetchHistoryCities(city: String)
}

//MARK: - MainViewProtocol
protocol MainViewProtocol: AnyObject {
    func failure(error: Error)
    func showAlert()
}

class MainViewController: UIViewController {

    //MARK: - IB Outlets
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var temperatureChangeSwitch: UISwitch!

    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var cityLoadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tempLoadingActivitiIndicator: UIActivityIndicatorView!
    
    //MARK: - Private Properties
    private var conditionCode = 0.0
    private var latitude: Double = 0.0
    private var longitude: Double = 0.0
    
    //Location Manager
    private lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        lm.requestWhenInUseAuthorization()
        return lm
    }()
    
    private var presenter: MainViewPresenterProtocol!
    
    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupActivityIndicator()
        let storageService = StorageService()
        let networkService = NetworkService()
        presenter = MainViewPresenter(view: self, netwotkService: networkService, storageService: storageService)
        requestLocation()
        updateUI()
    }
    
    
    //MARK: - IB Actions
    @IBAction func searchByLocationButtonTapped(_ sender: UIBarButtonItem) {
        
        requestLocation()
        clearLabelsText()
        presenter.getCurrentWeather(requestType: .coordinate(latitude: latitude, longitude: longitude))
        setupActivityIndicator()
        updateUI()
        presenter.fetchDataFromMemory()
        mainTableView.reloadData()
    }
    
    @IBAction func TemperatureConvertSwitchToggled(_ sender: UISwitch) {
        temperatureChangeSwitch.isOn ? convertTemperatureToC() :  convertTemperatureToF()
        mainTableView.reloadData()
    }
    
    //MARK: - Private Methods
    private func setupActivityIndicator() {
        cityLoadingActivityIndicator.startAnimating()
        cityLoadingActivityIndicator.hidesWhenStopped = true
        tempLoadingActivitiIndicator.startAnimating()
        tempLoadingActivitiIndicator.hidesWhenStopped = true
    }
    
    private func setupSearchBar() {
        let seacrhController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = seacrhController
        navigationItem.hidesSearchBarWhenScrolling = false
        seacrhController.hidesNavigationBarDuringPresentation = false
        seacrhController.obscuresBackgroundDuringPresentation = false
        seacrhController.searchBar.delegate = self
    }
    
    private func updateUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.cityLoadingActivityIndicator.stopAnimating()
            self.tempLoadingActivitiIndicator.stopAnimating()
            self.conditionCode = self.presenter.weather?.main.temp ?? 0
            self.cityNameLabel.text = self.presenter.weather?.name
            self.temperatureLabel.text = String(format: "%.1f", self.conditionCode) + "º"
            self.updateColorMainView()
        }
    }
    
    private func updateColorMainView() {
        var mainViewColor: UIColor {
            switch conditionCode {
            case -100.00...9.99: return #colorLiteral(red: 0.356584847, green: 0.7869387865, blue: 0.9794784188, alpha: 1)
            case 10.00...24.99: return #colorLiteral(red: 0.9563025832, green: 0.6592767835, blue: 0.5453029871, alpha: 1)
            default: return .red
            }
        }
        view.backgroundColor = mainViewColor
    }
    
    private func convertTemperatureToF() {
        temperatureLabel.text = String(format: "%.1f", 32 + self.conditionCode * 1.8) + "º"
    }
    
    private func convertTemperatureToC() {
        temperatureLabel.text = String(format: "%.1f", self.conditionCode) + "º"
    }
    
    private func clearLabelsText() {
        cityNameLabel.text = ""
        temperatureLabel.text = ""
    }
    
    private func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        } else {
            showAlert(with: "Нет сети", and: "")
        }
    }
    
    private func saveCity() {
            presenter.saveCity(
            name: presenter.weather?.name ?? "",
            temperature: presenter.weather?.main.temp ?? 0.0,
            date: Date()
        )
    }
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
}

//MARK: - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.fetchDataFromMemory()
        mainTableView.reloadData()
        presenter.getCurrentWeather(requestType: .cityName(city: searchBar.searchTextField.text ?? ""))
        clearLabelsText()
        setupActivityIndicator()
        updateUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.saveCity()
        }
        
    }
}


//MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.cities?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
        
        let city = presenter.cities?.reversed()[indexPath.row]
        
        var formattedDate: String?
        if let date = city?.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy HH:mm:ss"
            dateFormatter.locale = Locale.current
            formattedDate = dateFormatter.string(from: date)
        }
        
        let tempCelsius = ", \(city?.temperature ?? 0.0)ºC"
        
        var temperature: Double?
     
        if let temp = city?.temperature {
            temperature = temp * 1.8 + 32
        }
        
        let tempFarenheits = ", \(temperature ?? 0.0)ºF)"
        
        var convertedText: String {
            temperatureChangeSwitch.isOn ? tempCelsius : tempFarenheits
        }
    
        cell.configure(city: city?.name ?? "", temperature: convertedText, date: formattedDate ?? "", historyButtonVisible: true)
        cell.delegate = self
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        print("Широта: \(latitude) | Долгота: \(longitude)")
        presenter.getCurrentWeather(requestType: .coordinate(latitude: latitude, longitude: longitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

//MARK: - MainViewProtocol
extension MainViewController: MainViewProtocol {
    func failure(error: Error) {
        showAlert(with: "Ошибка", and: "Ошибка загрузки данных \(error)")
    }
    
    func showAlert() {
        showAlert(with: "Ошибка", and: "Город не найден")
        clearLabelsText()
    }
    
}


extension MainViewController: MainViewControllerDelegate {
    func fetchHistoryCities(city: String) {
        presenter.fetchDuplicates(city: city)
        mainTableView.reloadData()
    }
    
}
