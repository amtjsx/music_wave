import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/playlist.dart';
import 'package:music/services/playlist_service.dart';

class CreatePlaylistScreen extends ConsumerStatefulWidget {
  final Playlist? playlist; // If provided, we're editing an existing playlist

  const CreatePlaylistScreen({super.key, this.playlist});

  @override
  ConsumerState<CreatePlaylistScreen> createState() =>
      _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends ConsumerState<CreatePlaylistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _coverUrl;
  bool _isOffline = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // If editing an existing playlist, populate the form
    if (widget.playlist != null) {
      _titleController.text = widget.playlist!.title;
      _descriptionController.text = widget.playlist!.description ?? '';
      _coverUrl = widget.playlist!.coverUrl;
      _isOffline = widget.playlist!.isOffline;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.playlist != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Playlist' : 'Create Playlist'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePlaylist,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Playlist cover
            Center(
              child: GestureDetector(
                onTap: _selectCover,
                child: Stack(
                  children: [
                    // Cover image or placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          _coverUrl != null
                              ? Image.network(
                                _coverUrl!,
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildCoverPlaceholder();
                                },
                              )
                              : _buildCoverPlaceholder(),
                    ),

                    // Edit overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Playlist Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name for your playlist';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Offline switch
            SwitchListTile(
              title: const Text('Available Offline'),
              subtitle: const Text('Download songs for offline listening'),
              value: _isOffline,
              onChanged: (value) {
                setState(() {
                  _isOffline = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    // Generate a color based on the playlist title or use a default color
    final color =
        _titleController.text.isNotEmpty
            ? Colors.primaries[_titleController.text.hashCode %
                Colors.primaries.length]
            : Colors.grey[800];

    return Container(
      width: 160,
      height: 160,
      color: color,
      child: Center(
        child: Icon(
          Icons.queue_music,
          size: 80,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  void _selectCover() {
    // In a real app, you would implement image selection from gallery or camera
    // For this example, we'll just show a dialog with some preset images
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Cover Image'),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                children: [
                  // Some preset cover images
                  _buildCoverOption('https://example.com/cover1.jpg'),
                  _buildCoverOption('https://example.com/cover2.jpg'),
                  _buildCoverOption('https://example.com/cover3.jpg'),
                  _buildCoverOption('https://example.com/cover4.jpg'),
                  _buildCoverOption('https://example.com/cover5.jpg'),
                  _buildCoverOption('https://example.com/cover6.jpg'),

                  // Option to remove cover
                  InkWell(
                    onTap: () {
                      setState(() {
                        _coverUrl = null;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Icon(Icons.remove, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Widget _buildCoverOption(String url) {
    return InkWell(
      onTap: () {
        setState(() {
          _coverUrl = url;
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Future<void> _savePlaylist() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final playlistService = ref.read(playlistServiceProvider);
        final title = _titleController.text;
        final description =
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null;

        Playlist updatedPlaylist;

        if (widget.playlist != null) {
          // Update existing playlist
          updatedPlaylist = await playlistService.updatePlaylist(
            widget.playlist!.copyWith(
              title: title,
              description: description,
              coverUrl: _coverUrl,
              isOffline: _isOffline,
            ),
          );
        } else {
          // Create new playlist
          updatedPlaylist = await playlistService.createPlaylist(
            title: title,
            description: description,
            coverUrl: _coverUrl,
            isOffline: _isOffline,
          );
        }

        // Refresh playlists provider
        ref.refresh(playlistsProvider);

        // Return to previous screen with the updated playlist
        if (mounted) {
          Navigator.pop(context, updatedPlaylist);
        }
      } catch (e) {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving playlist: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
