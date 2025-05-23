import 'package:flutter/material.dart';
import '../models/song.dart';
import 'drag_handle.dart';

class PlaylistSection extends StatelessWidget {
  final List<Song> playlist;
  final int currentIndex;
  final Function(int) onTap;
  final ScrollController scrollController;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final Song currentSong;
  final DraggableScrollableController playlistController;

  const PlaylistSection({
    Key? key,
    required this.playlist,
    required this.currentIndex,
    required this.onTap,
    required this.scrollController,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.currentSong,
    required this.playlistController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isExpanded ? 0 : 30),
          topRight: Radius.circular(isExpanded ? 0 : 30),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          DragHandle(
            playlistController: playlistController,
            isExpanded: isExpanded,
            onTap: onHeaderTap,
          ),

          // Playlist Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Text(
                  isExpanded ? "Playlist" : "Up Next",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isExpanded)
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: onHeaderTap,
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.playlist_play),
                    onPressed: onHeaderTap,
                  ),
              ],
            ),
          ),

          // Now Playing Bar (only in expanded view)
          if (isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              color: Colors.grey[850],
              child: Row(
                children: [
                  const Text(
                    "NOW PLAYING",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${currentSong.title} • ${currentSong.artist}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Playlist Items
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: playlist.length,
              itemBuilder: (context, index) {
                final song = playlist[index];
                final isSelected = index == currentIndex;

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      song.albumArt,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.music_note,
                            size: 20,
                            color: Colors.white54,
                          ),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    song.title,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    song.artist,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Icon(
                          Icons.equalizer,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        song.duration,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () => onTap(index),
                  selected: isSelected,
                  selectedTileColor: Colors.grey[850],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
