import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  final LatLng sourceLatLng;
  final LatLng destinationLatLng;

  MapScreen({
    Key? key,
    required this.sourceLatLng,
    required this.destinationLatLng,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GlobalKey<GoogleMapState> _mapKey = GlobalKey<GoogleMapState>();
  LatLng? driverLocation;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    startDriverLocationUpdates();
  }

  void startDriverLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Request to enable location services
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Handle location services disabled
        return;
      }
    }

    // Check location permission status
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      // Request location permission
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        // Handle location permission denied
        return;
      }
    }

    // Get the current position of the driver
    LocationData position = await location.getLocation();
    setState(() {
      driverLocation = LatLng(position.latitude!, position.longitude!);
    });

    // Listen for location updates
    location.onLocationChanged.listen((LocationData position) {
      setState(() {
        driverLocation = LatLng(position.latitude!, position.longitude!);
      });
      updateDriverPositionOnMap();
    });
  }

  void updateDriverPositionOnMap() async {
    final GoogleMapController? controller = _mapKey.currentState;
    if (controller != null && driverLocation != null) {
      controller.clearMarkers();
      controller.addMarker(
        Marker(
          markerId: MarkerId('driver'),
          position: driverLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              key: _mapKey,
              initialCameraPosition: CameraPosition(
                target: widget.sourceLatLng,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('source'),
                  position: widget.sourceLatLng,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ),
                Marker(
                  markerId: MarkerId('destination'),
                  position: widget.destinationLatLng,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
                if (driverLocation != null)
                  Marker(
                    markerId: MarkerId('driver'),
                    position: driverLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
