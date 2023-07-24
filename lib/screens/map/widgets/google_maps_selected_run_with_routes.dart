import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:logmap/models/run_model.dart';
import 'package:logmap/models/truck_model.dart';
import 'package:logmap/models/delivery_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleMapsSelectedRunWithRoutes extends StatefulWidget {
  final GeoAddress userGeoAddress;
  final Run selectedRun;

  const GoogleMapsSelectedRunWithRoutes({
    Key? key,
    required this.userGeoAddress,
    required this.selectedRun,
  }) : super(key: key);

  @override
  State<GoogleMapsSelectedRunWithRoutes> createState() =>
      _GoogleMapsSelectedRunWithRoutes();
}

class _GoogleMapsSelectedRunWithRoutes
    extends State<GoogleMapsSelectedRunWithRoutes> {
  Set<Marker> markers = <Marker>{};

  StreamSubscription<DocumentSnapshot>? deliverySubscription;
  StreamSubscription<DocumentSnapshot>? truckSubscription;
  late LatLng truckLastLocation = const LatLng(0.0, 0.0);

  Timer? locationTimer;

  late Map<String, Delivery> deliveriesMap = <String, Delivery>{};

  final LatLng? lastDestination = null;
  final LatLng? currentDestination = null;

  void completeDelivery() {}

  void updateCurrentDestination() {
    if (widget.selectedRun.status == "progress") {

      for (final deliveryRef in widget.selectedRun.route) {
        if (deliveryRef is DocumentReference) {
          final delivery = deliveriesMap[deliveryRef];

          if (delivery != null) {
            if (!delivery.isComplete) {
              break;
            }
          }
        }
      }

      // Check if the current destination is the same
      // If it is not, then rebuild the Widget.
      //   if (currentDelivery is Delivery) {
      //     final currentDeliveryLatLng = LatLng(
      //         currentDelivery.geoAddress.latitude,
      //         currentDelivery.geoAddress.longitude);
      //     if (currentDeliveryLatLng == currentDestination) {
      //       return;
      //     } else {
      //       lastDestination = currentDestination;
      //       currentDestination = currentDeliveryLatLng;
      //     }
      //   } else {
      //     final userLatLng = LatLng(
      //         widget.userGeoAddress.latitude, widget.userGeoAddress.longitude);
      //     if (currentDestination != userLatLng) {
      //       lastDestination = currentDestination;
      //       currentDestination = LatLng(
      //           widget.userGeoAddress.latitude, widget.userGeoAddress.longitude);
      //     } else {}

      //     // There were no incomplete deliveries left to the run
      //     // Check if the driver
      //   }
    }
  }

  void subscribeToDeliveryUpdates() {
    // Ja pegar do lugar das rotas
    final List<DocumentReference> deliveriesRef =
        widget.selectedRun.deliveriesRef;

    for (final deliveryRef in deliveriesRef) {
      deliverySubscription = deliveryRef.snapshots().listen((snapshot) {
        final delivery = Delivery.fromSnapshot(snapshot);

        deliveriesMap[deliveryRef.path] = delivery;

        // Updates the markers
        markers.removeWhere(
          (marker) => marker.markerId.value == delivery.number.toString(),
        );

        markers.add(
          Marker(
            markerId: MarkerId(delivery.number.toString()),
            position: LatLng(
              delivery.geoAddress.latitude,
              delivery.geoAddress.longitude,
            ),
            infoWindow: const InfoWindow(title: 'Pedido #'),
          ),
        );

        setState(() {});
      });
    }
  }

  void subscribeToTruckUpdates() {
    if (widget.selectedRun.truckRef != null) {
      truckSubscription =
          widget.selectedRun.truckRef!.snapshots().listen((snapshot) {
        final truck = Truck.fromSnapshot(snapshot);
        final truckName = truck.name;

        truckLastLocation =
            LatLng(truck.lastLocation.latitude, truck.lastLocation.longitude);

        // Updates the marker
        markers.removeWhere(
          (marker) => marker.markerId.value == truck.name,
        );

        markers.add(
          Marker(
            markerId: MarkerId(truck.name),
            position: LatLng(
                truck.lastLocation.latitude, truck.lastLocation.longitude),
            infoWindow: InfoWindow(title: 'Caminhão $truckName'),
          ),
        );

        setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(GoogleMapsSelectedRunWithRoutes oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();

    // This will start the Snapshot realmtime updates
    // Will call once and the functions will keep running
    subscribeToDeliveryUpdates();
    subscribeToTruckUpdates();
  }

  @override
  void dispose() {
    deliverySubscription?.cancel();
    truckSubscription?.cancel();

    locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Add userGeoAddress marker
    markers.add(
      Marker(
        markerId: const MarkerId('userGeoAddress'),
        position: LatLng(
          widget.userGeoAddress.latitude,
          widget.userGeoAddress.longitude,
        ),
        infoWindow: const InfoWindow(title: 'User Address'),
      ),
    );

    return Expanded(
        child: widget.selectedRun.status == "progress"
            ? GoogleMapsWidget(
                apiKey: "AIzaSyCBm0S2FqvzhNO_pqiZNTk8hKhlJd4AxOA",
                sourceLatLng: LatLng(
                  widget.userGeoAddress.latitude,
                  widget.userGeoAddress.longitude,
                ),
                driverCoordinatesStream: Stream.periodic(
                  const Duration(milliseconds: 500),
                  (i) => truckLastLocation,
                ),
                destinationLatLng: const LatLng(-29.7256, -52.4385),
                routeColor: const Color(0xFF08F26E),
                markers: markers,
              )
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.userGeoAddress.latitude,
                      widget.userGeoAddress.longitude),
                  zoom: 15,
                ),
                markers: markers,
              ));
  }
}
