import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';

class MapScreen extends StatefulWidget {
  final LatLng sourceLatLng;
  final LatLng destinationLatLng;

  MapScreen({
    Key? key,
    this.sourceLatLng = const LatLng(-29.7119623, -52.4385882),
    this.destinationLatLng = const LatLng(-29.7086771, -52.4336602),
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapsWidgetController = GlobalKey<GoogleMapsWidgetState>();
  StreamSubscription? driverCoordinatesSubscription;
  StreamController<LatLng> driverCoordinatesStreamController =
      StreamController<LatLng>();
  LatLng? driverLocation;

  @override
  void initState() {
    super.initState();
    driverCoordinatesSubscription =
        driverCoordinatesStreamController.stream.listen((driverLocation) {
      setState(() {
        this.driverLocation = driverLocation;
      });
    });
    startDriverLocationUpdates();
  }

  @override
  void dispose() {
    driverCoordinatesSubscription?.cancel();
    driverCoordinatesStreamController.close();
    super.dispose();
  }

  void startDriverLocationUpdates() {
    // Simulate driver location updates
    Timer.periodic(Duration(seconds: 1), (timer) {
      final driverLatitude = widget.destinationLatLng.latitude +
          (Random().nextDouble() - 0.5) / 1000; // Random variation within 0.001 km
      final driverLongitude = widget.destinationLatLng.longitude +
          (Random().nextDouble() - 0.5) / 1000; // Random variation within 0.001 km

      final driverLocation = LatLng(driverLatitude, driverLongitude);
      driverCoordinatesStreamController.add(driverLocation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMapsWidget(
              apiKey: "AIzaSyCBm0S2FqvzhNO_pqiZNTk8hKhlJd4AxOA",
              key: mapsWidgetController,
              sourceLatLng: widget.sourceLatLng,
              destinationLatLng: widget.destinationLatLng,
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
              driverMarkerIconInfo: MarkerIconInfo(
                assetPath: "assets/icons/home_marker.png",
              ),
              updatePolylinesOnDriverLocUpdate: true,
              onPolylineUpdate: (_) {
                print("Polyline updated");
              },
              driverCoordinatesStream: driverCoordinatesStreamController.stream,
              totalTimeCallback: (time) => print(time),
              totalDistanceCallback: (distance) => print(distance),
            ),
          ),
        ],
      ),
    );
  }
}

























/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/map/widgets/selected_course_map.dart';
import 'package:logmap/shared/botto_nav.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:logmap/models/run_model.dart';
import 'package:logmap/providers/driver_select_provider.dart';
import 'package:logmap/shared/get_current_date.dart';


class MapScreen extends ConsumerWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('runs')
          .where('date', isEqualTo: getCurrentDate())
          .where('driverRef',
              isEqualTo: ref.read(selectedDriverProvider.notifier).state?.ref)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final runs = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: runs.length,
          itemBuilder: (context, index) {
            final run = Run.fromSnapshot(runs[index]);

            return Consumer(
              builder: (context, ref, _) {
                return SelectedCourse(
                  sourceLatLng: LatLng(-29.7, -52.4303),
                  destinationLatLng: LatLng(-29.7, -52.4385882),
                );
              },
            );
          },
        );
      },
    );
  }
}
*/
/*
class GMap extends StatefulWidget {
  const GMap({
    Key? key,
  }) : super(key: key);

  @override
  State<GMap> createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  final mapsWidgetController = GlobalKey<GoogleMapsWidgetState>();

  @override
  Widget build(BuildContext context) {
    return const GoogleMapsWidget(
      apiKey: "AIzaSyCBm0S2FqvzhNO_pqiZNTk8hKhlJd4AxOA", 
      destinationLatLng: LatLng(
        -29.7142288,
        -52.4311263,
        ), 
      sourceLatLng: LatLng(
        -29.7187294,
        -52.4423296,
        ),
    );
  }
}







*/

/*
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Data'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('your_collection').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title']),
                subtitle: Text(data['description']),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class AllRuns extends ConsumerWidget {
  const AllRuns({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('runs')
          .where('date', isEqualTo: getCurrentDate())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final runs = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: runs.length,
          itemBuilder: (context, index) {
            final run = Run.fromSnapshot(runs[index]);



=======================================================

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: const GMap(),
    );
  }
}


class GMap extends StatefulWidget {
  const GMap({
    Key? key,
  }) : super(key: key);

  @override
  State<GMap> createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  final mapsWidgetController = GlobalKey<GoogleMapsWidgetState>();

  @override
  Widget build(BuildContext context) {
    return const GoogleMapsWidget(
      apiKey: "AIzaSyCBm0S2FqvzhNO_pqiZNTk8hKhlJd4AxOA", 
      destinationLatLng: LatLng(
        -29.7142288,
        -52.4311263,
        ), 
      sourceLatLng: LatLng(
        -29.7187294,
        -52.4423296,
        ),
    );
  }
}











*/