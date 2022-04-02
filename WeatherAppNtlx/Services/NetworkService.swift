//
//  NetworkService.swift
//  WeatherAppNtlx
//
//  Created by Юрий Чекалюк on 29.03.2022.
//

import Foundation

enum RequestType {
    case cityName(city: String)
    case coordinate(latitude: Double, longitude: Double)
}
//MARK: - NetworkServiceProtocol
protocol NetworkServiceProtocol {
    func fetchCurrentWeather(for requestType: RequestType, completion: @escaping (Weather?) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    
    private let apiKey = "fa12b43efaac31a59f56cf50fc900364"
    
    func fetchCurrentWeather(for requestType: RequestType, completion: @escaping (Weather?) -> Void) {
        
        var urlString: String
        
        switch requestType {
        case .cityName(let city):
            urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        case .coordinate(let latitude, let longitude):
            urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        }
        
        print(urlString)
        
        performRequest(withURLString: urlString) { data, error in
            if let error = error {
                print("Error recieved requesting data: \(error.localizedDescription)")
                completion(nil)
            }
            let decode = self.decodeJSON(type: Weather.self, from: data)
            completion(decode)
        }
        
        
    }
    
    private func performRequest(withURLString urlString: String, completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "get"
        let task = createDataTask(from: request, completion: completion)
        task.resume()
    }
    
    private func createDataTask(from request: URLRequest, completion: @escaping (Data? , Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
    }
    
    private func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        let decoder = JSONDecoder()
        guard let data = from else { return nil }
        
        do {
            let objects = try decoder.decode(type.self, from: data)
            print(objects)
            return objects
        } catch let jsonError {
            print("Failed to decode JSON", jsonError)
            return nil
        }
    }
}
