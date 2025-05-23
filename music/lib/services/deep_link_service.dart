import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Deep link types
enum DeepLinkType {
  song,
  album,
  playlist,
  artist,
  search,
  unknown,
}

// Deep link data
class DeepLinkData {
  final DeepLinkType type;
  final String? id;
  final Map<String, String> parameters;
  
  DeepLinkData({
    required this.type,
    this.id,
    this.parameters = const {},
  });
}

class DeepLinkService {
  // Singleton instance
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();
  
  // Stream controller for deep links
  final StreamController<DeepLinkData> _deepLinkStreamController =
      StreamController<DeepLinkData>.broadcast();
  
  // Stream for deep links
  Stream<DeepLinkData> get deepLinks => _deepLinkStreamController.stream;
  
  // Method channel for getting initial link and listening to link events
  static const MethodChannel _channel = MethodChannel('app.channel.shared.data');
  
  // Initialize deep link handling
  Future<void> init() async {
    // Set up method channel handler
    _channel.setMethodCallHandler(_handleMethodCall);
    
    // Check for initial link
    try {
      final initialLink = await _channel.invokeMethod<String>('getInitialLink');
      if (initialLink != null && initialLink.isNotEmpty) {
        final deepLinkData = _parseDeepLink(initialLink);
        _deepLinkStreamController.add(deepLinkData);
      }
    } catch (e) {
      print('Error getting initial link: $e');
    }
  }
  
  // Handle method calls from platform
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onLinkReceived':
        final link = call.arguments as String?;
        if (link != null && link.isNotEmpty) {
          final deepLinkData = _parseDeepLink(link);
          _deepLinkStreamController.add(deepLinkData);
        }
        break;
      default:
        print('Unknown method ${call.method}');
    }
  }
  
  // Parse deep link
  DeepLinkData _parseDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      
      // Extract path segments
      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) {
        return DeepLinkData(type: DeepLinkType.unknown);
      }
      
      // Extract parameters
      final parameters = <String, String>{};
      uri.queryParameters.forEach((key, value) {
        parameters[key] = value;
      });
      
      // Determine link type
      final firstSegment = pathSegments[0];
      switch (firstSegment) {
        case 'song':
          return DeepLinkData(
            type: DeepLinkType.song,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            parameters: parameters,
          );
        case 'album':
          return DeepLinkData(
            type: DeepLinkType.album,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            parameters: parameters,
          );
        case 'playlist':
          return DeepLinkData(
            type: DeepLinkType.playlist,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            parameters: parameters,
          );
        case 'artist':
          return DeepLinkData(
            type: DeepLinkType.artist,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            parameters: parameters,
          );
        case 'search':
          return DeepLinkData(
            type: DeepLinkType.search,
            parameters: parameters,
          );
        default:
          return DeepLinkData(type: DeepLinkType.unknown);
      }
    } catch (e) {
      print('Error parsing deep link: $e');
      return DeepLinkData(type: DeepLinkType.unknown);
    }
  }
  
  // Handle deep link
  void handleDeepLink(DeepLinkData data, BuildContext context) {
    switch (data.type) {
      case DeepLinkType.song:
        if (data.id != null) {
          // Navigate to song details
          // This would be implemented in your app's navigation
          print('Navigate to song: ${data.id}');
        }
        break;
      case DeepLinkType.album:
        if (data.id != null) {
          // Navigate to album details
          // This would be implemented in your app's navigation
          print('Navigate to album: ${data.id}');
        }
        break;
      case DeepLinkType.playlist:
        if (data.id != null) {
          // Navigate to playlist details
          // This would be implemented in your app's navigation
          print('Navigate to playlist: ${data.id}');
        }
        break;
      case DeepLinkType.artist:
        if (data.id != null) {
          // Navigate to artist details
          // This would be implemented in your app's navigation
          print('Navigate to artist: ${data.id}');
        }
        break;
      case DeepLinkType.search:
        final query = data.parameters['q'];
        if (query != null) {
          // Navigate to search results
          // This would be implemented in your app's navigation
          print('Navigate to search: $query');
        }
        break;
      case DeepLinkType.unknown:
        // Handle unknown deep link
        break;
    }
  }
  
  // Dispose resources
  void dispose() {
    _deepLinkStreamController.close();
  }
}