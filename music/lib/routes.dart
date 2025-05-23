import 'package:flutter/material.dart';

import 'screens/explore_screen.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/live_screen.dart';
import 'screens/profile_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String explore = '/explore';
  static const String live = '/live';
  static const String library = '/library';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
    explore: (context) => const ExploreScreen(),
    live: (context) => const LiveScreen(),
    library: (context) => const LibraryScreen(),
    profile: (context) => const ProfileScreen(),
  };
}
