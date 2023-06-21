import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logmap/map/widgets/google_maps_selected_run.dart';
import 'package:logmap/models/user_model.dart';
import 'package:logmap/providers/selected_run_provider.dart';
import 'package:logmap/shared/botto_nav.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    final selectedRun = ref.watch(selectedRunProvider.notifier).state;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        bottomNavigationBar: const BottomNavBar(),
        appBar: AppBar(
          automaticallyImplyLeading: false, // Disable the back arrow
          title: const Text('Mapa'),
        ),
        body: Column(
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(userUid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final user = UserModel.fromSnapshot(snapshot);
                  // return Text("yesss");
                  return selectedRun != null
                      ? GoogleMapsSelectedRun(
                          userGeoAddress: user.geoAddress,
                          selectedRun: selectedRun,
                        )
                      : Expanded(
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(user.geoAddress.latitude,
                                  user.geoAddress.longitude),
                              zoom: 15,
                              tilt: 40,
                              bearing: 10,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('userGeoAddress'),
                                position: LatLng(
                                  user.geoAddress.latitude,
                                  user.geoAddress.longitude,
                                ),
                                infoWindow:
                                    const InfoWindow(title: 'User Address'),
                              )
                            },
                          ),
                        );
                } else if (snapshot.hasError) {
                  return const Text('Error');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
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