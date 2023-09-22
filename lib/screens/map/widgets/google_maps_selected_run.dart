import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:logmap/models/truck_model.dart';
import 'package:logmap/models/delivery_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logmap/providers/driver_select_provider.dart';
import 'package:logmap/providers/selected_run_provider.dart';

class GoogleMapsSelectedRun extends ConsumerStatefulWidget {
  final GeoAddress userGeoAddress;

  const GoogleMapsSelectedRun({
    Key? key,
    required this.userGeoAddress,
  }) : super(key: key);

  @override
  ConsumerState<GoogleMapsSelectedRun> createState() =>
      _GoogleMapsSelectedRun();
}

class _GoogleMapsSelectedRun extends ConsumerState<GoogleMapsSelectedRun> {
  Set<Marker> markers = <Marker>{};

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

  void subscribeToDeliveryUpdates() {
    final selectedRun = ref.read(selectedRunProvider.notifier).state;

    deliveriesRefStream = Stream.value(selectedRun!.deliveriesRef);

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
    final selectedRun = ref.read(selectedRunProvider.notifier).state;

    if (selectedRun?.truckRef != null) {
      truckSubscription = selectedRun!.truckRef!.snapshots().listen((snapshot) {
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

  @override
  void initState() {
    super.initState();
    loadCustomIcons();

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
    final selectedRun = ref.watch(selectedRunProvider.notifier).state;
    Map<int, bool> playRunButton =
        ref.read(runPlayMapButtonProvider.notifier).state;

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
      child: Stack(children: [
        GoogleMap(
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
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(right: 300.0, bottom: 40.0),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black, // Set the background color as black
                ),
                padding: const EdgeInsets.all(2.0),
                child: FloatingActionButton(
                  onPressed: () {
                    // Handle button click to start the run
                    if (selectedRun.status == 'pending') {
                      selectedRun.ref.update({'status': 'progress'});
                      selectedRun.truckRef?.update({
                        'driverRef': ref
                            .read(selectedDriverProvider.notifier)
                            .state
                            ?.ref,
                        'currentDateDriversRef': FieldValue.arrayUnion([
                          ref.read(selectedDriverProvider.notifier).state?.ref
                        ])
                      });
                    }

                    playRunButton[selectedRun.number] = true;
                    ref.read(runPlayMapButtonProvider.notifier).state = playRunButton;
                  },
                  backgroundColor: const Color(0xFF08F26E),
                  child: Icon(
                    ref.read(runPlayMapButtonProvider.notifier).state[selectedRun!.number] == true
                        ? Icons.pause 
                        : Icons.play_arrow,
                    size: 30,
                    color: const Color.fromARGB(255, 61, 60, 60),
                  ),
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }
}
