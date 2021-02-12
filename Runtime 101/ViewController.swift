// Copyright 2020 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import ArcGIS

class ViewController: UIViewController {
    @IBOutlet weak var mapView: AGSMapView!
    
    // An AGSLocatorTask allows us to go geocoding/reverse geocoding, etc. Here
    // we connect to our hosted, free, World Geocoder service.
    let locatorTask = AGSLocatorTask(
        url: URL(string: "https://geocode-api.arcgis.com/arcgis/rest/services/World/GeocodeServer")!
    )

    // We want somewhere to show geocode result location. We'll show it in an
    // AGSGraphicsOverlay on the AGSMapView.
    let locationOverlay = AGSGraphicsOverlay()
    
    // An AGSRouteTask allows us to solve routes and get directions. Here we
    // connet to our hosted, for pay, World Routing service.
    // Because it's not free, we require credentials to access it. These can be
    // obtained via OAuth or, as in this case, by using a simple username and
    // password. However it's obtained, it's represented in Runtime as an
    // AGSCredential.
    let routeTask = AGSRouteTask(
        url: URL(string: "https://route-api.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World")!
    )

    // We want somewhere to show route results. As with geocode results, we'll
    // show them in an AGSGraphicsOverlay on the AGSMapView.
    // However, in this case we'll tell the overlay how to display graphics
    // added to it. For the geocoding, we set the symbol on each graphic we
    // added. Another approach is just to set the geometry on the graphic and
    // let the AGSRenderer handle how that geometry is displayed.
    // In this case it's a simple style that doesn't vary from one graphic to
    // the next, but there are various renderers available that interrogate a
    // graphic's attributes dictionary to vary the style from one graphic to the
    // next. For example, we could display journeys of less than 10 minutes in
    // green, and all other journeys in red.
    let routeOverlay: AGSGraphicsOverlay = {
        let overlay = AGSGraphicsOverlay()
        
        // Create a symbol for geocode results.
        let lineSymbol = AGSSimpleLineSymbol(style: .solid, color: .orange, width: 10)
        // Set up the graphics overlay rendered with that symbol.
        overlay.renderer = AGSSimpleRenderer(symbol: lineSymbol)
        
        return overlay
    }()
    
    func makeMap() -> AGSMap {
        let map = AGSMap(basemapStyle: .arcGISNavigation)

        // Add some data to the map from a hosted feature service. A Feature
        // is a geographic data item from some data table. The Feature
        // could be a point, line or polygon. The source data table could be
        // hosted somewhere (e.g. ArcGIS Online) or some sort of local file
        // (like a Shapefile). Depending on the data source and its
        // configuration, the Feature Layer and Feature Table can work together
        // to define how the data from that table will be displayed on the map
        // (symbology, filters, popup definitions to show attributes, etc.).
        // An ArcGIS Feature Service (from ArcGIS Online, or an on-premise
        // ArcGIS Enterprise server) can self-describe this way. Runtime will
        // automatically take advantage of that where possible, and you also
        // have great control over these aspects via the Runtime's API.
        
        // First, we connect to the hosted feature service.
        let featureTable = AGSServiceFeatureTable(url: URL(string: "https://services.arcgis.com/OfH668nDRN7tbJh0/arcgis/rest/services/Palm_Springs_Shortlist/FeatureServer/0")!)
        // Next we create a feature layer that represents that table's contents
        // on the map.
        let featureLayer = AGSFeatureLayer(featureTable: featureTable)
        // Lastly we add that layer to the map itself.
        map.operationalLayers.add(featureLayer)
        
        return map
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // You might more typically set your API key in the AppDelegate
        AGSArcGISRuntimeEnvironment.apiKey = "YOUR-API-KEY"
        
        mapView.map = makeMap()
        
        mapView.setViewpoint(
            AGSViewpoint(latitude: 33.82496, longitude: -116.53862, scale: 18055.954822)
        )
        
        // Add the graphics overlay for geocode result location to the map view.
        mapView.graphicsOverlays.add(locationOverlay)
        
        // Add the graphics overlay for route results to the map view.
        mapView.graphicsOverlays.add(routeOverlay)
        
        mapView.touchDelegate = self
        
        // Configure the callout to tell us when it's been interacted with and
        // change the accessory button image.
        mapView.callout.delegate = self
        mapView.callout.accessoryButtonImage = UIImage(systemName: "arrow.up.right.diamond.fill")
        
        // Start up location services (see also the info.plist addition for
        // "When In Use" permissions).
        mapView.locationDisplay.start() { [weak self] (error) in
            if let error = error {
                self?.showAlert(title: "GPS Issue", message: error.localizedDescription)
            }
        }
    }
}

