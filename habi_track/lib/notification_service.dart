import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  static const int _dailyId = 1001; // identifiant fixe

  /// Initialise les notifications locales
  Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _fln.initialize(initSettings);
  }

  /// Paramètres par défaut des notifications
  NotificationDetails _defaultDetails() {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'habitrack_default_channel',
      'HabiTrack Notifications',
      channelDescription: 'Notifications de progression et rappels HabiTrack',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const DarwinNotificationDetails ios = DarwinNotificationDetails();

    return const NotificationDetails(android: android, iOS: ios);
  }

  /// Affiche une notification instantanée
  Future<void> showInstant(String title, String body) async {
    await _fln.show(
      DateTime.now().millisecondsSinceEpoch % 100000, // id unique simplifié
      title,
      body,
      _defaultDetails(),
    );
  }

  /// Programme un rappel quotidien toutes les 24h à partir de MAINTENANT
  Future<void> enableDailyReminder() async {
    await _fln.periodicallyShow(
      _dailyId,
      'Rappel HabiTrack',
      'Pense à valider au moins une habitude aujourd\'hui ✨',
      RepeatInterval.daily,
      _defaultDetails(),
      androidScheduleMode: AndroidScheduleMode.inexact, // correction v18+
    );
  }

  /// Désactive le rappel quotidien
  Future<void> disableDailyReminder() async {
    await _fln.cancel(_dailyId);
  }
}