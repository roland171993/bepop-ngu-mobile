import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:bepop_ngu/app/routes.dart';
import 'package:bepop_ngu/data/models/notificationDetails.dart';
import 'package:bepop_ngu/data/repositories/authRepository.dart';
import 'package:bepop_ngu/data/repositories/notificationRepository.dart';
import 'package:bepop_ngu/ui/screens/home/homeScreen.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:bepop_ngu/utils/hiveBoxKeys.dart';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: avoid_classes_with_only_static_members
class NotificationUtility {
  static String generalNotificationType = "general";

  static String assignmentlNotificationType = "assignment";
  static String paymentNotificationType = "payment";
  static String notificationType = "Notification";
  static String messageType = "Message";

  static Future<void> setUpNotificationService() async {
    try {
      NotificationSettings notificationSettings =
          await FirebaseMessaging.instance.getNotificationSettings();

      //ask for permission
      if (notificationSettings.authorizationStatus ==
              AuthorizationStatus.notDetermined ||
          notificationSettings.authorizationStatus ==
              AuthorizationStatus.denied) {
        notificationSettings =
            await FirebaseMessaging.instance.requestPermission();

        //if permission is provisionnal or authorised
        if (notificationSettings.authorizationStatus ==
                AuthorizationStatus.authorized ||
            notificationSettings.authorizationStatus ==
                AuthorizationStatus.provisional) {
          initNotificationListener();
        }

        //if permission denied
      } else if (notificationSettings.authorizationStatus ==
          AuthorizationStatus.denied) {
        return;
      }
      initNotificationListener();
    } catch (e) {
      // Handle Google Play services errors in emulatorliveBusTracking
      print('Firebase messaging setup failed: $e');
      // Continue without Firebase messaging in emulator
    }
  }