extension ViewController: AGSCalloutDelegate {
    func didTapAccessoryButton(for callout: AGSCallout) {
        guard let feature = callout.representedObject as? AGSFeature,
            let featureLocation = feature.geometry as? AGSPoint else { return }
        
        // Note that if we’ve already retrieved the default route parameters
        // once, this will just return and not re-fetch them; i.e., the
        // parameters are cached.
        routeTask.defaultRouteParameters { [weak self] (routeParameters, error) in
            guard let self = self else { return }
            
            guard let routeParameters = routeParameters else {
                if let error = error {
                    self.showAlert(title: "Route Parameters Error", message: error.localizedDescription)
                }
                return
            }
            
            guard let mapLocation = self.mapView.locationDisplay.mapLocation else {
                self.showAlert(title: "Error", message: "Unable to get device location.")
                return
            }

            // Ensure the geometry we get back is projected for the
            // current map display. In this case, it doesn't matter too
            // much - Runtime will easily handle the projection on the
            // fly, but it's good practice to ask a service to give you
            // back geometry in a projection that will allow the client
            // to just show it and not have to do work each time.
            routeParameters.outputSpatialReference = self.mapView.spatialReference

            // Let's get detailed turn-by-turn directions returned as
            // well as the overall route summary.
            routeParameters.returnDirections = true

            // Set up stops (just 2 in this case, but AGSRouteTask can
            // handle many). By assigning names, the turn-by-turn
            // directions will look nicer.
            let start = AGSStop(point: mapLocation)
            start.name = "your location"
            let end = AGSStop(point: featureLocation)
            end.name = (feature.attributes["Name"] as? String) ?? "your destination"
            routeParameters.setStops([start, end])
            
            // Now simply call "solveRoute", and handle the response in
            // the callback block.
            self.routeTask.solveRoute(with: routeParameters) { [weak self] (routeResult, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.showAlert(title: "Error solving route", message: error.localizedDescription)
                    return
                }
                
                guard let route = routeResult?.routes.first,
                      let routeGeometry = route.routeGeometry else { return }
                
                // Note we don't set a symbol on the graphic this
                // time, as the route overlay has a renderer defined
                // on it.
                let routeGraphic = AGSGraphic(geometry: routeGeometry, symbol: nil)
                self.routeOverlay.graphics.setArray([routeGraphic])
                
                // Zoom the map to the route result geometry. Here
                // we expand a little so the route doesn't run right
                // up against the edge of the map view.
                //
                // Geometries are immutable. This is for performance
                // reasons, particularly when a geometry is reused
                // in multiple places. Instead, to modify a
                // geometry, you derive a Builder from it, do the
                // modifications with the builder, and then derive
                // the modified geometry.
                let routeExtent = routeGeometry.extent
                    .toBuilder()
                    .expand(byFactor: 1.4)
                    .toGeometry()
                self.mapView.setViewpointGeometry(routeExtent, completion: nil)

                // Just quickly print out the turn-by-turn
                // directions.
                route.directionManeuvers.forEach { print($0.directionText) }
            }
        }
        
        callout.dismiss()
    }
}

extension ViewController: AGSGeoViewTouchDelegate {
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        mapView.identifyLayers(atScreenPoint: screenPoint, tolerance: 10, returnPopupsOnly: false) { [weak self] (results, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error Identifying", message: error.localizedDescription)
                return
            }
            
            guard let feature = results?.first?.geoElements.first as? AGSFeature else { return }

            self.mapView.callout.title = feature.attributes["Name"] as? String
            self.mapView.callout.detail = feature.attributes["Text_for_Short_Desc_field"] as? String
            self.mapView.callout.show(for: feature, tapLocation: mapPoint, animated: true)
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
        
        // Simply call geocode(withSearchText:completion:) on the
        // AGSLocatorTask and handle the response in the completion closure.
        locatorTask.geocode(withSearchText: searchText) { [weak self] (results, error) in
            guard let self = self else {
                return
            }
            
            if let result = results?.first {
                // If the result came back with an extent, zoom the map to it.
                // Note: The World Geocoder will always return an extent, but
                // it's a good pattern to check. A customer may publish a
                // geocoder without this capability. Since the extent is
                // optional, this plays well into an if...let statement.
                if let extent = result.extent {
                    self.mapView.setViewpoint(AGSViewpoint(targetExtent: extent), duration: 0.5)
                }
                
                // Remove the previous location.
                self.locationOverlay.graphics.removeAllObjects()
                
                // Again, since displayLocation is optional, an 'if let'
                // statement is useful here, though we know that World Geocoder
                // will return one with any result.
                if let location = result.displayLocation {
                    // Set up a simple AGSSymbol type for points.
                    // Why "Marker"? Historically, a point on a map is often
                    // called a marker in GIS.
                    let markerSymbol = AGSSimpleMarkerSymbol(style: .triangle, color: .red, size: 15)
                    markerSymbol.outline = AGSSimpleLineSymbol(style: .solid, color: .white, width: 2)
                    
                    // Create an AGSGraphic combining the result geometry and
                    // the symbol. We'll use the default value of nil for the
                    // attributes parameter, but it could be used to associate
                    // arbitrary simple information with the AGSGraphic.
                    let locationGraphic = AGSGraphic(geometry: location, symbol: markerSymbol)
                    
                    // By adding the graphic to the graphics overlay, it'll
                    // automatically be displayed on the map.
                    self.locationOverlay.graphics.add(locationGraphic)
                }
            } else if let error = error {
                self.showAlert(title: "Error Geocoding", message: error.localizedDescription)
            }
            
            searchBar.resignFirstResponder()
        }
    }
}

