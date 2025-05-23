import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/screens/download/download_item.dart';
import 'package:music/screens/download/download_queue_state.dart';

class DownloadQueueScreen extends ConsumerStatefulWidget {
  const DownloadQueueScreen({super.key});

  @override
  ConsumerState<DownloadQueueScreen> createState() =>
      _DownloadQueueScreenState();
}

class _DownloadQueueScreenState extends ConsumerState<DownloadQueueScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Queue'),
            Tab(text: 'Completed'),
            Tab(text: 'Failed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to download settings
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Queue tab
          _buildQueueTab(theme),

          // Completed tab
          _buildCompletedTab(theme),

          // Failed tab
          _buildFailedTab(theme),
        ],
      ),
    );
  }

  Widget _buildQueueTab(ThemeData theme) {
    // Watch the download queue state
    final queueState = ref.watch(downloadQueueProvider);
    final activeDownloads = queueState.activeDownloadsList;
    final queuedDownloads = queueState.queuedDownloads;

    if (activeDownloads.isEmpty && queuedDownloads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_done, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No active downloads',
              style: TextStyle(fontSize: 18, color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              'Your download queue is empty',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active downloads section
        if (activeDownloads.isNotEmpty) ...[
          const Text(
            'Active Downloads',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...activeDownloads.map((item) => _buildDownloadItem(item, theme)),
          const SizedBox(height: 16),
        ],

        // Queued downloads section
        if (queuedDownloads.isNotEmpty) ...[
          const Text(
            'Queued Downloads',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...queuedDownloads.map((item) => _buildDownloadItem(item, theme)),
        ],
      ],
    );
  }

  Widget _buildCompletedTab(ThemeData theme) {
    // Watch the download queue state
    final queueState = ref.watch(downloadQueueProvider);
    final completedDownloads = queueState.completedDownloads;

    if (completedDownloads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_done, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No completed downloads',
              style: TextStyle(fontSize: 18, color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              'Your downloaded tracks will appear here',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...completedDownloads.map((item) => _buildDownloadItem(item, theme)),
      ],
    );
  }

  Widget _buildFailedTab(ThemeData theme) {
    // Watch the download queue state
    final queueState = ref.watch(downloadQueueProvider);
    final failedDownloads = queueState.failedDownloads;

    if (failedDownloads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No failed downloads',
              style: TextStyle(fontSize: 18, color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              'Failed downloads will appear here',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...failedDownloads.map((item) => _buildDownloadItem(item, theme)),
      ],
    );
  }

  Widget _buildDownloadItem(DownloadItem item, ThemeData theme) {
    final accentColor = theme.colorScheme.secondary;
    final queueNotifier = ref.read(downloadQueueProvider.notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Song info row
            Row(
              children: [
                // Album art
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    item.song.albumArt,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Song details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.song.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.song.artist} • ${item.albumName}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Status icon
                _buildStatusIcon(item, accentColor),
              ],
            ),

            // Progress section for downloading items
            if (item.status == DownloadStatus.downloading ||
                item.status == DownloadStatus.paused) ...[
              const SizedBox(height: 12),

              // Progress bar
              LinearProgressIndicator(
                value: item.progress,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  item.status == DownloadStatus.paused
                      ? Colors.grey
                      : accentColor,
                ),
              ),

              const SizedBox(height: 8),

              // Progress details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress percentage
                  Text(
                    '${(item.progress * 100).toInt()}%',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),

                  // Download speed and time remaining
                  if (item.status == DownloadStatus.downloading) ...[
                    Text(
                      item.formattedDownloadSpeed ?? '',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.formattedTimeRemaining ?? '',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],

                  // Paused status
                  if (item.status == DownloadStatus.paused)
                    Text(
                      'Paused',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                ],
              ),
            ],

            // Error message for failed downloads
            if (item.status == DownloadStatus.failed && item.error != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error: ${item.error}',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],

            // Action buttons
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Different actions based on status
                if (item.status == DownloadStatus.downloading) ...[
                  // Pause button
                  TextButton.icon(
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    onPressed: () => queueNotifier.pauseDownload(item.id),
                  ),

                  // Cancel button
                  TextButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    onPressed: () => queueNotifier.cancelDownload(item.id),
                  ),
                ] else if (item.status == DownloadStatus.paused) ...[
                  // Resume button
                  TextButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                    onPressed: () => queueNotifier.resumeDownload(item.id),
                  ),

                  // Cancel button
                  TextButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    onPressed: () => queueNotifier.cancelDownload(item.id),
                  ),
                ] else if (item.status == DownloadStatus.queued) ...[
                  // Prioritize button
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Prioritize'),
                    onPressed: () => queueNotifier.prioritizeDownload(item.id),
                  ),

                  // Cancel button
                  TextButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    onPressed: () => queueNotifier.cancelDownload(item.id),
                  ),
                ] else if (item.status == DownloadStatus.failed) ...[
                  // Retry button
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: () => queueNotifier.resumeDownload(item.id),
                  ),

                  // Remove button
                  TextButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove'),
                    onPressed: () => queueNotifier.cancelDownload(item.id),
                  ),
                ] else if (item.status == DownloadStatus.completed) ...[
                  // Play button
                  TextButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                    onPressed: () {
                      // Play the downloaded song
                    },
                  ),

                  // Delete button
                  TextButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    onPressed: () {
                      // Delete the downloaded song
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(DownloadItem item, Color accentColor) {
    switch (item.status) {
      case DownloadStatus.downloading:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value: item.progress,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        );

      case DownloadStatus.paused:
        return const Icon(Icons.pause, color: Colors.orange);

      case DownloadStatus.completed:
        return Icon(Icons.check_circle, color: accentColor);

      case DownloadStatus.failed:
        return const Icon(Icons.error, color: Colors.red);

      case DownloadStatus.queued:
        return const Icon(Icons.queue, color: Colors.grey);

      case DownloadStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.grey);
      case DownloadStatus.error:
        return const Icon(Icons.error, color: Colors.red);
    }
  }
}
