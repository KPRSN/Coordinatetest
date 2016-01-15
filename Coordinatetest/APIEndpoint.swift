//
//  APIEndpoint.swift
//  Coordinatetest
//
//  Created by Karl Persson on 2016-01-13.
//  Copyright © 2016 Karl Persson. All rights reserved.
//
//  Endpoint for connecting to the coordinate API, converting JSON data to tree of Nodes.
//  Basic authentication using credentials.
//
//  Example data (JSON):
//  [
//		{
//			"Lat": 1.0,
//			"Lng": 2.0
//		},
//		{
//			"Lat": 1.0,
//			"Lng": 2.0
//		}
//  ]
//

import UIKit
import MapKit

class APIEndpoint: NSObject, NSURLSessionTaskDelegate {
	var host: NSURL!
	var user: String!
	var password: String!
	
	// Initialize with host, user and password from Keys.plist as follows:
	// host: String
	// user: String
	// password: String
	override init() {
		// Initialize endpoint from Keys.plist
		if let path = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: String] {
			self.host = NSURL(string: dict["host"]!)!
			self.user = dict["user"]!
			self.password = dict["password"]!
		}
	}
	
	// Initialize with url and user credentials
	init(host: NSURL, user: String, password: String) {
		self.host = host
		self.user = user
		self.password = password
	}
	
	// Handle authentication
	func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
		// Try authenticating once before cancelling
		if challenge.previousFailureCount == 0 {
			completionHandler(.UseCredential, NSURLCredential(user: user, password: password, persistence: .None))
		}
		else {
			completionHandler(.CancelAuthenticationChallenge, nil)
		}
	}
	
	// Fetch and parse coordinates from server
	func getNodes(completionHandler: (([Node], NSURLResponse?, ErrorType?) -> Void)) {
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		
		// JSON request
		let request = NSMutableURLRequest(URL: host)
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		
		let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
		let task = session.dataTaskWithRequest(request) { data, response, error in
			// Handle result
			if error == nil {
				do {
					if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [[String: AnyObject]] {
						// Parse, connect and return nodes from JSON data
						let nodes = APIEndpoint.parseJSON(json)
						APIEndpoint.connectNodes(nodes)
						completionHandler(nodes, response, error)
					}
				}
				catch {
					
				}
			}
		}
		task.resume()
	}
	
	// Parse JSON into nodes
	private static func parseJSON(json: [[String: AnyObject]]) -> [Node] {
		var nodes: [Node] = []
		
		for coordinate in json {
			if let lat = coordinate["Lat"] as? Double, lng = coordinate["Lng"] as? Double {
				nodes.append(Node(latitude: lat, longitude: lng))
			}
		}
		
		return nodes
	}
	
	// Connect nodes into a looping minimum spanning tree (greedy)
	private static func connectNodes(nodes: [Node]) {
		var remaining = Array(nodes)
		var previous: Node?
		var current = remaining.first!
		
		while remaining.count > 0 {
			remaining.removeAtIndex(remaining.indexOf(current)!)
			
			// Set previous node
			current.previous = previous
			
			// Set next node
			if remaining.count > 0 {
				var closest = remaining.first!
				var closestDistance = current.distanceFromLocation(closest)
				
				// Find closest remaining node
				for n in remaining {
					let distance = current.distanceFromLocation(n)
					if distance < closestDistance {
						closest = n
						closestDistance = distance
					}
				}
				
				current.next = closest
			}
			else {
				// Last node, connect back to start (loop)
				current.next = nodes.first
				nodes.first?.previous = current.next
			}
			
			// Update current/next node
			previous = current
			current = current.next!
		}
	}
}
