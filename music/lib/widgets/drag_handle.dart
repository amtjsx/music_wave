import 'package:flutter/material.dart';

class DragHandle extends StatefulWidget {
  final DraggableScrollableController playlistController;
  final bool isExpanded;
  final VoidCallback onTap;

  const DragHandle({
    Key? key,
    required this.playlistController,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  State<DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<DragHandle> {
  double _dragStartPosition = 0;
  double _dragStartSize = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      // Handle vertical drag to move the sheet
      onVerticalDragStart: (details) {
        _dragStartPosition = details.globalPosition.dy;
        _dragStartSize = widget.playlistController.size;
      },
      onVerticalDragUpdate: (details) {
        // Calculate how much the user has dragged
        final dragDistance = details.globalPosition.dy - _dragStartPosition;

        // Convert to a size change (negative because dragging down should decrease size)
        final sizeDelta = -dragDistance / MediaQuery.of(context).size.height;

        // Calculate new size and clamp it to valid range
        final newSize = (_dragStartSize + sizeDelta).clamp(0.1, 0.9);

        // Update the sheet position
        widget.playlistController.jumpTo(newSize);
      },
      onVerticalDragEnd: (details) {
        // Snap to either expanded or collapsed state based on velocity and current position
        final currentSize = widget.playlistController.size;
        final targetSize =
            (currentSize > 0.5 || details.velocity.pixelsPerSecond.dy < -300)
                ? 0.9
                : 0.4;

        widget.playlistController.animateTo(
          targetSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: Colors.transparent, // Make the entire area draggable
        child: Column(
          children: [
            // Visual drag handle indicator
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Add a small text hint for better UX
            if (!widget.isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Drag to expand",
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
