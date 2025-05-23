import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/playlist.dart';
import '../models/song.dart';

// Provider for playlist service
final playlistServiceProvider = Provider<PlaylistService>((ref) {
  return PlaylistService();
});

// Provider for all playlists
final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final playlistService = ref.watch(playlistServiceProvider);
  return await playlistService.getPlaylists();
});

// Provider for a specific playlist
final playlistProvider = FutureProvider.family<Playlist?, String>((
  ref,
  id,
) async {
  final playlistService = ref.watch(playlistServiceProvider);
  return await playlistService.getPlaylist(id);
});

class PlaylistService {
  // Singleton instance
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;
  PlaylistService._internal();

  // Storage key for playlists
  static const String _playlistsKey = 'user_playlists';

  // Get all playlists
  Future<List<Playlist>> getPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = prefs.getStringList(_playlistsKey);

      if (playlistsJson == null || playlistsJson.isEmpty) {
        return [];
      }

      return playlistsJson.map((json) => Playlist.fromJson(json)).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      print('Error getting playlists: $e');
      return [];
    }
  }

  // Get a specific playlist by ID
  Future<Playlist?> getPlaylist(String id) async {
    try {
      final playlists = await getPlaylists();
      return playlists.firstWhere((playlist) => playlist.id == id);
    } catch (e) {
      print('Error getting playlist: $e');
      return null;
    }
  }

  // Create a new playlist
  Future<Playlist> createPlaylist({
    required String title,
    String? description,
    String? coverUrl,
    bool isOffline = false,
    String? creatorId,
    String? creatorName,
  }) async {
    try {
      final playlist = Playlist.create(
        title: title,
        description: description,
        coverUrl: coverUrl,
        isOffline: isOffline,
        creatorId: creatorId,
        creatorName: creatorName,
      );

      await _savePlaylists([playlist], append: true);
      return playlist;
    } catch (e) {
      print('Error creating playlist: $e');
      rethrow;
    }
  }

  // Update an existing playlist
  Future<Playlist> updatePlaylist(Playlist playlist) async {
    try {
      final playlists = await getPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlist.id);

      if (index >= 0) {
        // Update the playlist
        final updatedPlaylist = playlist.copyWith(updatedAt: DateTime.now());
        playlists[index] = updatedPlaylist;

        await _savePlaylists(playlists);
        return updatedPlaylist;
      } else {
        throw Exception('Playlist not found');
      }
    } catch (e) {
      print('Error updating playlist: $e');
      rethrow;
    }
  }

  // Delete a playlist
  Future<bool> deletePlaylist(String id) async {
    try {
      final playlists = await getPlaylists();
      final filteredPlaylists = playlists.where((p) => p.id != id).toList();

      if (playlists.length != filteredPlaylists.length) {
        await _savePlaylists(filteredPlaylists);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error deleting playlist: $e');
      return false;
    }
  }

  // Add a song to a playlist
  Future<Playlist> addSongToPlaylist(String playlistId, Song song) async {
    try {
      final playlists = await getPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlistId);

      if (index >= 0) {
        // Add the song to the playlist
        final updatedPlaylist = playlists[index].addSong(song);
        playlists[index] = updatedPlaylist;

        await _savePlaylists(playlists);
        return updatedPlaylist;
      } else {
        throw Exception('Playlist not found');
      }
    } catch (e) {
      print('Error adding song to playlist: $e');
      rethrow;
    }
  }

  // Remove a song from a playlist
  Future<Playlist> removeSongFromPlaylist(
    String playlistId,
    String songId,
  ) async {
    try {
      final playlists = await getPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlistId);

      if (index >= 0) {
        // Remove the song from the playlist
        final updatedPlaylist = playlists[index].removeSong(songId);
        playlists[index] = updatedPlaylist;

        await _savePlaylists(playlists);
        return updatedPlaylist;
      } else {
        throw Exception('Playlist not found');
      }
    } catch (e) {
      print('Error removing song from playlist: $e');
      rethrow;
    }
  }

  // Reorder songs in a playlist
  Future<Playlist> reorderPlaylistSongs(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    try {
      final playlists = await getPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlistId);

      if (index >= 0) {
        // Reorder the songs in the playlist
        final updatedPlaylist = playlists[index].reorderSongs(
          oldIndex,
          newIndex,
        );
        playlists[index] = updatedPlaylist;

        await _savePlaylists(playlists);
        return updatedPlaylist;
      } else {
        throw Exception('Playlist not found');
      }
    } catch (e) {
      print('Error reordering playlist songs: $e');
      rethrow;
    }
  }

  // Check if a song is in any playlists
  Future<List<Playlist>> getPlaylistsContainingSong(String songId) async {
    try {
      final playlists = await getPlaylists();
      return playlists
          .where((playlist) => playlist.songs.any((song) => song.id == songId))
          .toList();
    } catch (e) {
      print('Error checking if song is in playlists: $e');
      return [];
    }
  }

  // Save playlists to storage
  Future<void> _savePlaylists(
    List<Playlist> playlists, {
    bool append = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      List<String> playlistsJson;
      if (append) {
        // Append to existing playlists
        final existingPlaylists = await getPlaylists();
        final allPlaylists = [...existingPlaylists, ...playlists];
        playlistsJson =
            allPlaylists.map((playlist) => playlist.toJson()).toList();
      } else {
        // Replace existing playlists
        playlistsJson = playlists.map((playlist) => playlist.toJson()).toList();
      }

      await prefs.setStringList(_playlistsKey, playlistsJson);
    } catch (e) {
      print('Error saving playlists: $e');
      rethrow;
    }
  }
}
