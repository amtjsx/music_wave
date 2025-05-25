import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'audio_service.dart';

// Message types for isolate communication
enum ScanMessageType {
  start,
  progress,
  songFound,
  complete,
  error,
  cancel
}

// Message structure for isolate communication
class ScanMessage {
  final ScanMessageType type;
  final dynamic data;

  ScanMessage(this.type, this.data);
}

// Scan progress information
class ScanProgress {
  final int totalFiles;
  final int processedFiles;
  final int foundSongs;
  final String currentFolder;

  ScanProgress({
    required this.totalFiles,
    required this.processedFiles,
    required this.foundSongs,
    required this.currentFolder,
  });

  double get progressPercentage => 
    totalFiles > 0 ? (processedFiles / totalFiles) * 100 : 0;
}

// Scanner service for background music scanning
class ScannerService {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;
  final _progressController = StreamController<ScanProgress>.broadcast();
  final _songsController = StreamController<List<MusicFile>>.broadcast();
  final _completeController = StreamController<List<MusicFile>>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  bool _isScanning = false;
  
  // Stream getters
  Stream<ScanProgress> get progressStream => _progressController.stream;
  Stream<List<MusicFile>> get songsStream => _songsController.stream;
  Stream<List<MusicFile>> get completeStream => _completeController.stream;
  Stream<String> get errorStream => _errorController.stream;
  bool get isScanning => _isScanning;
  
  // Start scanning in background
  Future<void> startScan(String directoryPath) async {
    if (_isScanning) {
      return;
    }
    
    _isScanning = true;
    
    try {
      // Create a receive port for communication
      _receivePort = ReceivePort();
      
      // Spawn the isolate
      _isolate = await Isolate.spawn(
        _scanIsolate,
        [_receivePort!.sendPort, directoryPath],
      );
      
      // Listen for messages from the isolate
      _receivePort!.listen((message) {
        if (message is SendPort) {
          _sendPort = message;
        } else if (message is ScanMessage) {
          _handleMessage(message);
        }
      });
    } catch (e) {
      _isScanning = false;
      _errorController.add('Failed to start background scan: $e');
    }
  }
  
  // Cancel the current scan
  void cancelScan() {
    if (_sendPort != null && _isScanning) {
      _sendPort!.send(ScanMessage(ScanMessageType.cancel, null));
    }
  }
  
  // Handle messages from the isolate
  void _handleMessage(ScanMessage message) {
    switch (message.type) {
      case ScanMessageType.progress:
        _progressController.add(message.data as ScanProgress);
        break;
      case ScanMessageType.songFound:
        _songsController.add(message.data as List<MusicFile>);
        break;
      case ScanMessageType.complete:
        _completeController.add(message.data as List<MusicFile>);
        _isScanning = false;
        _cleanupIsolate();
        break;
      case ScanMessageType.error:
        _errorController.add(message.data as String);
        _isScanning = false;
        _cleanupIsolate();
        break;
      default:
        break;
    }
  }
  
  // Clean up the isolate
  void _cleanupIsolate() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    _sendPort = null;
  }
  
  // Dispose the service
  void dispose() {
    _cleanupIsolate();
    _progressController.close();
    _songsController.close();
    _completeController.close();
    _errorController.close();
  }
  
  // Static method to run in isolate
  static void _scanIsolate(List<dynamic> args) async {
    final SendPort sendPort = args[0];
    final String directoryPath = args[1];
    
    // Create a receive port for two-way communication
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    
    bool cancelled = false;
    receivePort.listen((message) {
      if (message is ScanMessage && message.type == ScanMessageType.cancel) {
        cancelled = true;
      }
    });
    
    try {
      final directory = Directory(directoryPath);
      
      if (!await directory.exists()) {
        sendPort.send(ScanMessage(
          ScanMessageType.error, 
          'Directory does not exist: $directoryPath'
        ));
        return;
      }
      
      // First, count total files to process for progress reporting
      int totalFiles = 0;
      await for (final entity in directory.list(recursive: true, followLinks: false)) {
        if (cancelled) break;
        if (entity is File) {
          final extension = path.extension(entity.path).toLowerCase();
          if (['.mp3', '.m4a', '.wav', '.flac', '.aac', '.ogg'].contains(extension)) {
            totalFiles++;
          }
        }
      }
      
      if (cancelled) {
        sendPort.send(ScanMessage(ScanMessageType.complete, <MusicFile>[]));
        return;
      }
      
      // Now scan for music files
      final List<MusicFile> musicFiles = [];
      int processedFiles = 0;
      int foundSongs = 0;
      List<MusicFile> batchSongs = [];
      
      await for (final entity in directory.list(recursive: true, followLinks: false)) {
        if (cancelled) break;
        
        if (entity is File) {
          final extension = path.extension(entity.path).toLowerCase();
          if (['.mp3', '.m4a', '.wav', '.flac', '.aac', '.ogg'].contains(extension)) {
            processedFiles++;
            
            try {
              final file = File(entity.path);
              final stat = await file.stat();
              final fileName = path.basenameWithoutExtension(entity.path);
              final folderName = path.basename(path.dirname(entity.path));
              
              // Extract basic metadata from filename
              final parts = fileName.split(' - ');
              String title = fileName;
              String artist = 'Unknown Artist';
              String album = 'Unknown Album';
              
              if (parts.length >= 2) {
                artist = parts[0].trim();
                title = parts[1].trim();
              }
              
              final musicFile = MusicFile(
                id: entity.path.hashCode.toString(),
                title: title,
                artist: artist,
                album: album,
                filePath: entity.path,
                fileName: path.basename(entity.path),
                fileSize: stat.size,
                dateAdded: stat.modified,
                duration: 0, // We'll update this when playing
              );
              
              musicFiles.add(musicFile);
              batchSongs.add(musicFile);
              foundSongs++;
              
              // Send progress update every 10 files or when batch reaches 20 songs
              if (processedFiles % 10 == 0 || batchSongs.length >= 20) {
                sendPort.send(ScanMessage(
                  ScanMessageType.progress,
                  ScanProgress(
                    totalFiles: totalFiles,
                    processedFiles: processedFiles,
                    foundSongs: foundSongs,
                    currentFolder: folderName,
                  ),
                ));
                
                if (batchSongs.isNotEmpty) {
                  sendPort.send(ScanMessage(
                    ScanMessageType.songFound,
                    List<MusicFile>.from(batchSongs),
                  ));
                  batchSongs.clear();
                }
              }
            } catch (e) {
              // Skip files that can't be processed
              debugPrint('Error processing file ${entity.path}: $e');
            }
          }
        }
      }
      
      // Send any remaining songs in the batch
      if (batchSongs.isNotEmpty && !cancelled) {
        sendPort.send(ScanMessage(
          ScanMessageType.songFound,
          List<MusicFile>.from(batchSongs),
        ));
      }
      
      // Send completion message
      if (!cancelled) {
        sendPort.send(ScanMessage(
          ScanMessageType.complete,
          musicFiles,
        ));
      } else {
        sendPort.send(ScanMessage(ScanMessageType.complete, <MusicFile>[]));
      }
    } catch (e) {
      sendPort.send(ScanMessage(
        ScanMessageType.error,
        'Error scanning directory: $e',
      ));
    } finally {
      receivePort.close();
    }
  }
}
