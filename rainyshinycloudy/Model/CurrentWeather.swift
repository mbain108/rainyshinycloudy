//
//  CurrentWeather.swift
//  rainyshinycloudy
//
//  Created by Melissa Bain on 11/25/17. Updated 1/18/18.
//  Copyright © 2017 MB Consulting. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CurrentWeather {
    
    var _cityName: String!
    var _date: String!
    var _weatherType: String!
    var _currentTemp: Int!
    var _minimumTemp: Int!
    var _maximumTemp: Int!
    var _sunrise: Double!
    var _sunset: Double!
    
    var city: String = ""
    var weatherIconName: String = ""
    var description: String = ""
    var condition: Int = 0
    var temperature: Int = 0
    var minimumTemperature: Int = 0
    var maximumTemperature: Int = 0
    var sunriseTime: Double = 0.0
    var sunsetTime: Double = 0.0
    
    var cityName: String {
        
        if _cityName == nil {
            _cityName = ""
        }
        
        return _cityName
    }
    
    var date: String {
        
        if _date == nil {
            _date = ""
        }
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE MMMM, d"
        let convertDate: String = dateFormatter.string(from: currentDate)
        self._date = "\(convertDate)"
        
        return _date
    }
    
    var weatherType: String {
        
        if _weatherType == nil {
            _weatherType = ""
        }
        
        return _weatherType
    }
    
    var currentTemp: Int {
        
        if _currentTemp == nil {
            _currentTemp = 0
        }
        
        return _currentTemp
    }
    
    var minimumTemp: Int {
        
        if _minimumTemp == nil {
            _minimumTemp = 0
        }
        
        return _minimumTemp
    }
    
    var maximumTemp: Int {
        
        if _maximumTemp == nil {
            _maximumTemp = 0
        }
        
        return _maximumTemp
    }
    
    var sunrise: Double {
        
        if _sunrise == nil {
            _sunrise = 0.0
        }
        
        return _sunrise
    }
    
    var sunset: Double {
        
        if _sunset == nil {
            _sunset = 0.0
        }
        
        return _sunset
    }
    
    func downloadWeatherDetails(url: String, parameters: [String: String], completed: @escaping DownloadComplete) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            
            if response.result.isSuccess {
                
                let weatherJSON: JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJSON)
                
            } else {
                
                WeatherVC().locationLabel.text = "Connection Issues"
                
            }
        
            completed()
        }
    }
    
    func updateWeatherData(json: JSON) {
        
        let currentTemperature = json["main"]["temp"].doubleValue
        
        let kelvinToFarenheitPreDivision = (currentTemperature * (9/5) - 459.67)
        let kelvinToFarenheit = Double(round(10 * kelvinToFarenheitPreDivision/10))
        temperature = Int(kelvinToFarenheit)
        
        let minTemperature = json["main"]["temp_min"].doubleValue
        
        let minKelvinToFarenheitPreDivision = (minTemperature * (9/5) - 459.67)
        let minKelvinToFarenheit = Double(round(10 * minKelvinToFarenheitPreDivision/10))
        minimumTemperature = Int(minKelvinToFarenheit)
        
        let maxTemperature = json["main"]["temp_max"].doubleValue
        
        let maxKelvinToFarenheitPreDivision = (maxTemperature * (9/5) - 459.67)
        let maxKelvinToFarenheit = Double(round(10 * maxKelvinToFarenheitPreDivision/10))
        maximumTemperature = Int(maxKelvinToFarenheit)
        
        sunriseTime = json["sys"]["sunrise"].doubleValue
        sunsetTime = json["sys"]["sunset"].doubleValue
        
        city = json["name"].stringValue
        condition = json["weather"][0]["id"].intValue
        weatherIconName = updateWeatherIcon(condition: condition)
        description = json["weather"][0]["description"].stringValue
    }
    
    func updateWeatherIcon(condition: Int) -> String {
        
        switch (condition) {
            case 200...232:
                return "Thunderstorm"
            case 300...321:
                return "Drizzle"
            case 500...531:
                return "Rain"
            case 600...622:
                return "Snow"
            case 701...781:
                return "Haze"
            case 800:
                return "Clear"
            case 801...804:
                return "Clouds"
            default:
                return "dunno"
        }
    }
}
