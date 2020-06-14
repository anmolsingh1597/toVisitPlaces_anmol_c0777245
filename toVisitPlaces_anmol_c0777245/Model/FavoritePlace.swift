//
//  FavoritePlace.swift
//  toVisitPlaces_anmol_c0777245
//
//  Created by Anmol singh on 2020-06-14.
//  Copyright © 2020 Swift Project. All rights reserved.
//

import Foundation


class FavoritePlace{
    var lat: Double
    var long: Double
    var speed: Double
    var course: Double
    var altitude: Double
    var address: String
    
    init(lat: Double, long: Double, speed: Double, course: Double, altitude: Double, address: String) {
        self.lat = lat
        self.long = long
        self.speed = speed
        self.course = course
        self.altitude = altitude
        self.address = address
    }
}
