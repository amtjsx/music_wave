import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // Dispose tab controller to prevent memory leaks
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Library'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          tabs: const [
            Tab(text: 'Playlists'),
            Tab(text: 'Artists'),
            Tab(text: 'Albums'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Playlists tab - No changes needed as it doesn't use network images
          ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  context.push('/playlists/${index + 1}');
                },
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Icon(
                      index % 3 == 0 ? Icons.favorite : Icons.music_note,
                      color: index % 3 == 0 ? Colors.red : Colors.white,
                    ),
                  ),
                ),
                title: Text('Playlist ${index + 1}'),
                subtitle: Text('${10 + index} songs'),
                trailing: const Icon(Icons.more_vert),
              );
            },
          ),

          // Artists tab - Fixed to use placeholders instead of network images
          _buildArtistsTab(),

          // Albums tab - Fixed to use placeholders instead of network images
          _buildAlbumsTab(),
        ],
      ),
      // Note: The navigation bar will be handled by the parent widget
    );
  }

  // Separate method for artists tab
  Widget _buildArtistsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Column(
          children: [
            // Replace NetworkImage with a placeholder
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[700],
              child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              'Artist ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${index + 5} albums',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        );
      },
    );
  }

  // Separate method for albums tab
  Widget _buildAlbumsTab() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            // Replace Image.network with a placeholder
            child: Container(
              width: 50,
              height: 50,
              color: Colors.grey[700],
              child: Icon(Icons.album, color: Colors.grey[400]),
            ),
          ),
          title: Text('Album ${index + 1}'),
          subtitle: Text('Artist ${index % 3 + 1}'),
          trailing: const Icon(Icons.more_vert),
        );
      },
    );
  }
}
