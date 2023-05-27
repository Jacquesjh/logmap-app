import 'package:flutter/material.dart';
import 'package:logmap/shared/botto_nav.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(),
      backgroundColor: Colors.amber,
      appBar: AppBar(
        title: Text('Map'),
      ),
    );
  }
}