import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logmap/map/widgets/google_maps.dart';
import 'package:logmap/models/user_model.dart';
import 'package:logmap/shared/botto_nav.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userUid = FirebaseAuth.instance.currentUser?.uid;

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
                  return GoogleMapsWithRoutes(userGeoAddress: user.geoAddress);
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
