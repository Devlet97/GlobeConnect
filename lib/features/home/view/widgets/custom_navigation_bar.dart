import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1E),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        backgroundColor: const Color(0xFF1A1B1E),
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.view_agenda_outlined,
              color: selectedIndex == 0 ? Colors.blue : Colors.white,
            ),
            label: 'Akış',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.grid_view,
              color: selectedIndex == 1 ? Colors.blue : Colors.white,
            ),
            label: 'Servisler',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.add_circle_outline,
              color: selectedIndex == 2 ? Colors.blue : Colors.white,
            ),
            label: 'Paylaş',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.chat_outlined,
              color: selectedIndex == 3 ? Colors.blue : Colors.white,
            ),
            label: 'Sohbet',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color: selectedIndex == 4 ? Colors.blue : Colors.white,
            ),
            label: 'Profil',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        height: 65,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(color: Colors.blue, fontSize: 12);
          }
          return const TextStyle(color: Colors.white, fontSize: 12);
        }),
      ),
    );
  }
}
