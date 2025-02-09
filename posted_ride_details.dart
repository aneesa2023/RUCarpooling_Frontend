import 'package:ru_carpooling/screens/utilities/constants.dart';
import 'package:ru_carpooling/services/api_service.dart';
import 'package:ru_carpooling/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostedRideDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> ride;

  const PostedRideDetailsScreen({super.key, required this.ride});

  @override
  State<PostedRideDetailsScreen> createState() =>
      _PostedRideDetailsScreenState();
}

class _PostedRideDetailsScreenState extends State<PostedRideDetailsScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final String googleApiKey = Constants.googleApiKey;
  LatLng? _fromLocation;
  LatLng? _toLocation;
  Polyline? _routePolyline;
  bool _isRouteFetched = false;
  String? carModel;
  String? licenseNumber;
  bool isFetchingVehicle = true;

  @override
  void initState() {
    super.initState();
    _setupMapMarkers();
    _fetchRoute();
    _fetchVehicleDetails();
  }

  /// Fetch Vehicle Details
  Future<void> _fetchVehicleDetails() async {
    final String? carId = widget.ride['car_id'];
    if (carId == null || carId.isEmpty) return;

    try {
      final response = await ApiService.getRequest(
        module: 'cars',
        endpoint: 'cars/$carId',
      );

      if (response.containsKey('car_details')) {
        setState(() {
          carModel = response['car_details']['car_model'] ?? "Unknown";
          licenseNumber =
              response['car_details']['license_number'] ?? "Unknown";
          isFetchingVehicle = false;
        });
      } else {
        setState(() {
          carModel = "Unknown";
          licenseNumber = "Unknown";
          isFetchingVehicle = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch vehicle details. $e")),
      );
      setState(() {
        carModel = "Error";
        licenseNumber = "Error";
        isFetchingVehicle = false;
      });
    }
  }

  void _setupMapMarkers() {
    _fromLocation = LatLng(
        double.tryParse(widget.ride['from_lat'].toString()) ?? 0.0,
        double.tryParse(widget.ride['from_long'].toString()) ?? 0.0);
    _toLocation = LatLng(
        double.tryParse(widget.ride['to_lat'].toString()) ?? 0.0,
        double.tryParse(widget.ride['to_long'].toString()) ?? 0.0);

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("from"),
          position: _fromLocation!,
          infoWindow: InfoWindow(title: widget.ride["from_location"]),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      _markers.add(
        Marker(
          markerId: const MarkerId("to"),
          position: _toLocation!,
          infoWindow: InfoWindow(title: widget.ride["to_location"]),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  Future<void> _fetchRoute() async {
    if (_fromLocation == null || _toLocation == null) return;

    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_fromLocation!.latitude},${_fromLocation!.longitude}&destination=${_toLocation!.latitude},${_toLocation!.longitude}&key=$googleApiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final polylinePoints = data['routes'][0]['overview_polyline']['points'];
        List<LatLng> decodedPoints = _decodePolyline(polylinePoints);

        setState(() {
          _routePolyline = Polyline(
            polylineId: const PolylineId("route"),
            points: decodedPoints,
            color: Colors.blue,
            width: 4,
          );

          LatLngBounds bounds = _getBoundsForPolyline(decodedPoints);
          _mapController
              .animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));

          _isRouteFetched = true;
        });
      }
    }
  }

  LatLngBounds _getBoundsForPolyline(List<LatLng> polylinePoints) {
    double minLat = polylinePoints.first.latitude;
    double maxLat = polylinePoints.first.latitude;
    double minLng = polylinePoints.first.longitude;
    double maxLng = polylinePoints.first.longitude;

    for (LatLng point in polylinePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Details"),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Google Map View (1/4th of the screen)
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _fromLocation ?? const LatLng(0, 0),
                zoom: 10.0,
              ),
              markers: _markers,
              polylines: _routePolyline != null ? {_routePolyline!} : {},
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  widget.ride['departure_time'],
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
                Text(
                  "\$${widget.ride['ride_price']}",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
                Divider(),
                Text(
                  widget.ride['from_location']!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(
                  height: 10,
                ),
                const Icon(
                  Icons.arrow_downward,
                  color: Colors.black,
                  size: 16,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.ride['to_location']!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildDetailColumn(
                        "Vehicle Model",
                        isFetchingVehicle
                            ? "Loading..."
                            : carModel ?? "Unknown",
                      ),
                    ),
                    Expanded(
                      child: _buildDetailColumn(
                          "Licence Number",
                          isFetchingVehicle
                              ? "Loading..."
                              : licenseNumber ?? "Unknown"),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildDetailColumn(
                        'Total Seats',
                        widget.ride['total_seats']!.toString(),
                      ),
                    ),
                    Expanded(
                      child: _buildDetailColumn(
                        'Available Seats',
                        widget.ride['available_seats']!.toString(),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                _buildDetailColumn(
                  "Notes",
                  widget.ride['note'],
                ),
                _buildDetailColumn(
                  "Additional Features",
                  getAdditionalFeatures(widget.ride),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String getAdditionalFeatures(Map<String, dynamic> ride) {
    List<String> features = [];

    if (ride['pet_friendly']) features.add("Pet Friendly");
    if (ride['trunk_space']) features.add("Trunk Space");
    if (ride['wheelchair_access']) {
      features.add("Wheelchair Accessible");
    }

    return features.isNotEmpty
        ? features.join(", ")
        : "No Additional Features Available";
  }
}
