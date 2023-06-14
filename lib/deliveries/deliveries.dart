import 'package:flutter/material.dart';
import 'package:logmap/shared/botto_nav.dart';

class DeliveriesScreen extends StatelessWidget {
  const DeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(),
      backgroundColor: Colors.amber,
      appBar: AppBar(
        title: Text('DeliveriesScreen'),
      ),
    );
  }
}
