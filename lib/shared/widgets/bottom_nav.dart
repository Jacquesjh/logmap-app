import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logmap/providers/bottom_nav_bar_provider.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex =
        ref.watch(selectedIndexBottomNavBarProvider.notifier).state;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.truckFast,
            size: 20,
          ),
          label: 'Corridas',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.boxesPacking,
            size: 20,
          ),
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.solidMap,
            size: 20,
          ),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.solidUser,
            size: 20,
          ),
          label: 'Perfil',
        ),
      ],
      selectedItemColor: Theme.of(context)
          .primaryColor, // Use the primary color of your theme for highlighting
      unselectedItemColor:
          Colors.white, // Adjust the color for unselected items
      onTap: (int index) {
        ref.read(selectedIndexBottomNavBarProvider.notifier).state =
            index; // Update the selected index
        
        var bottoSelect = index != currentIndex ? index : null;

        switch (bottoSelect) {
          case 0:
            Navigator.pushNamed(context, '/runs');
            break;
          case 1:
            Navigator.pushNamed(context, '/deliveries');
            break;
          case 2:
            Navigator.pushNamed(context, '/map');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
          default:
            break;
          
        }
      },
    );
  }
}
