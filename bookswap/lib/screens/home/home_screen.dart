import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'browse_listings_screen.dart';
import 'my_listings_screen.dart';
import 'my_offers_screen.dart';
import '../chat/chats_list_screen.dart';
import '../settings/settings_screen.dart';

// this screen serves as the main container for the app with bottom navigation. 
//it manages navigation between five main sections: browse listings, my listings, my offers, chats, and settings. the screen maintains the current tab state and switches between screens based on user selection.

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // list of screens corresponding to each navigation tab
  final List<Widget> _screens = [
    const BrowseListingsScreen(),
    const MyListingsScreen(),
    const MyOffersScreen(),
    const ChatsListScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // display current screen based on selected index
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}