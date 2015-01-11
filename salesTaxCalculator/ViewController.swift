//
//  ViewController.swift
//  salesTaxCalculator
//
//  Created by Snehal Dhadge on 14/12/14.
//  Copyright (c) 2014 Snehal Dhadge. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {

    var rc:Int32=0
    var db:COpaquePointer = nil
    var statement:COpaquePointer = nil
    var manager:CLLocationManager!=nil
    var tax_rate:Double = 0
    var locality:String = " "
    var state:String = " "
    @IBOutlet var Final_Amount: UITextField!
    @IBOutlet var Amount_Label: UILabel!
    @IBOutlet var Tax_Label: UILabel!
    @IBOutlet var Tax_Amount: UITextField!
    @IBOutlet var price: UITextField!
    @IBAction func CalculateTax(sender: AnyObject) {
        price.resignFirstResponder()
        if(rc == 0)
        {
            var query_stmt = "SELECT tax_rate FROM state where state_name like '\(state)' and county_name like '\(locality)'"
            if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, nil) == SQLITE_OK)
            {
                while(sqlite3_step(statement) == SQLITE_ROW)
                {
                    tax_rate = sqlite3_column_double(statement,0)
                }
                
            }
            sqlite3_reset(statement)
        }
        else
        {
            println("DB Not Found")
        }
        
        var orig_price = (price.text as NSString).doubleValue
        if (orig_price > 0)
        {
            var final_p = orig_price + (orig_price * (tax_rate/100))
            Amount_Label.text = "Final Amount with tax is:"
            Final_Amount.text = "\(final_p)"
            var tax_component = (orig_price * (tax_rate/100))
            Tax_Label.text = "Tax based on \(locality) is:"
            Tax_Amount.text = "\(tax_component)"
        }
        
    }
    
    
    @IBAction func OnClickClear(sender: AnyObject) {
        price.text = " "
        Amount_Label.text = " "
        Final_Amount.text = " "
        Tax_Label.text = " "
        Tax_Amount.text = " "
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rc = sqlite3_open("/Users/snehaldhadge/Desktop/Niranjan documents/salesTaxCalculator/salesTaxCalculator/sales_tax.db",&db)
        if(rc == 0)
        {
            println("DB Opened")
        }
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        
        manager.requestAlwaysAuthorization()
       // manager.startUpdatingLocation()
      
        
    }
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            var shouldIAllow = false
            var locationStatus : NSString = "Not Started"
            switch status {
            case CLAuthorizationStatus.Restricted:
                locationStatus = "Restricted Access to location"
            case CLAuthorizationStatus.Denied:
                locationStatus = "User denied access to location"
            case CLAuthorizationStatus.NotDetermined:
                locationStatus = "Status not determined"
            default:
                locationStatus = "Allowed to location Access"
                shouldIAllow = true
            }
            NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
            if (shouldIAllow == true) {
                NSLog("Location to Allowed")
                // Start location services
                manager.startUpdatingLocation()
            } else {
                println("Denied access: \(locationStatus)")
            }
                       // gpsResult.text = "success "
            
            //manager.startUpdatingLocation()
            
            
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                println("Reverse geocoder failed with error \(error.localizedDescription)")
                return
            }
           
            if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                println("Problem with the data received from geocoder")
            }
        })
    }
    func displayLocationInfo(placemark: CLPlacemark) {
        if placemark != 0 {
            //stop updating location to save battery life
            manager.stopUpdatingLocation()
            println("placemark.locality:\(placemark.locality)")
            println("placemark.postalCode:\(placemark.postalCode)")
            //  println(placemark.administrativeArea ? placemark.administrativeArea : “”)
            println("placemark.country:\(placemark.country)")
            locality = placemark.locality
            state = placemark.administrativeArea
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

