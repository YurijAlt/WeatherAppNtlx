//
//  StorageService.swift
//  WeatherAppNtlx
//
//  Created by Юрий Чекалюк on 29.03.2022.
//

import Foundation
import CoreData

protocol StorageServiceProtocol {
    func fetchCitySearchHistory(completion: (Result<[CityWeather], Error>) -> Void)
    func fetchDuplicateCitiesHistory(city: String, completion: (Result<[CityWeather], Error>) -> Void)
    func save(_ name: String, temperature: Double, date: Date)
    func saveContext()
}

class StorageService: StorageServiceProtocol {
    //MARK: - CoreData Stack
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SavedCity")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let viewContext: NSManagedObjectContext
    init() {
        viewContext = persistentContainer.viewContext
    }
    
    //MARK: - Fetch Request
    func fetchCitySearchHistory(completion: (Result<[CityWeather], Error>) -> Void) {
        
        let fetchRequest: NSFetchRequest<CityWeather> = CityWeather.fetchRequest()
        do {
            let savedCities = try viewContext.fetch(fetchRequest)
            completion(.success(savedCities))
        } catch let error {
            completion(.failure(error))
        }
    }

    func fetchDuplicateCitiesHistory(city: String, completion: (Result<[CityWeather], Error>) -> Void) {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(CityWeather.name), city)
        let fetchRequest: NSFetchRequest<CityWeather> = CityWeather.fetchRequest()
        fetchRequest.predicate = predicate
        do {
            let savedCities = try viewContext.fetch(fetchRequest)
            completion(.success(savedCities))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    //MARK: Save and delete Data
    func save(_ name: String, temperature: Double, date: Date) {
        let city = CityWeather(context: viewContext)
        city.name = name
        city.temperature = temperature
        city.date = date
        saveContext()
    }
        
    func delete(_ savedCity: CityWeather) {
        viewContext.delete(savedCity)
        saveContext()
    }
    
    // MARK: CoreData saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
}
