//
//  MapViewController.swift
//  Coordinatetest
//
//  Created by Karl Persson on 2016-01-13.
//  Copyright © 2016 Karl Persson. All rights reserved.
//
//  View controller used for handling MapKit map and its additional shapes
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
	@IBOutlet weak var mapSegmentControl: UISegmentedControl!
	@IBOutlet weak var mapView: MKMapView!
	
	// Design properties
	let nodeRadius: Double = 8.0
	let lineThickness: CGFloat = 1.5
	
	var endpoint = APIEndpoint()
	var nodes: [Node] = []
	var polygon: MKPolygon?
	var nodeCircles: [MKCircle] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Fetch coordinates and show on map
		endpoint.getNodes({ nodes, response, error in
			dispatch_async(dispatch_get_main_queue(), {
				self.nodes = nodes
				self.addPolygon()
				self.addNodeCircles()
				self.zoomToFit(true)
			})
		})
	}
	
	// Create polygon from nodes and add to map
	func addPolygon() {
		// Add node coordinates in correct order
		var coordinates: [CLLocationCoordinate2D] = []
		if let start = nodes.first {
			coordinates.append(start.coordinate)
			var next = start.next
			while next != start {
				guard next != nil else {
					break // Broken polygon
				}
				coordinates.append(next!.coordinate)
				next = next?.next
			}
		}
		
		// Create and add polygon to map
		polygon = MKPolygon(coordinates: &coordinates , count: coordinates.count)
		mapView.addOverlay(polygon!)
	}
	
	// Create node circles and add to map
	func addNodeCircles() {
		// Create coordinates
		for node in nodes {
			let circle = MKCircle(centerCoordinate: node.coordinate, radius: nodeRadius)
			nodeCircles.append(circle)
			mapView.addOverlay(circle)
		}
	}
	
	// Zoom map view to fit polygon
	func zoomToFit(animated: Bool) {
		if polygon != nil {
			mapView.setVisibleMapRect(polygon!.boundingMapRect, edgePadding: UIEdgeInsetsMake(50.0, 50.0, 50.0, 50.0), animated: animated)
		}
	}

	// Polygon/Node overlay renderers (delegate)
	func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay is MKPolygon {
			// Polygon renderer
			let view = MKPolygonRenderer(overlay: overlay)
			view.strokeColor = Colors.polygonStrokeColor
			view.fillColor = Colors.polygonFillColor
			view.lineWidth = lineThickness
			
			return view
		}
		else if overlay is MKCircle {
			// Node renderer
			let view = MKCircleRenderer(overlay: overlay)
			view.strokeColor = Colors.nodeStrokeColor
			view.fillColor = Colors.nodeFillColor
			view.lineWidth = lineThickness
			
			return view
		}
		
		return MKOverlayRenderer()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// Zoom button
	@IBAction func takeMeBack(sender: AnyObject) {
		zoomToFit(true)
	}
	
	// Map segment control
	@IBAction func selectMapType(sender: AnyObject) {
		switch mapSegmentControl.selectedSegmentIndex {
		case 0:
			mapView.mapType = .Standard
		case 1:
			mapView.mapType = .Satellite
		default:
			break
		}
	}
}

