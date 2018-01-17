//
//  WeatherVC.swift
//  rainyshinycloudy
//
//  Created by Melissa Bain on 11/17/17. Updated 1/17/18.
//  Copyright © 2017 MB Consulting. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherVC: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
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
        
        setupLocationManager()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        currentWeather = CurrentWeather()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupLocationManager()
    }
    
    func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
        
            currentLocation = locationManager.location
            
            let latitude = String(currentLocation.coordinate.latitude)
            let longitude = String(currentLocation.coordinate.longitude)
            let params: [String: String] = ["lat": latitude, "lon": longitude, "appid": API_KEY]
            
            currentWeather.downloadWeatherDetails(url: CURRENT_WEATHER_URL, parameters: params) {

                // self.downloadForecastData {
                self.getForecastData(url: FORECAST_URL, parameters: params)
                self.updateUIWithWeatherData()
                // }
            }
        } else {
            locationLabel.text = "Need Authorization"
            
            if CLLocationManager.authorizationStatus() == .denied {
                
                let alert = UIAlertController(title: "Need Authorization", message: "This app is unusable if you don't authorize this app to use your location.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                    let url = URL(string: UIApplicationOpenSettingsURLString)!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func getForecastData(url: String, parameters: [String: String]) {

        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in

            if response.result.isSuccess {

                if let dict = response.result.value as? Dictionary<String, AnyObject> {

                    if let list = dict["list"] as? [Dictionary<String, AnyObject>] {

                        for element in list {

                            let forecast = Forecast(weatherDict: element)
                            self.forecasts.append(forecast)
                        }

                        self.forecasts.remove(at: 0)
                        self.tableView.reloadData()
                    }
                }
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
        dateLabel.text = "\(currentWeather.date)"
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
}
