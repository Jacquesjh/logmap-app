import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.map,
            size: 20,
          ),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.user,
            size: 20,
          ),
          label: 'Profile',
        ),
      ],
      fixedColor: Colors.deepPurple[200],
      onTap: (int index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/map');
            break;
          case 1:
            Navigator.pushNamed(context, '/profile');
            break;                          
        }
      },
    );
  }
}