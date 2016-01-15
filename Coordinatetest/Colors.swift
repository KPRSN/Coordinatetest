//
//  Colors.swift
//  Coordinatetest
//
//  Created by Karl Persson on 2016-01-14.
//  Copyright © 2016 Karl Persson. All rights reserved.
//
//  Static colors used in the application
//

import UIKit

struct Colors {
	// Global tint color
	static let tintColor = UIColor(red: 0.027, green: 0.133, blue: 0.18, alpha: 1)
	
	// Polygon/node colors
	static let polygonFillColor = UIColor(red: 0.027, green: 0.133, blue: 0.18, alpha: 0.2)
	static let polygonStrokeColor = tintColor
	static let nodeFillColor = UIColor.whiteColor()
	static let nodeStrokeColor = tintColor
}