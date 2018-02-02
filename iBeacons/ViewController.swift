//
//  ViewController.swift
//  iBeacons
//
//  Created by James on 02/02/2018.
//  Copyright © 2018 Rantmedia Ltd. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UITableViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
	
	let locationManager = CLLocationManager()
	var foundBeacons = [CLBeacon]()
	
	var beaconRegion: CLBeaconRegion!
	
	var isRanging = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "iBeacons"
		
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
			print("Permission granted? \(granted)")
		}
		UNUserNotificationCenter.current().delegate = self
		
		locationManager.delegate = self
		
		let uuid = UUID(uuidString: "0fdb9b40-cf82-4362-ba5d-246f094f5c2a")!
		beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 101, minor: 2, identifier: uuid.uuidString)
				
		if CLLocationManager.authorizationStatus() != .authorizedAlways {
			locationManager.requestAlwaysAuthorization()
		} else {
			locationManager.startMonitoring(for: beaconRegion)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .authorizedAlways:
			if !locationManager.monitoredRegions.contains(beaconRegion) {
				locationManager.startMonitoring(for: beaconRegion)
			}
		case .authorizedWhenInUse:
			if !locationManager.monitoredRegions.contains(beaconRegion) {
				locationManager.startMonitoring(for: beaconRegion)
			}
		default:
			print("authorisation not granted")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		print("Did determine state for region \(region)")
		if state == .inside {
			locationManager.startRangingBeacons(in: beaconRegion)
			isRanging = true
			postNotification()
		} else {
			isRanging = false
		}
		
		tableView.reloadData()
	}
	
	func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
		print("Did start monitoring region: \(region)\n")
		tableView.reloadData()
	}
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		locationManager.startRangingBeacons(in: beaconRegion)
		print("didEnter")
		
		tableView.reloadData()
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		locationManager.stopRangingBeacons(in: beaconRegion)
		print("didExit")
		foundBeacons = []
		tableView.reloadData()
	}
	
	func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		foundBeacons = beacons
		foundBeacons.sort { beacon1, beacon2 -> Bool in
			beacon1.rssi < beacon2.rssi
		}
		
		
		tableView.reloadData()
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return foundBeacons.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return isRanging ? "Ranging Active" : "Ranging Inactive"
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconCell", for: indexPath) as! BeaconCell
		let beacon = foundBeacons[indexPath.row]
		cell.idLabel.text = beacon.proximityUUID.uuidString
		cell.majorLabel.text = "Major: \(beacon.major)"
		cell.minorLabel.text = "Minor: \(beacon.minor)"
		cell.unknown.layer.cornerRadius = cell.unknown.bounds.width / 2.0
		cell.far.layer.cornerRadius = cell.far.bounds.width / 2.0
		cell.near.layer.cornerRadius = cell.near.bounds.width / 2.0
		cell.immediate.layer.cornerRadius = cell.immediate.bounds.width / 2.0
		switch beacon.proximity {
		case .far:
			cell.unknown.isHidden = false
			cell.far.isHidden = false
			cell.near.isHidden = true
			cell.immediate.isHidden = true
		case .near:
			cell.unknown.isHidden = false
			cell.far.isHidden = false
			cell.near.isHidden = false
			cell.immediate.isHidden = true
		case .immediate:
			cell.unknown.isHidden = false
			cell.far.isHidden = false
			cell.near.isHidden = false
			cell.immediate.isHidden = false
		case .unknown:
			cell.unknown.isHidden = false
			cell.far.isHidden = true
			cell.near.isHidden = true
			cell.immediate.isHidden = true
		}
		
		return cell
	}
	
	func postNotification() {
		let content = UNMutableNotificationContent()
		content.title = "Welcome to Rantmedia!"
		content.body = "Enjoy your stay!"
		content.sound = UNNotificationSound.default()
		let request = UNNotificationRequest(identifier: "EntryNotification", content: content, trigger: nil)
		UNUserNotificationCenter.current().add(request) { error in
			if let error = error {
				print("Error: \(error.localizedDescription)")
			}
		}
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler(.alert)
	}
	
}

