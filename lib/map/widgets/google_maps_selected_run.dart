import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:logmap/models/run_model.dart';
import 'package:logmap/models/truck_model.dart';
import 'package:logmap/models/delivery_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleMapsSelectedRun extends StatefulWidget {
  final GeoAddress userGeoAddress;
  final Run selectedRun;

  const GoogleMapsSelectedRun({
    Key? key,
    required this.userGeoAddress,
    required this.selectedRun,
  }) : super(key: key);

  @override
  State<GoogleMapsSelectedRun> createState() => _GoogleMapsSelectedRun();
}

class _GoogleMapsSelectedRun extends State<GoogleMapsSelectedRun> {
  Set<Marker> markers = <Marker>{};

  // Realtime tracking
  // StreamSubscription<DocumentSnapshot>? deliverySubscription;

  Stream<List<DocumentReference>> deliveriesRefStream = const Stream.empty();
  List<StreamSubscription<DocumentSnapshot>> deliverySubscriptions = [];

  StreamSubscription<DocumentSnapshot>? truckSubscription;
  late LatLng truckLastLocation = const LatLng(0.0, 0.0);

  Timer? locationTimer;

  late Map<String, Delivery> deliveriesMap = <String, Delivery>{};

  final LatLng? lastDestination = null;
  final LatLng? currentDestination = null;

  // Icons
  late BitmapDescriptor truckIcon;
  late BitmapDescriptor deliveryIcon;
  late BitmapDescriptor warehouseIcon = BitmapDescriptor.defaultMarker;

  Future<void> loadCustomIcons() async {
    truckIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/icons/truck-icon.png',
    );

    deliveryIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/icons/destination-flag-icon.png');

    warehouseIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/icons/warehouse-icon.png');
  }

  // void subscribeToDeliveryUpdates() {
  //   final List<DocumentReference> deliveriesRef =
  //       widget.selectedRun.deliveriesRef;

  //   for (final deliveryRef in deliveriesRef) {
  //     deliverySubscription = deliveryRef.snapshots().listen((snapshot) {
  //       final delivery = Delivery.fromSnapshot(snapshot);

  //       deliveriesMap[deliveryRef.path] = delivery;

  //       // Updates the markers
  //       markers.removeWhere(
  //         (marker) => marker.markerId.value == delivery.number.toString(),
  //       );

  //       markers.add(
  //         Marker(
  //           icon: deliveryIcon,
  //           markerId: MarkerId(delivery.number.toString()),
  //           position: LatLng(
  //             delivery.geoAddress.latitude,
  //             delivery.geoAddress.longitude,
  //           ),
  //           infoWindow: InfoWindow(title: 'Pedido #${delivery.number}'),
  //         ),
  //       );

  //       setState(() {});
  //     });
  //   }
  // }

  void subscribeToDeliveryUpdates() {
    deliveriesRefStream = Stream.value(widget.selectedRun.deliveriesRef);

    final currentSubscriptions = [...deliverySubscriptions];
    deliverySubscriptions.clear();

    deliveriesRefStream.listen((deliveriesRef) {
      for (final deliverySubscription in currentSubscriptions) {
        deliverySubscription.cancel();
      }

      for (final deliveryRef in deliveriesRef) {
        final subscription = deliveryRef.snapshots().listen((snapshot) {
          final delivery = Delivery.fromSnapshot(snapshot);

          deliveriesMap[deliveryRef.path] = delivery;

          // Updates the markers
          markers.removeWhere(
            (marker) => marker.markerId.value == delivery.number.toString(),
          );

          markers.add(
            Marker(
              icon: deliveryIcon,
              markerId: MarkerId(delivery.number.toString()),
              position: LatLng(
                delivery.geoAddress.latitude,
                delivery.geoAddress.longitude,
              ),
              infoWindow: InfoWindow(title: 'Pedido #${delivery.number}'),
            ),
          );

          setState(() {});
        });

        deliverySubscriptions.add(subscription);
      }
    });
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
            icon: truckIcon,
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

  // void updateLocationTracking() {
  //   final status = widget.selectedRun.status;

  //   if (status == 'progress' && locationTimer == null) {
  //     startLocationTracking();
  //   } else if (status != 'progress' && locationTimer != null) {
  //     stopLocationTracking();
  //   }
  // }

  // void startLocationTracking() {
  //   final status = widget.selectedRun.status;

  //   if (status == 'progress' && locationTimer == null) {
  //     locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
  //       final position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high,
  //       );

  //       if (widget.selectedRun.truckRef != null) {
  //         final truckRef = widget.selectedRun.truckRef!;
  //         final lastLocation = GeoPoint(position.latitude, position.longitude);

  //         print('Localização atual: $lastLocation');
  //         // truckRef.update({
  //         //   'lastLocation': lastLocation,
  //         //   'geoAddressArray': FieldValue.arrayUnion([lastLocation])
  //         // });
  //       }
  //     });
  //   }
  // }

  // void stopLocationTracking() {
  //   locationTimer?.cancel();
  //   locationTimer = null;
  // }

  // @override
  // void didUpdateWidget(GoogleMapsSelectedRun oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   updateLocationTracking();
  // }

  @override
  void initState() {
    super.initState();
    loadCustomIcons();
    // updateLocationTracking();

    // This will start the Snapshot realmtime updates
    // Will call once and the functions will keep running
    subscribeToDeliveryUpdates();
    subscribeToTruckUpdates();
  }

  @override
  void dispose() {
    for (final deliverySubscription in deliverySubscriptions) {
      deliverySubscription.cancel();
    }

    truckSubscription?.cancel();

    locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Add userGeoAddress marker
    markers.add(
      Marker(
        icon: warehouseIcon,
        markerId: const MarkerId('userGeoAddress'),
        position: LatLng(
          widget.userGeoAddress.latitude,
          widget.userGeoAddress.longitude,
        ),
        infoWindow: const InfoWindow(title: 'Loja'),
      ),
    );

    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 500, // Adjust the height as needed
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.userGeoAddress.latitude,
                    widget.userGeoAddress.longitude,
                  ),
                  zoom: 15,
                  tilt: 40,
                  bearing: 10,
                ),
                markers: markers,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle button click to start the run
                if (widget.selectedRun.status == "pending") {
                  // updateLocationTracking();
                  widget.selectedRun.updateStatus("progress");
                }
              },
              child: Text(
                widget.selectedRun.status == "progress"
                    ? 'Corrida #${widget.selectedRun.number} em andamento'
                    : widget.selectedRun.status == "pending"
                        ? 'Começar Corrida #${widget.selectedRun.number}!'
                        : 'Corrida #${widget.selectedRun.number} completada!',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
