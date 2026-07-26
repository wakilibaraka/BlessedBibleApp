import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  Future<void> initialize() async {
    debugPrint('Mock NotificationService: initialize() called.');
  }

  Future<void> requestPermissions() async {
    debugPrint('Mock NotificationService: requestPermissions() called.');
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    debugPrint("Mock NotificationService: scheduleDailyReminder() called for $hour:$minute. Time for today's reading.");
  }

  Future<void> cancelReminder() async {
    debugPrint('Mock NotificationService: cancelReminder() called.');
  }
}
