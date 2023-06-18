import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';

class SelectedCourseMap extends StatelessWidget {
  final LatLng sourceLatLng;
  final LatLng destinationLatLng;

  SelectedCourseMap({
    Key? key,
    required this.sourceLatLng,
    required this.destinationLatLng,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMapsWidget(
              apiKey: "AIzaSyCBm0S2FqvzhNO_pqiZNTk8hKhlJd4AxOA",
              sourceLatLng: sourceLatLng,
              destinationLatLng: destinationLatLng,
              routeWidth: 2,
              sourceMarkerIconInfo: MarkerIconInfo(
                infoWindowTitle: "CHANGE FOR COMPANY NAME",
                onTapInfoWindow: (_) {
                  print("Tapped on source info window");
                },
                assetPath: "assets/icons/home_marker.png",
              ),
              destinationMarkerIconInfo: MarkerIconInfo(
                assetPath: "assets/icons/delivery_marker.png",
              ),
              onPolylineUpdate: (_) {
                print("Polyline updated");
              },
              totalTimeCallback: (time) => print(time),
              totalDistanceCallback: (distance) => print(distance),
            ),
          ),
        ],
      ),
    );
  }
}
