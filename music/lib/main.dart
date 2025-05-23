// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music/home_wrapper.dart';
import 'package:music/screens/albums/album_detail_screen.dart';
import 'package:music/screens/artist_detail_screen.dart';
import 'package:music/screens/auth/login_screen.dart';
import 'package:music/screens/download/download_queue_screen.dart';
import 'package:music/screens/explore_screen.dart';
import 'package:music/screens/home_screen.dart';
import 'package:music/screens/library_screen.dart';
import 'package:music/screens/live/live_event_all_screen.dart';
import 'package:music/screens/live/live_event_detail_screen.dart';
import 'package:music/screens/live_screen.dart';
import 'package:music/screens/playlists/playlist_detail_screen.dart';
import 'package:music/screens/profile_screen.dart';
import 'package:music/screens/recent_played_screen.dart';
import 'package:music/screens/song_detail_screen.dart';
import 'package:music/screens/welcome_screen.dart';
import 'package:music/services/deep_link_service.dart';

/// This sample app shows an app with two screens.
///
/// The first route '/' is mapped to [HomeScreen], and the second route
/// '/details' is mapped to [DetailsScreen].
///
/// The buttons use context.go() to navigate to each destination. On mobile
/// devices, each destination is deep-linkable and on the web, can be navigated
/// to using the address bar.
void main() => runApp(const ProviderScope(child: MyApp()));

/// The route configuration.
final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'login',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginScreen();
          },
        ),
        StatefulShellRoute.indexedStack(
          builder:
              (context, state, navigationShell) =>
                  HomeWrapper(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: 'home',
                  builder: (BuildContext context, GoRouterState state) {
                    return const HomeScreen();
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: 'explore',
                  builder: (BuildContext context, GoRouterState state) {
                    return const ExploreScreen();
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: 'live',
                  builder: (BuildContext context, GoRouterState state) {
                    return const LiveScreen();
                  },
                ),
                GoRoute(
                  path: 'live-events-all',
                  builder: (BuildContext context, GoRouterState state) {
                    return const LiveEventsAllScreen();
                  },
                ),
                GoRoute(
                  path: 'live-event-detail/:eventId',
                  builder: (BuildContext context, GoRouterState state) {
                    return LiveEventDetailScreen(
                      eventId: state.pathParameters['eventId']!,
                    );
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: 'library',
                  builder: (BuildContext context, GoRouterState state) {
                    return const LibraryScreen();
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: 'profile',
                  builder: (BuildContext context, GoRouterState state) {
                    return const ProfileScreen();
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: 'details',
          builder: (BuildContext context, GoRouterState state) {
            return const DetailsScreen();
          },
        ),
        GoRoute(
          path: 'playlists/:playlistId',
          builder: (BuildContext context, GoRouterState state) {
            return PlaylistDetailScreen(
              playlistId: state.pathParameters['playlistId']!,
            );
          },
        ),
        GoRoute(
          path: 'artists/:artistId',
          builder: (BuildContext context, GoRouterState state) {
            return ArtistDetailScreen(
              artistId: state.pathParameters['artistId']!,
            );
          },
        ),
        GoRoute(
          path: 'albums/:albumId',
          builder: (BuildContext context, GoRouterState state) {
            return AlbumDetailScreen(albumId: state.pathParameters['albumId']!);
          },
        ),
        GoRoute(
          path: 'download-queue',
          builder: (BuildContext context, GoRouterState state) {
            return const DownloadQueueScreen();
          },
        ),
        GoRoute(
          path: 'recent-played',
          builder: (BuildContext context, GoRouterState state) {
            return const RecentlyPlayedScreen();
          },
        ),
        GoRoute(
          path: 'song/:songId',
          builder: (BuildContext context, GoRouterState state) {
            return SongDetailScreen(songId: state.pathParameters['songId']!);
          },
        ),
      ],
    ),
  ],
);

/// The main app.
class MyApp extends StatefulWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // Listen for deep links
    DeepLinkService().deepLinks.listen((data) {
      final context = _navigatorKey.currentContext;
      if (context != null) {
        DeepLinkService().handleDeepLink(data, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.purple,
        colorScheme: ColorScheme.dark(
          primary: Colors.purple,
          secondary: Colors.purpleAccent,
        ),
        fontFamily: 'Roboto',
      ),
    );
  }
}

/// The details screen
class DetailsScreen extends StatelessWidget {
  /// Constructs a [DetailsScreen]
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details Screen')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go back to the Home screen'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to the Login screen'),
            ),
          ],
        ),
      ),
    );
  }
}
