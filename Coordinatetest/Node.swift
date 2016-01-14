//
//  Node.swift
//  Coordinatetest
//
//  Created by Karl Persson on 2016-01-14.
//  Copyright © 2016 Karl Persson. All rights reserved.
//
//  CLLocation-object with linked nodes.
//

import UIKit
import MapKit

class Node: CLLocation {
	var previous: Node?
	var next: Node?
}
