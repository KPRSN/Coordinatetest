# Coordinatetest
Rendering a polygon shape of coordinates using MapKit in iOS 9.

* Fetch coordinates from an API endpoint (JSON)
* Parse JSON into linked node objects, where each node is connected its closest neighbors creating a shape.
* Display polygon shape of all connected nodes, as well as each individual node, on the map.

![alt text](Screenshots/coordinatetest.png "Screenshot")

## Usage
The application is currently setup with basic http authentication in mind, reading host, user and password as string values from resource Keys.plist. The requested JSON data is expected to contain coordinates on the following form:
```
[
  {
    "Lat": 1.0,
    "Lng": 2.0
  },
  {
    "Lat": 1.0,
    "Lng": 2.0
  }
]
```