  static void initNotificationListener() {
    try {
      // Initialize Firebase messaging listeners
      FirebaseMessaging.onMessage.listen(foregroundMessageListener);
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedAppListener);
    } catch (e) {
      // Handle Google Play services errors in emulator
      print('Firebase messaging listener setup failed: $e');
    }
  }

  static Future<void> foregroundMessageListener(
    RemoteMessage remoteMessage,
  ) async {
    await FirebaseMessaging.instance.getToken();

    final type = (remoteMessage.data['type'] ?? "").toString();

    if (type == paymentNotificationType) {
      Future.delayed(Duration(seconds: 5), () {
        if (Get.currentRoute == Routes.confirmPayment) {
          Get.back();
        }
      });
    } else if (type.toLowerCase() == notificationType.toLowerCase()) {
      // Clear temporary notifications to prevent duplicates when processing in foreground
      NotificationRepository.clearTemporarilyNotification();

      NotificationRepository.addNotification(
          notificationDetails: NotificationDetails(
              userId: AuthRepository.getIsStudentLogIn()
                  ? (AuthRepository().getStudentProfileData().id ?? 0)
                  : (AuthRepository.getParentDetails().id ?? 0),
              attachmentUrl: remoteMessage.data['image'] ?? "",
              body: remoteMessage.notification?.body ?? "",
              createdAt: DateTime.timestamp(),
              title: remoteMessage.notification?.title ?? ""));
    }

//

    createLocalNotification(dimissable: true, message: remoteMessage);
  }

  static void onMessageOpenedAppListener(RemoteMessage remoteMessage) {
    _onTapNotificationScreenNavigateCallback(
      remoteMessage.data['type'] ?? "",
      remoteMessage.data,
    );
  }

  static void _onTapNotificationScreenNavigateCallback(
    String type,
    Map<String, dynamic> data,
  ) {
    if (type.isEmpty) {
      return;
    }

    if (type == generalNotificationType) {
      if (Get.currentRoute != Routes.noticeBoard) {
        Get.toNamed(Routes.noticeBoard);
      }
    } else if (type == assignmentlNotificationType) {
      HomeScreen.homeScreenKey.currentState?.navigateToAssignmentContainer();
    } else if (type == paymentNotificationType) {
    } else if (type == messageType) {
      if (Get.currentRoute != Routes.chatContacts) {
        Get.toNamed(Routes.chatContacts);
      }
    } else if (type == notificationType) {
      if (Get.currentRoute != Routes.notifications) {
        Get.toNamed(Routes.notifications);
      }
    }
  }

  static Future<void> initializeAwesomeNotification() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: notificationChannelKey,
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        vibrationPattern: highVibrationPattern,
        importance: NotificationImportance.Max,
        playSound: true,
      ),
      NotificationChannel(
        channelKey: 'download_channel',
        channelName: 'Download Notifications',
        channelDescription: 'Notifications for file downloads with progress',
        importance: NotificationImportance.High,
        playSound: false,
        enableVibration: false,
      ),
      NotificationChannel(
        channelKey: 'download_complete_channel',
        channelName: 'Download Complete Notifications',
        channelDescription: 'Shows download completion status',
        importance: NotificationImportance.Max,
        playSound: false,
        enableVibration: false,
      ),
    ]);
  }

  static Future<bool> isLocalNotificationAllowed() async {
    const notificationPermission = Permission.notification;
    final status = await notificationPermission.status;
    return status.isGranted;
  }

  /// Use this method to detect when a new notification or a schedule is created
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    _onTapNotificationScreenNavigateCallback(
      (receivedAction.payload ?? {})['type'] ?? "",
      Map.from(receivedAction.payload ?? {}),
    );
  }

  // Download notification methods
  static Future<void> showDownloadNotification({
    required int notificationId,
    required String fileName,
    required int progress,
  }) async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) return;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'download_channel',
          title: Utils.getTranslatedLabel(downloadingFileKey),
          body: fileName,
          notificationLayout: NotificationLayout.ProgressBar,
          progress: progress.toDouble(),
          category: NotificationCategory.Progress,
          autoDismissible: false,
          showWhen: true,
        ),
      );
    } catch (e) {
      // Handle notification errors silently
    }
  }

  static Future<void> updateDownloadNotification({
    required int notificationId,
    required String fileName,
    required int progress,
  }) async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) return;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'download_channel',
          title: '${Utils.getTranslatedLabel(downloadingFileKey)} ($progress%)',
          body: fileName,
          notificationLayout: NotificationLayout.ProgressBar,
          progress: progress.toDouble(),
          category: NotificationCategory.Progress,
          autoDismissible: false,
          showWhen: true,
        ),
      );
    } catch (e) {
      // Handle notification errors silently
    }
  }

  static Future<void> showDownloadCompleteNotification({
    required int notificationId,
    required String fileName,
  }) async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) return;

      // Use a different notification ID for completion to avoid conflicts
      final completionNotificationId = notificationId + 1000;

      // First, cancel the progress notification
      try {
        await AwesomeNotifications().dismiss(notificationId);
      } catch (e) {
        // Handle dismissal errors silently
      }

      // Small delay to ensure the progress notification is cancelled
      await Future.delayed(const Duration(milliseconds: 100));

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: completionNotificationId,
          channelKey: 'download_complete_channel',
          title: '${Utils.getTranslatedLabel(downloadCompleteKey)} ✅',
          body:
              '$fileName ${Utils.getTranslatedLabel(fileDownloadedSuccessfullyKey)}',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Status,
          autoDismissible: true,
          showWhen: true,
          wakeUpScreen: false,
          fullScreenIntent: false,
        ),
      );

      // Auto-dismiss the notification after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        try {
          AwesomeNotifications().dismiss(completionNotificationId);
        } catch (e) {
          // Handle dismissal errors silently
        }
      });
    } catch (e) {
      // Handle notification errors silently
    }
  }

  static Future<void> showDownloadErrorNotification({
    required int notificationId,
    required String fileName,
    required String error,
  }) async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) return;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'download_channel',
          title: '${Utils.getTranslatedLabel(downloadFailedKey)} ❌',
          body:
              '${Utils.getTranslatedLabel(failedToDownloadFileKey)} $fileName',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Error,
          autoDismissible: true,
          showWhen: true,
          wakeUpScreen: false,
          fullScreenIntent: false,
        ),
      );

      // Auto-dismiss the notification after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        try {
          AwesomeNotifications().dismiss(notificationId);
        } catch (e) {
          // Handle dismissal errors silently
        }
      });
    } catch (e) {
      // Handle notification errors silently
    }
  }

  static Future<void> createLocalNotification({
    required bool dimissable,
    required RemoteMessage message,
  }) async {
    final String title = message.notification?.title ?? "";
    final String body = message.notification?.body ?? "";
    final String imageUrl = message.data['image'] ?? "";

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        title: title,
        body: body,
        id: 1,
        locked: !dimissable,
        payload: {"type": message.data['type'] ?? ""},
        channelKey: notificationChannelKey,
        notificationLayout: NotificationLayout.BigPicture,
        autoDismissible: dimissable,
        bigPicture: imageUrl,
        largeIcon: imageUrl,
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage remoteMessage) async {
  //perform any background task if needed here
  final type = (remoteMessage.data['type'] ?? "").toString();
  if (type == "Notification") {
    await Hive.initFlutter();
    await Hive.openBox(authBoxKey);
    NotificationRepository.addNotificationTemporarily(
        data: NotificationDetails(
                userId: AuthRepository.getIsStudentLogIn()
                    ? (AuthRepository().getStudentProfileData().id ?? 0)
                    : (AuthRepository.getParentDetails().id ?? 0),
                attachmentUrl: remoteMessage.data['image'] ?? "",
                body: remoteMessage.notification?.body ?? "",
                createdAt: DateTime.timestamp(),
                title: remoteMessage.notification?.title ?? "")
            .toJson());
  }
}
