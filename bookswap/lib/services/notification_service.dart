import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Track last message timestamps to avoid duplicate notifications
  final Map<String, DateTime> _lastMessageTimestamps = {};
  final Map<String, DateTime> _lastSwapTimestamps = {};

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _requestPermissions();

    // Start listening for new messages and swap updates
    _listenForMessages();
    _listenForSwapUpdates();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - you can navigate to specific screens here
    print('Notification tapped: ${response.payload}');
  }

  // Listen for new messages
  void _listenForMessages() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified ||
            change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          final lastSenderId = data['lastSenderId'] as String?;
          final lastSenderName = data['lastSenderName'] as String?;
          final lastMessage = data['lastMessage'] as String?;
          final lastMessageTimeStr = data['lastMessageTime'] as String?;

          // Only notify if message is from someone else
          if (lastSenderId != null &&
              lastSenderId != currentUserId &&
              lastMessage != null &&
              lastSenderName != null) {
            
            // Check if we should send notification (avoid duplicates)
            final chatId = change.doc.id;
            final messageTime = lastMessageTimeStr != null 
                ? DateTime.tryParse(lastMessageTimeStr) ?? DateTime.now()
                : DateTime.now();

            if (_lastMessageTimestamps[chatId] == null ||
                messageTime.isAfter(_lastMessageTimestamps[chatId]!)) {
              _lastMessageTimestamps[chatId] = messageTime;

              // Check user's notification settings
              final userSettings = await _getUserSettings(currentUserId);
              final messageNotificationsEnabled = 
                  userSettings?['messageNotifications'] ?? true;

              if (messageNotificationsEnabled) {
                await _showMessageNotification(
                  lastSenderName,
                  lastMessage,
                  chatId,
                );
              }
            }
          }
        }
      }
    });
  }

  // Listen for swap offer updates
  void _listenForSwapUpdates() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    // Listen for offers where current user is the sender
    _firestore
        .collection('swap_offers')
        .where('senderId', isEqualTo: currentUserId)
        .snapshots()
        .listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          if (data == null) continue;

          final status = data['status'] as String?;
          final bookTitle = data['bookTitle'] as String?;
          final recipientName = data['recipientName'] as String?;

          // Only notify if swap was accepted
          if (status == 'Accepted' && bookTitle != null && recipientName != null) {
            final offerId = change.doc.id;
            final now = DateTime.now();

            // Avoid duplicate notifications
            if (_lastSwapTimestamps[offerId] == null ||
                now.difference(_lastSwapTimestamps[offerId]!).inSeconds > 5) {
              _lastSwapTimestamps[offerId] = now;

              // Check user's notification settings
              final userSettings = await _getUserSettings(currentUserId);
              final swapNotificationsEnabled = 
                  userSettings?['swapNotifications'] ?? true;

              if (swapNotificationsEnabled) {
                await _showSwapAcceptedNotification(
                  bookTitle,
                  recipientName,
                  offerId,
                );
              }
            }
          }
        }
      }
    });
  }

  Future<Map<String, dynamic>?> _getUserSettings(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user settings: $e');
      return null;
    }
  }

  Future<void> _showMessageNotification(
    String senderName,
    String message,
    String chatId,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'messages_channel',
      'Messages',
      channelDescription: 'Notifications for new messages',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      chatId.hashCode, // Use chat ID hash as notification ID
      'New message from $senderName',
      message,
      details,
      payload: 'chat:$chatId',
    );
  }

  Future<void> _showSwapAcceptedNotification(
    String bookTitle,
    String recipientName,
    String offerId,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'swaps_channel',
      'Swap Offers',
      channelDescription: 'Notifications for swap offer updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      offerId.hashCode, // Use offer ID hash as notification ID
      'Swap Request Accepted! 🎉',
      '$recipientName accepted your swap request for "$bookTitle"',
      details,
      payload: 'swap:$offerId',
    );
  }

  // Method to show a test notification
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notification channel',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'Notifications are working correctly!',
      details,
    );
  }
}