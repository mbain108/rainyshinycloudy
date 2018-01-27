//
//  WeatherVC.swift
//  rainyshinycloudy
//
//  Created by Melissa Bain on 11/17/17. Updated 1/26/18.
//  Copyright © 2017 MB Consulting. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherVC: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, ChangeCityDelegate {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var currentWeatherTypeLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var minMaxTempLabel: UILabel!
    @IBOutlet weak var sunriseSunsetLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var currentWeather: CurrentWeather!
    var forecast: Forecast!
    var forecasts = [Forecast]()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            
            locationManager.requestLocation()
        } else {
            
            locationManager.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
        
    }
    
      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        Location.sharedInstance.latitude = userLocation.coordinate.latitude
        Location.sharedInstance.longitude = userLocation.coordinate.longitude
        
        let params: [String: String] = ["lat": String(Location.sharedInstance.latitude), "lon": String(Location.sharedInstance.longitude), "appid": API_KEY]
        
        currentWeather = CurrentWeather()
        
        currentWeather.downloadWeatherDetails(url: CURRENT_WEATHER_URL, parameters: params) {

            self.getForecastData(url: FORECAST_URL, parameters: params) {
                self.updateUIWithWeatherData()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Location.sharedInstance.latitude = 37.3230
        Location.sharedInstance.longitude = -122.0322
        
        let params: [String: String] = ["lat": String(Location.sharedInstance.latitude), "lon": String(Location.sharedInstance.longitude), "appid": API_KEY]
        
        currentWeather = CurrentWeather()
        
        currentWeather.downloadWeatherDetails(url: CURRENT_WEATHER_URL, parameters: params) {
            
            self.getForecastData(url: FORECAST_URL, parameters: params) {
                self.updateUIWithWeatherData()
            }
        }
    }
    
    func getForecastData(url: String, parameters: [String: String], completed: @escaping DownloadComplete) {

        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in

            if response.result.isSuccess {

                self.forecasts.removeAll()
                
                if let dict = response.result.value as? Dictionary<String, AnyObject> {

                    if let list = dict["list"] as? [Dictionary<String, AnyObject>] {

                        for element in list {
                            let forecast = Forecast(weatherDict: element)
                            self.forecasts.append(forecast)
                        }

                        self.tableView.reloadData()
                    }
                }
                completed()
            }
        }
    }
    
    func UTCToLocal(unixTimeStamp: Double) -> String {

        let date = Date(timeIntervalSince1970: unixTimeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "h:mm a"

        return dateFormatter.string(from: date)
    }
    
    func updateUIWithWeatherData() {

        locationLabel.text = currentWeather.city
        currentTempLabel.text = "\(currentWeather.temperature)° F"
        minMaxTempLabel.text = "h: \(currentWeather.maximumTemperature)°   l: \(currentWeather.minimumTemperature)° F"
        sunriseSunsetLabel.text = "↑ \(UTCToLocal(unixTimeStamp: currentWeather.sunriseTime))   ↓ \(UTCToLocal(unixTimeStamp: currentWeather.sunsetTime))"

        currentWeatherImage.image = UIImage(named: currentWeather.weatherIconName)
        currentWeatherTypeLabel.text = "\(currentWeather.description)"
        self.dateLabel.text = "\(currentWeather.date)"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return forecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as? WeatherCell {
            
            let forecast = forecasts[indexPath.row]
            cell.configureCell(forecast: forecast)
            
            return cell
        } else {
            
            return WeatherCell()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
    
        return .lightContent
    }
    
    func userEnteredANewCityName(city: String) {
        
        let newParams: [String: String] = ["q": city, "appid": API_KEY]
        
        currentWeather.downloadWeatherDetails(url: CURRENT_WEATHER_URL, parameters: newParams) {
            
            self.getForecastData(url: FORECAST_URL, parameters: newParams) {
                self.updateUIWithWeatherData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityVC
            
            destinationVC.delegate = self
        }
    }
}
