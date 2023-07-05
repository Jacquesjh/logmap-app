import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logmap/map/widgets/google_maps_selected_run.dart';
import 'package:logmap/providers/selected_run_provider.dart';
import 'package:logmap/providers/user_provider.dart';
import 'package:logmap/shared/bottom_nav.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRun = ref.watch(selectedRunProvider.notifier).state;
    final user = ref.read(userProvider.notifier).state;

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
            if (user != null)
              if (selectedRun != null)
                GoogleMapsSelectedRun(
                  userGeoAddress: user.geoAddress,
                )
              else
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        user.geoAddress.latitude,
                        user.geoAddress.longitude,
                      ),
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
                        infoWindow: const InfoWindow(title: 'User Address'),
                      )
                    },
                  ),
                ),
            if (user == null) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
