//
//  Location.swift
//  rainyshinycloudy
//
//  Created by Melissa Bain on 11/17/17.
//  Copyright © 2017 MB Consulting. All rights reserved.
//

import CoreLocation

class Location {
    
    static var sharedInstance = Location()
    private init() {}
    
    var latitude: Double!
    var longitude: Double!
}
