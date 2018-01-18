//
//  ChangeCityVC.swift
//  rainyshinycloudy
//
//  Created by Melissa Bain on 1/17/18.
//  Copyright © 2018 MB Consulting. All rights reserved.
//

import UIKit

protocol ChangeCityDelegate {
    
    func userEnteredANewCityName(city: String)
}

class ChangeCityVC: UIViewController {
 
    var delegate: ChangeCityDelegate?
    
    @IBOutlet weak var changeCityTextField: UITextField!
    
    @IBAction func getWeatherPressed(_ sender: Any) {
        
        let cityName = changeCityTextField.text!
        
        delegate?.userEnteredANewCityName(city: cityName)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
