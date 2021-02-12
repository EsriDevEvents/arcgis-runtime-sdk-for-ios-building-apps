# Runtime 101

Source code for the `ArcGIS Runtime SDKs: Building iOS Apps` session from the 2021 Esri Developer Summit.

## Features
* Display a map ([`AGSMap`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_map.html) and [`AGSMapView`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_map_view.html)) using a basemap layer style.
* Use an [API key](https://developers.arcgis.com/documentation/mapping-apis-and-location-services/security-and-authentication/#api-keys) to [geocode](https://developers.arcgis.com/documentation/mapping-apis-and-location-services/geocode-and-search/geocoding/), [find places](https://developers.arcgis.com/documentation/mapping-apis-and-location-services/geocode-and-search/place-search/), [get routes and directions](https://developers.arcgis.com/documentation/mapping-apis-and-location-services/route-and-directions/routing/), and access [basemap layers](https://developers.arcgis.com/documentation/mapping-apis-and-location-services/maps-scenes-and-layers/basemap-layers/).
* Use a [`UISearchBar`](https://developer.apple.com/documentation/uikit/uisearchbar) and an [`AGSLocatorTask`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_locator_task.html) with the World Geocoding Service to geocode and place find using the Runtime SDK's _Task Pattern_.
* Learn how to set the map's Viewpoint ([`AGSViewpoint`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_viewpoint.html)).
* Add and style markers ([`AGSGraphic`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_graphic.html), [`AGSGraphicsOverlay`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_graphics_overlay.html), [`AGSSimpleMarkerSymbol`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_simple_marker_symbol.html)).
* Add hosted data to the map ([`AGSServiceFeatureTable`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_service_feature_table.html), [`AGSFeatureLayer`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_feature_layer.html)).
* Identify and a tapped geographic feature and display its attributes ([`AGSFeature`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_feature.html), [`AGSCallout`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_callout.html), [`AGSCalloutDelegate`](https://developers.arcgis.com/ios/api-reference/protocol_a_g_s_callout_delegate-p.html), [`AGSGeoViewTouchDelegate`](https://developers.arcgis.com/ios/api-reference/protocol_a_g_s_geo_view_touch_delegate-p.html)).
* Use the device's GPS ([`AGSLocationDisplay`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_location_display.html)).
* Learn how to use a renderer with a graphics overlay([`AGSSimpleRenderer`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_simple_renderer.html), [`AGSSimpleLineSymbol`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_simple_line_symbol.html)).
* Get turn-by-turn directions with custom start and end text ([`AGSRouteTask`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_route_task.html), [`AGSStop`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_stop.html)).
* Learn about geometry builders ([`AGSGeometry.toBuilder()`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_geometry.html#a0a5dd7e9f36c1f05971cca3f6b68d190), [`AGSGeometryBuilder.toGeometry()`](https://developers.arcgis.com/ios/api-reference/interface_a_g_s_geometry_builder.html#a4b108ac0cfce067e27d3e1bd55219b57)).
* Animate the map view's viewpoint.

## Instructions
Download and install the [ArcGIS Runtime SDK for iOS](https://developers.arcgis.com/ios/).
Open the project in Xcode and run it.

To use the ArcGIS Platform's [geocoding](https://developers.arcgis.com/documentation/mapping-apis-and-location-services/geocode-and-search/) and [routing](https://developers.arcgis.com/documentation/mapping-apis-and-location-services/route-and-directions/) capabilities, you need an [API key](https://developers.arcgis.com/documentation/mapping-apis-and-location-services/security-and-authentication/#api-keys).


## Requirements
* [ArcGIS Runtime SDK for iOS](https://developers.arcgis.com/ios/)
* [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12)

## Licensing
Copyright 2020 Esri

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

A copy of the license is available in the repository's [LICENSE](LICENSE) file.

For information about licensing your deployed app, see [License your app](https://developers.arcgis.com/ios/license-and-deployment/license/#license-your-app).
