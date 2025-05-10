import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/viewmodel/auth_view_model.dart';
import '../../profile/view/profile_view.dart';
import 'widgets/publish_modal.dart';
import 'widgets/feed_view.dart';
import 'widgets/job_listing_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  void _showPublishModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const PublishModal(),
    );
  }

  final List<Widget> _pages = [
    const FeedView(),
    const JobListingView(),
    const Center(child: Text('Yeni', style: TextStyle(color: Colors.white))),
    const Center(child: Text('Sohbet', style: TextStyle(color: Colors.white))),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              );
            }
            return TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            );
          }),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: NavigationBar(
            backgroundColor: const Color(0xFF121212),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              if (index == 2) {
                _showPublishModal();
              } else {
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            indicatorColor: Colors.blue.withOpacity(0.1),
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            height: 65,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined,
                    color: _selectedIndex == 0 ? Colors.blue : Colors.white70),
                selectedIcon: Icon(Icons.home, color: Colors.blue),
                label: 'Akış',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined,
                    color: _selectedIndex == 1 ? Colors.blue : Colors.white70),
                selectedIcon: Icon(Icons.grid_view, color: Colors.blue),
                label: 'İş İlanı',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline,
                    color: _selectedIndex == 2 ? Colors.blue : Colors.white70),
                selectedIcon: Icon(Icons.add_circle, color: Colors.blue),
                label: 'Yayınla',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_outlined,
                    color: _selectedIndex == 3 ? Colors.blue : Colors.white70),
                selectedIcon: Icon(Icons.chat, color: Colors.blue),
                label: 'Sohbet',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline,
                    color: _selectedIndex == 4 ? Colors.blue : Colors.white70),
                selectedIcon: Icon(Icons.person, color: Colors.blue),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
