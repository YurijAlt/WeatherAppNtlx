//
//  MainViewPresenter.swift
//  WeatherAppNtlx
//
//  Created by Юрий Чекалюк on 29.03.2022.
//

import Foundation

//MARK: - MainViewPresenterProtocol
protocol MainViewPresenterProtocol {
    init(view: MainViewProtocol, netwotkService: NetworkServiceProtocol, storageService: StorageServiceProtocol)
    func getCurrentWeather(requestType: RequestType)
    func fetchDataFromMemory()
    
    func fetchDuplicates(city: String)
    
    func saveCity(name: String, temperature: Double, date: Date)
    var weather: Weather? { get set }
    var cities: [CityWeather]? { get set }
}

class MainViewPresenter: MainViewPresenterProtocol {

    unowned let view: MainViewProtocol
    let netwotkService: NetworkServiceProtocol!
    let storeService: StorageServiceProtocol!
    var weather: Weather?
    var cities: [CityWeather]?
    
    required init(view: MainViewProtocol, netwotkService: NetworkServiceProtocol, storageService storageSevice: StorageServiceProtocol) {
        self.view = view
        self.netwotkService = netwotkService
        self.storeService = storageSevice
        fetchDataFromMemory()
    }
    
    func getCurrentWeather(requestType: RequestType) {
        netwotkService.fetchCurrentWeather(for: requestType) { weather in
            self.weather = weather
            if self.weather == nil {
                self.view.showAlert()
            }
        }
    }
    
    func fetchDataFromMemory() {
        storeService.fetchCitySearchHistory { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let cities):
                self.cities = cities
            case .failure(let error):
                self.view.failure(error: error)
                
            }
        }
    }
    
    func fetchDuplicates(city: String) {
        storeService.fetchDuplicateCitiesHistory(city: city) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let cities):
                self.cities = cities
            case .failure(let error):
                self.view.failure(error: error)
                
            }
        }
    }
    
    
    
    func saveCity(name: String, temperature: Double, date: Date) {
        storeService.save(name, temperature: temperature, date: date)
    }
    
}
