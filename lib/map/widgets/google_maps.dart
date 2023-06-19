import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logmap/models/truck_model.dart';
import 'package:logmap/models/delivery_model.dart';
import 'package:logmap/providers/selected_run_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_routes/google_maps_routes.dart';

class GoogleMapsWithRoutes extends ConsumerStatefulWidget {
  final GeoAddress userGeoAddress;

  const GoogleMapsWithRoutes({
    Key? key,
    required this.userGeoAddress,
  }) : super(key: key);

  @override
  ConsumerState<GoogleMapsWithRoutes> createState() =>
      _GoogleMapsWithRoutesState();
}

class _GoogleMapsWithRoutesState extends ConsumerState<GoogleMapsWithRoutes> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Set<Marker> markers = <Marker>{};

  StreamSubscription<DocumentSnapshot>? deliverySubscription;
  StreamSubscription<DocumentSnapshot>? truckSubscription;
  Timer? locationTimer;

  MapsRoutes route = MapsRoutes();
  List<LatLng> waypoints = <LatLng>[];

  late LatLng truckLastLocation = const LatLng(0.0, 0.0);
  late Map<String, LatLng> deliveriesLatLngMap = {};

  void updateRoute() async {
    final selectedRun = ref.read(selectedRunProvider.notifier).state;

    waypoints = <LatLng>[];

    // Clear the current route
    route.routes.clear();

    if (selectedRun != null) {
      final String status = selectedRun.status;

      // Add userGeoAddress or truck lastLocation as the starting point
      if (status == 'progress' && selectedRun.truckRef != null) {
        waypoints.add(truckLastLocation);
      } else {
        final LatLng userGeoAddress = LatLng(
          widget.userGeoAddress.latitude,
          widget.userGeoAddress.longitude,
        );
        waypoints.add(userGeoAddress);
      }

      // Add the deliveries
      if (selectedRun.deliveriesRef.isNotEmpty &&
          selectedRun.route.isNotEmpty) {
        for (final deliveryRef in selectedRun.route) {
          if (deliveryRef is DocumentReference) {
            final deliveryDocRef = deliveryRef;
            final deliveryLatLng = deliveriesLatLngMap[deliveryDocRef.path];

            if (deliveryLatLng != null) {
              waypoints.add(deliveryLatLng);
            }
          }
        }
      }

      // Add userGeoAddress as the final point
      final LatLng userGeoAddress = LatLng(
        widget.userGeoAddress.latitude,
        widget.userGeoAddress.longitude,
      );
      waypoints.add(userGeoAddress);
    }

    print("Waypoints : $waypoints");

    await route.drawRoute(waypoints, "rota", const Color(0xFF08F26E),
        "AIzaSyCBm0S2FqvzhNO_pqiZNTk8hKhlJd4AxOA",
        travelMode: TravelModes.driving);

    setState(() {});
  }

  void subscribeToDeliveryUpdates() {
    final selectedRun = ref.read(selectedRunProvider.notifier).state;

    if (selectedRun != null) {
      // Ja pegar do lugar das rotas
      final List<dynamic> deliveriesRef = selectedRun.deliveriesRef;

      for (final deliveryRef in deliveriesRef) {
        deliverySubscription = deliveryRef.snapshots().listen((snapshot) {
          final delivery = Delivery.fromSnapshot(snapshot);

          deliveriesLatLngMap[delivery.ref?.path as String] = LatLng(
            delivery.geoAddress.latitude,
            delivery.geoAddress.longitude,
          );

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
          updateRoute();

          setState(() {});
        });
      }
    }
  }

  void subscribeToTruckUpdates() {
    final selectedRun = ref.read(selectedRunProvider.notifier).state;

    if (selectedRun != null && selectedRun.truckRef != null) {
      truckSubscription = selectedRun.truckRef!.snapshots().listen((snapshot) {
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
        print("Calling updateRoute");
        updateRoute();

        setState(() {});
      });
    }
  }

  // void updateLocationTracking() {
  //   final status = ref.read(selectedRunProvider.notifier).state?.status;

  //   if (status == 'progress' && locationTimer == null) {
  //     startLocationTracking();
  //   } else if (status != 'progress' && locationTimer != null) {
  //     stopLocationTracking();
  //   }
  // }

  // void startLocationTracking() {
  //   final status = ref.read(selectedRunProvider.notifier).state?.status;

  //   if (status == 'progress' && locationTimer == null) {
  //     locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
  //       final position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high,
  //       );

  //       final selectedRun = ref.read(selectedRunProvider.notifier).state;

  //       if (selectedRun != null && selectedRun.truckRef != null) {
  //         final truckRef = selectedRun.truckRef!;
  //         final lastLocation = GeoPoint(position.latitude, position.longitude);

  //         truckRef.update({
  //           'lastLocation': lastLocation,
  //           'geoAddressArray': FieldValue.arrayUnion([lastLocation])
  //         });
  //       }
  //     });
  //   }
  // }

  // void stopLocationTracking() {
  //   locationTimer?.cancel();
  //   locationTimer = null;
  // }

  @override
  void didUpdateWidget(GoogleMapsWithRoutes oldWidget) {
    super.didUpdateWidget(oldWidget);
    // updateLocationTracking();
    updateRoute();
  }

  @override
  void initState() {
    super.initState();
    // updateLocationTracking();

    // This will start the Snapshot realmtime updates
    // Will call once and the functions will keep running
    subscribeToDeliveryUpdates();
    subscribeToTruckUpdates();

    updateRoute();
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
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.userGeoAddress.latitude,
            widget.userGeoAddress.longitude,
          ),
          zoom: 17,
        ),
        markers: markers,
        polylines: route.routes,

        // myLocationButtonEnabled: true,
        // myLocationEnabled: true,
      ),
    );
  }
}
