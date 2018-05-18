//
//  ViewController.swift
//  SunriseSunset app
//
//  Created by George Heints on 17.05.2018.
//  Copyright © 2018 George Heints. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import GooglePlaces
import SystemConfiguration

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {


    //IBOutlets
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet var currentLocation: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    //IBActions
    @IBAction func searchWithAddress(_ sender: AnyObject) {

        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        present(placePickerController, animated: true, completion: nil)

    }
    //CLLocationManager
    var locationManager:CLLocationManager!
    //GMSAutocompleteResultsViewController
    var resultsViewController: GMSAutocompleteResultsViewController?


    override func viewDidLoad() {
        super.viewDidLoad()

        locationInit()

    }

    //Location setUp.
    func locationInit(){
        if ConnectionCheck.isConnectedToNetwork() {
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.alpha = 0.2

            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()

            if CLLocationManager.locationServicesEnabled(){
                locationManager.startUpdatingLocation()
            }
        }
        else{
            resetForm()
        }

    }

    //location manager to get user current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation

        self.latitudeLabel.text = "\(userLocation.coordinate.latitude)"
        self.longitudeLabel.text = "\(userLocation.coordinate.longitude)"

        //Longitude and latitude variables
        let latidute: String = "\(userLocation.coordinate.latitude)"
        let longitude: String = "\(userLocation.coordinate.longitude)"

        getDataFromApi(lng: longitude, lat: latidute)   //get JSON func

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                self.currentLocation.text = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
            }
        }

    }

    //Get data from API using lng - langitude and lat - latitude from locationManager func.
    func getDataFromApi(lng: String, lat: String){
        Alamofire.request("https://api.sunrise-sunset.org/json?lat=\(lat)&lng=\(lng)").responseJSON{ response in

            if let locationJSON = response.result.value{
                let locationObject: Dictionary = locationJSON as! Dictionary<String, Any>
                let resultObject: Dictionary = locationObject["results"] as! Dictionary<String, Any>
                let resultSunrise: String = resultObject["sunrise"] as! String
                let resultSunset: String = resultObject["sunset"] as! String

                self.sunriseLabel.text = "Sunrise: \(resultSunrise)"
                self.sunsetLabel.text = "Sunset: \(resultSunset)"
            }
        }
    }

    //Loose connection alert
    func resetForm() {
        let alert = UIAlertController(title: "Check your internet connection", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
// Handle the user's selection.
extension ViewController: GMSAutocompleteViewControllerDelegate {

    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //Coordinates
        let latitude:String = "\(place.coordinate.latitude)"
        let longitude:String = "\(place.coordinate.longitude)"

        //Display data on labels
        self.currentLocation.text = "\(place.name)"
        self.latitudeLabel.text = latitude
        self.longitudeLabel.text = longitude
        //Get Dara From API
        getDataFromApi(lng: latitude, lat: longitude)
        dismiss(animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }

    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

}


