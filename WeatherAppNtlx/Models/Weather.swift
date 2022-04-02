//
//  Weather.swift
//  WeatherAppNtlx
//
//  Created by Юрий Чекалюк on 29.03.2022.
//

struct Weather: Decodable {
    let main: Main
    let name: String?
}

struct Main: Decodable {
    let temp: Double?
}
