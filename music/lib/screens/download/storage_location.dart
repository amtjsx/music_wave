import 'dart:math' as math;

class StorageLocation {
  final String id;
  final String name;
  final String path;
  final bool isRemovable;
  final StorageSpaceInfo spaceInfo;
  
  const StorageLocation({
    required this.id,
    required this.name,
    required this.path,
    required this.isRemovable,
    required this.spaceInfo,
  });
}

class StorageSpaceInfo {
  final int totalSpace;  // in bytes
  final int freeSpace;   // in bytes
  final int usedSpace;   // in bytes
  
  const StorageSpaceInfo({
    required this.totalSpace,
    required this.freeSpace,
    required this.usedSpace,
  });
  
  // Get formatted total space
  String get formattedTotalSpace => _formatBytes(totalSpace);
  
  // Get formatted free space
  String get formattedFreeSpace => _formatBytes(freeSpace);
  
  // Get formatted used space
  String get formattedUsedSpace => _formatBytes(usedSpace);
  
  // Get usage percentage
  double get usagePercentage {
    if (totalSpace == 0) return 0.0;
    return usedSpace / totalSpace;
  }
  
  // Format bytes to human-readable string
  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }
}

// Helper function for log and pow since they're not imported
double log(num x) => math.log(x);
num pow(num x, num exponent) => math.pow(x, exponent);