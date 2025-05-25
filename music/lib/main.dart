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
import 'package:music/screens/friends/following_screen.dart';
import 'package:music/screens/friends/friend_profile_screen.dart';
import 'package:music/screens/friends/friends_activity_screen.dart';
import 'package:music/screens/genre/browse_genre_screen.dart';
import 'package:music/screens/genre/genre_detail_screen.dart';
import 'package:music/screens/home_screen.dart';
import 'package:music/screens/library/library_screen.dart';
import 'package:music/screens/liked-songs/liked-songs-screen.dart';
import 'package:music/screens/live/live_event_all_screen.dart';
import 'package:music/screens/live/live_event_detail_screen.dart';
import 'package:music/screens/live/live_event_search_screen.dart'
    show LiveEventSearchScreen;
import 'package:music/screens/live_screen.dart';
import 'package:music/screens/menu/device_songs_screen.dart';
import 'package:music/screens/menu/menu_screen.dart';
import 'package:music/screens/now_playing_screen.dart';
import 'package:music/screens/playlists/playlist_detail_screen.dart';
import 'package:music/screens/playlists/playlist_screen.dart';
import 'package:music/screens/profile_screen.dart';
import 'package:music/screens/recent_played_screen.dart';
import 'package:music/screens/search_screen.dart';
import 'package:music/screens/shared_screen.dart';
import 'package:music/screens/short_screen.dart';
import 'package:music/screens/trending_screen.dart';
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
                  path: 'live-events',
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
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: 'shorts',
                  builder: (BuildContext context, GoRouterState state) {
                    return const ShortScreen();
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: 'menu',
                  builder: (BuildContext context, GoRouterState state) {
                    return const MenuScreen();
                  },
                ),
                GoRoute(
                  path: 'device-songs',
                  builder: (BuildContext context, GoRouterState state) {
                    return const DeviceSongsScreen();
                  },
                ),
              ],
            ),
          ],
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
          path: 'downloads',
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
          path: 'now-playing',
          builder: (BuildContext context, GoRouterState state) {
            return const NowPlayingScreen();
          },
        ),
        GoRoute(
          path: 'trending',
          builder: (BuildContext context, GoRouterState state) {
            return const TrendingScreen();
          },
        ),
        GoRoute(
          path: 'playlists',
          builder: (BuildContext context, GoRouterState state) {
            return const PlaylistsScreen();
          },
        ),
        GoRoute(
          path: 'search',
          builder: (BuildContext context, GoRouterState state) {
            return const SearchScreen();
          },
        ),
        GoRoute(
          path: 'live-event-search',
          builder: (BuildContext context, GoRouterState state) {
            return const LiveEventSearchScreen();
          },
        ),
        GoRoute(
          path: 'profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
        ),
        GoRoute(
          path: 'browse-genre',
          builder: (BuildContext context, GoRouterState state) {
            return const BrowseGenreScreen();
          },
        ),
        GoRoute(
          path: 'genre/:genreName',
          builder: (BuildContext context, GoRouterState state) {
            return GenreDetailScreen(
              genreName: state.pathParameters['genreName']!,
            );
          },
        ),
        GoRoute(
          path: 'library',
          builder: (BuildContext context, GoRouterState state) {
            return const LibraryScreen();
          },
        ),
        GoRoute(
          path: 'friends',
          builder: (BuildContext context, GoRouterState state) {
            return const FriendsActivityScreen();
          },
        ),
        GoRoute(
          path: 'friends/:friendId',
          builder: (BuildContext context, GoRouterState state) {
            return FriendProfileScreen(
              friendId: state.pathParameters['friendId']!,
            );
          },
        ),
        GoRoute(
          path: 'following',
          builder: (BuildContext context, GoRouterState state) {
            return const FollowingScreen();
          },
        ),
        GoRoute(
          path: 'shared',
          builder: (BuildContext context, GoRouterState state) {
            return const SharedScreen();
          },
        ),
        GoRoute(
          path: 'liked-songs',
          builder: (BuildContext context, GoRouterState state) {
            return const LikedSongsScreen();
          },
        ),
        GoRoute(
          path: 'live-event-detail/:eventId',
          builder: (BuildContext context, GoRouterState state) {
            return LiveEventDetailScreen(
              liveId: state.pathParameters['eventId']!,
            );
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
