//
//  WeatherCell.swift
//  rainyshinycloudy
//
//  Created by Melissa Bain on 11/17/17.
//  Copyright © 2017 MB Consulting. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherType: UILabel!
    @IBOutlet weak var highTemp: UILabel!
    @IBOutlet weak var lowTemp: UILabel!

    func configureCell(forecast: Forecast) {
        
        lowTemp.text = "l: \(forecast.lowTemp)°"
        highTemp.text = "h: \(forecast.highTemp)°"
        weatherType.text = forecast.weatherType
        weatherIcon.image = UIImage(named: forecast.weatherType)
        dayLabel.text = forecast.date
    }
}
