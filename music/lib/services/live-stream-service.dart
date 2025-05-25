import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/live-stream.dart';

// Provider for live stream service
final liveStreamServiceProvider = Provider<LiveStreamService>((ref) {
  return LiveStreamService();
});

// Provider for individual live stream - using 'live' as the parameter
final liveStreamProvider = FutureProvider.family<LiveStream?, String>((
  ref,
  live,
) async {
  final service = ref.watch(liveStreamServiceProvider);
  return service.getLiveStream(live);
});

// Provider for live chat messages - using 'live' as the parameter
final liveChatProvider = StreamProvider.family<List<LiveComment>, String>((
  ref,
  live,
) {
  final service = ref.watch(liveStreamServiceProvider);
  return service.getChatStream(live);
});

class LiveStreamService {
  // Mock data for demonstration
  Future<LiveStream?> getLiveStream(String live) async {
    await Future.delayed(const Duration(seconds: 1));

    return LiveStream(
      id: live,
      title: 'Music Wave Live Session',
      hostId: 'host123',
      hostName: 'DJ MusicWave',
      hostAvatar: 'https://picsum.photos/200/200?random=1',
      streamUrl: 'https://example.com/stream',
      thumbnailUrl: 'https://picsum.photos/400/300?random=2',
      isLive: true,
      isAudioOnly: false,
      viewerCount: 1100,
      startedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      topComments: _getMockComments(),
      tags: ['music', 'live', 'edm'],
    );
  }

  Stream<List<LiveComment>> getChatStream(String live) {
    // Simulate real-time chat messages
    return Stream.periodic(const Duration(seconds: 3), (count) {
      return _getMockChatMessages(count);
    });
  }

  void sendComment(String live, String text) {
    // Send comment implementation
  }

  void sendReaction(String live, String type) {
    // Send reaction implementation
  }

  List<LiveComment> _getMockComments() {
    return [
      LiveComment(
        id: '1',
        userId: 'user1',
        userName: 'စမ်း ဇာယ',
        userAvatar: 'https://picsum.photos/200/200?random=3',
        text: 'ပြန်မာစကားကို ပြန်မာ စာတန်းထိုး၊ရတယ်လို့😊',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        replies: [
          LiveReply(
            id: 'r1',
            userId: 'user2',
            userName: 'Mar',
            text: 'စာတန်းထိုးတိုကောင်းကောလည်းဘာသာတေရေးမှန်မှ သိကာမှတတ်လား',
            timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
          ),
        ],
        replyToUser: 'Htein',
        originalUser: 'စမ်း ဇာယ',
      ),
      LiveComment(
        id: '2',
        userId: 'user3',
        userName: 'Mar Ri On',
        userAvatar: 'https://picsum.photos/200/200?random=4',
        text: 'မင်းပိုန်းတာလည်ကောယ်',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      LiveComment(
        id: '3',
        userId: 'user4',
        userName: 'Daw Yin Min',
        userAvatar: 'https://picsum.photos/200/200?random=5',
        text: 'နိုင်ငံတွန်း နိုင်ငံတွန်း နိုင်ပြီ',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      LiveComment(
        id: '4',
        userId: 'user5',
        userName: 'Mehm Chit Oo',
        userAvatar: 'https://picsum.photos/200/200?random=6',
        text: 'နိုင်ငံတွန်းရှိ။',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      LiveComment(
        id: '5',
        userId: 'user6',
        userName: 'Htun Myat Aung',
        userAvatar: 'https://picsum.photos/200/200?random=7',
        text: 'အဆုံမလုပ်နေလေကွာ',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        replies: [
          LiveReply(
            id: 'r2',
            userId: 'user7',
            userName: 'Htun',
            text:
                'မင်းတို့ဟာကလဲ ကာ ဘယ်လိုလုပ်ပဲ ေစာက်ပြစ် ကို မလွတ်ဘူး၊ ကို ထိုင်နိုင်ငံခြေနေသည်၊ ကြည့်...',
            timestamp: DateTime.now(),
          ),
        ],
        replyToUser: 'Han',
        originalUser: 'Htun Myat Aung',
      ),
    ];
  }

  List<LiveComment> _getMockChatMessages(int count) {
    final messages = <LiveComment>[];
    final baseCount = count * 3;

    for (int i = 0; i < 3; i++) {
      messages.add(
        LiveComment(
          id: 'chat${baseCount + i}',
          userId: 'user${baseCount + i}',
          userName: 'User ${baseCount + i}',
          userAvatar: 'https://picsum.photos/200/200?random=${baseCount + i}',
          text: 'Great music! 🎵',
          timestamp: DateTime.now(),
          isHost: i == 1 && count % 3 == 0,
        ),
      );
    }

    return messages;
  }
}
