import 'dart:convert';

import 'package:bepop_ngu/data/models/notificationDetails.dart';
import 'package:bepop_ngu/data/repositories/authRepository.dart';
import 'package:bepop_ngu/utils/api.dart';
import 'package:bepop_ngu/utils/errorMessageKeysAndCodes.dart';
import 'package:bepop_ngu/utils/hiveBoxKeys.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepository {
  static Future<void> addNotification(
      {required NotificationDetails notificationDetails}) async {
    try {
      final box = Hive.box(notificationsBoxKey);

      // Check for duplicate notifications by comparing title, body, and userId
      // within the last 5 minutes to avoid adding the same notification twice
      final currentTime = DateTime.now();
      final fiveMinutesAgo = currentTime.subtract(Duration(minutes: 5));

      bool isDuplicate = false;
      for (var key in box.keys) {
        try {
          final existingNotificationData =
              Map<String, dynamic>.from(box.get(key) ?? {});
          final existingNotification =
              NotificationDetails.fromJson(existingNotificationData);

          // Check if it's the same notification within 5 minutes
          if (existingNotification.title == notificationDetails.title &&
              existingNotification.body == notificationDetails.body &&
              existingNotification.userId == notificationDetails.userId &&
              existingNotification.createdAt.isAfter(fiveMinutesAgo)) {
            isDuplicate = true;
            break;
          }
        } catch (_) {
          // Skip invalid entries
          continue;
        }
      }

      // Only add if it's not a duplicate
      if (!isDuplicate) {
        await box.put(notificationDetails.createdAt.toString(),
            notificationDetails.toJson());
      }
    } catch (_) {}
  }

  Future<List<NotificationDetails>> fetchNotifications() async {
    try {
      Box notificationBox = Hive.box(notificationsBoxKey);
      List<NotificationDetails> notifications = [];

      for (var notificationKey in notificationBox.keys.toList()) {
        notifications.add(NotificationDetails.fromJson(
          Map.from(notificationBox.get(notificationKey) ?? {}),
        ));
      }

      final currentUserId = AuthRepository.getIsStudentLogIn()
          ? (AuthRepository().getStudentProfileData().id ?? 0)
          : (AuthRepository.getParentDetails().id ?? 0);

      notifications = notifications
          .where((element) => element.userId == currentUserId)
          .toList();

      notifications
          .sort((first, second) => second.createdAt.compareTo(first.createdAt));

      return notifications;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<void> addNotificationTemporarily(
      {required Map<String, dynamic> data}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.reload();
      List<String> notifications =
          sharedPreferences.getStringList(temporarilyStoredNotificationsKey) ??
              List<String>.from([]);

      notifications.add(jsonEncode(data));

      await sharedPreferences.setStringList(
          temporarilyStoredNotificationsKey, notifications);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>>
      getTemporarilyStoredNotifications() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();
    List<String> notifications =
        sharedPreferences.getStringList(temporarilyStoredNotificationsKey) ??
            List<String>.from([]);

    return notifications
        .map((notificationData) =>
            Map<String, dynamic>.from(jsonDecode(notificationData) ?? {}))
        .toList();
  }

  static Future<void> clearTemporarilyNotification() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setStringList(temporarilyStoredNotificationsKey, []);
  }
}
