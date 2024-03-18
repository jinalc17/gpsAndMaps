//
//  ViewController.swift
//  GpsAndMaps
//
//  Created by user239775 on 3/14/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate  {
    
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var maxAccelerationLabel: UILabel!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomBar: UIView!
    
    let locationManager = CLLocationManager()
    var tripStartDate: Date?
    var previousLocation: CLLocation?
    var timeElapsed: Double = 0.0
    var tripDistance: CLLocationDistance = 0
    var maxSpeed: CLLocationSpeed = 0
    var averageSpeed: CLLocationSpeed = 0
    var totalSpeed: CLLocationSpeed = 0
    var maxAcceleration: Double = 0.0
    var previousSpeed: CLLocationSpeed = 0
    var isTripStarted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
    }
    
    
    @IBAction func startTrip(_ sender: Any) {
        tripStartDate = Date()
        locationManager.startUpdatingLocation()
        isTripStarted = true
        //set bottombar background
        bottomBar.backgroundColor = UIColor.green
    }
    
    
    @IBAction func stopTrip(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        tripStartDate = nil
        // Reset top bar and bottom bar background
        bottomBar.backgroundColor = UIColor.gray
        topBar.backgroundColor = UIColor.clear
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Stop updating if trip hasn't started
        guard isTripStarted else { return }
        
        guard let newLocation = locations.last else { return }
        let currentSpeed = newLocation.speed
        print("Current speed: \(currentSpeed)")
        
        // Update current speed label
        currentSpeedLabel.text = "\(Int(currentSpeed * 3.6)) km/h"
        
        // Update max speed label
        if currentSpeed > maxSpeed {
            maxSpeed = currentSpeed
            maxSpeedLabel.text = "\(Int(maxSpeed * 3.6)) km/h"
        }
        print("Max speed: \(maxSpeed)")
        
        // Calculate trip distance and update distance label
        if let prevLocation = previousLocation {
            let distance = newLocation.distance(from: prevLocation) / 1000 // Convert meters to kilometers
            tripDistance += distance
            distanceLabel.text = "\(String(format: "%.2f", tripDistance)) km"
        }
        
        print("Distance: \(tripDistance)")
        
        previousLocation = newLocation
        
        // Calculate total time elapsed
        timeElapsed = newLocation.timestamp.timeIntervalSince(tripStartDate ?? Date())
        
        print("Time Elapsed: \(timeElapsed)")
        
        // Calculate average speed
        if timeElapsed > 0 {
            averageSpeed = tripDistance / timeElapsed * 3.6 // Convert from m/s to km/h
            averageSpeedLabel.text = String(format: "%.2f km/h", averageSpeed)
        }
        
        print("Average Speed: \(averageSpeed)")
        
        // Calculate acceleration using distance travelled over time
        let acceleration = (2 * tripDistance) / Double(timeElapsed)

        // Update max acceleration if the current acceleration exceeds it
        if acceleration > maxAcceleration {
            maxAcceleration = acceleration
        }
        // Update the max acceleration label
        maxAccelerationLabel.text = String(format: "%.2f m/s^2", maxAcceleration)
        print("Max Acceleration: \(averageSpeed)")
        
        // Update top bar color if speed exceeds 115 km/h
        topBar.backgroundColor = currentSpeed > (115.0 / 3.6) ? UIColor.red : UIColor.clear
        
        // Calculate time to reach speed limit
        let timeToReachSpeedLimit = (115.0 / 3.6 - currentSpeed) / acceleration
        // Calculate distance traveled during that time
        let distanceToSpeedLimit = currentSpeed * timeToReachSpeedLimit + 0.5 * acceleration * timeToReachSpeedLimit * timeToReachSpeedLimit
        // Convert distance to kilometers
        let distanceToSpeedLimitKm = distanceToSpeedLimit / 1000.0
        print("Distance before the speed limit 115 km/h: \(distanceToSpeedLimitKm) kilometers")
        
        // Update map view
        mapView.setCenter(newLocation.coordinate, animated: true)
        let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        // Update previous speed
        previousSpeed = currentSpeed
    }
    
}
