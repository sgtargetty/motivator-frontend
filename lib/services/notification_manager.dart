import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

import '../screens/amber_alert_screen.dart';

@pragma("vm:entry-point")
class NotificationManager {
  static NotificationManager? _instance;
  static NotificationManager get instance => _instance ??= NotificationManager._();
  NotificationManager._();

  // Global navigator key reference (will be set by main app)
  GlobalKey<NavigatorState>? _navigatorKey;
  
  // 🚨 CRITICAL: Prevent infinite loops
  bool _isAmberAlertActive = false;
  
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  // ===== SETUP NOTIFICATION LISTENERS =====
  void setupNotificationListeners() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onNotificationActionReceived,
      onNotificationCreatedMethod: _onNotificationCreated,
      onNotificationDisplayedMethod: _onNotificationDisplayed,
      onDismissActionReceivedMethod: _onNotificationDismissed,
    );
    print("✅ Notification listeners set up successfully");
  }

  // ===== ENHANCED PERMISSION HANDLING FOR AMBER ALERTS =====
  Future<void> requestAwesomeNotificationPermissions() async {
    print("🔐 Requesting enhanced notification permissions for Amber Alerts...");
    
    // 1. Basic notification permission
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    
    if (isAllowed) {
      print('✅ Basic notification permissions granted');
      
      // 2. Request critical alert permissions (iOS specific but doesn't hurt on Android)
      try {
        await AwesomeNotifications().requestPermissionToSendNotifications(
          channelKey: 'amber_alert_channel',
          permissions: [
            NotificationPermission.Alert,
            NotificationPermission.Sound,
            NotificationPermission.Badge,
            NotificationPermission.Vibration,
            NotificationPermission.Light,
            NotificationPermission.CriticalAlert,
            NotificationPermission.FullScreenIntent,
          ],
        );
        print('✅ Critical alert permissions requested');
      } catch (e) {
        print('⚠️ Critical alert permission request failed (might not be supported): $e');
      }
      
      // 3. Request additional Android permissions for FORCEFUL hijacking
      if (Platform.isAndroid) {
        try {
          // System alert window - CRITICAL for overlay
          var overlayStatus = await Permission.systemAlertWindow.request();
          print('🛡️ System overlay permission: $overlayStatus');
          
          // Battery optimization exemption - CRITICAL for background
          var batteryStatus = await Permission.ignoreBatteryOptimizations.request();
          print('🔋 Battery optimization exemption: $batteryStatus');
          
          // Do not disturb policy access
          var dndStatus = await Permission.accessNotificationPolicy.request();
          print('🔇 Do not disturb access: $dndStatus');
          
          // Exact alarm scheduling
          var alarmStatus = await Permission.scheduleExactAlarm.request();
          print('⏰ Exact alarm permission: $alarmStatus');
          
          // Phone permissions for maximum priority
          var phoneStatus = await Permission.phone.request();
          print('📞 Phone permission: $phoneStatus');
          
          // 🚨 FORCEFUL PERMISSION SUCCESS CHECK
          if (overlayStatus.isGranted && batteryStatus.isGranted) {
            print('🔥 FORCEFUL HIJACKING PERMISSIONS GRANTED!');
          } else {
            print('⚠️ Some forceful permissions denied - amber alerts may be limited');
          }
          
        } catch (e) {
          print('❌ Forceful permission request error: $e');
        }
      }
      
    } else {
      print('❌ Basic notification permissions denied');
    }
  }

  // 🚨 FORCEFUL AMBER ALERT WITH EMERGENCY VIBRATION
  Future<void> createForcefulAmberAlert({
    required int id,
    required String title,
    required String body,
    required Map<String, String> payload,
    NotificationSchedule? schedule,
  }) async {
    print('🚨 CREATING FORCEFUL AMBER ALERT - EMERGENCY VIBRATION MODE');
    
    try {
      // 🚨 STEP 1: Create maximum priority notification with EMERGENCY VIBRATION
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'amber_alert_channel',
          title: title,
          body: body,
          payload: payload,
          
          // 🚨 EMERGENCY DISPLAY SETTINGS
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Alarm,
          
          // 🚨 MAXIMUM VISIBILITY FLAGS
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          displayOnForeground: true,
          displayOnBackground: true,
          showWhen: true,
          
          // 🚨 VISUAL DOMINANCE
          color: Colors.red,
          backgroundColor: Colors.red,
          largeIcon: 'resource://drawable/ic_launcher',
          
          // 🚨 INTERACTION SETTINGS
          locked: false,
          autoDismissible: false,
          
          // 🚨 OVERRIDE SETTINGS
          actionType: ActionType.KeepOnTop,
          
          // 🚨 CUSTOM EMERGENCY VIBRATION PATTERN (SOS + ALERT)
          customSound: 'resource://raw/alarm',
        ),
        schedule: schedule,
      );
      
      // 🚨 STEP 2: TRIPLE EMERGENCY VIBRATION SEQUENCE
      await _triggerEmergencyVibrationSequence();
      
      print('🔥 FORCEFUL AMBER ALERT DEPLOYED - EMERGENCY VIBRATION ACTIVE');
      
    } catch (e) {
      print('❌ Error creating forceful amber alert: $e');
      // Fallback to regular high-priority notification
      await createNotification(
        id: id,
        channelKey: 'amber_alert_channel',
        title: title,
        body: body,
        payload: payload,
        schedule: schedule,
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
        category: NotificationCategory.Alarm,
        color: Colors.red,
      );
      print('🔄 Fallback amber alert created');
    }
  }

  // 🚨 EMERGENCY VIBRATION SEQUENCE - REAL ANDROID VIBRATION
  Future<void> _triggerEmergencyVibrationSequence() async {
    print('🚨 TRIGGERING EMERGENCY VIBRATION SEQUENCE');
    
    try {
      // Use platform channel to trigger real Android vibration
      const platform = MethodChannel('flutter/platform_views');
      
      // PATTERN 1: SOS Pattern (3 short, 3 long, 3 short)
      for (int i = 0; i < 3; i++) {
        HapticFeedback.heavyImpact(); // Short
        await Future.delayed(const Duration(milliseconds: 150));
      }
      await Future.delayed(const Duration(milliseconds: 300));
      
      for (int i = 0; i < 3; i++) {
        // Simulate long vibration with multiple heavy impacts
        for (int j = 0; j < 3; j++) {
          HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 50));
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }
      await Future.delayed(const Duration(milliseconds: 300));
      
      for (int i = 0; i < 3; i++) {
        HapticFeedback.heavyImpact(); // Short
        await Future.delayed(const Duration(milliseconds: 150));
      }
      
      // Brief pause
      await Future.delayed(const Duration(milliseconds: 500));
      
      // PATTERN 2: Rapid Emergency Burst
      for (int i = 0; i < 8; i++) {
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // PATTERN 3: Final Alert Sequence
      await Future.delayed(const Duration(milliseconds: 300));
      for (int i = 0; i < 15; i++) {
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 80));
      }
      
      print('✅ Emergency vibration sequence completed');
      
    } catch (e) {
      print('❌ Error in emergency vibration sequence: $e');
      // Ultimate fallback - continuous haptic feedback
      for (int i = 0; i < 20; i++) {
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
  }

  // 🚨 OVERRIDE SILENT MODE FOR EMERGENCY ALERTS
  Future<void> overrideSilentModeForEmergency() async {
    print('🚨 ATTEMPTING TO OVERRIDE SILENT MODE FOR EMERGENCY');
    
    try {
      // Create a high-priority call-category notification that bypasses silent mode
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 999996,
          channelKey: 'amber_alert_channel',
          title: '🚨 EMERGENCY OVERRIDE ACTIVE',
          body: 'Silent mode bypassed for critical alert',
          category: NotificationCategory.Call, // Call category bypasses silent mode
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          displayOnForeground: true,
          displayOnBackground: true,
          locked: false,
          autoDismissible: true,
          color: Colors.red,
          // Custom vibration pattern for override notification
          payload: {
            'emergencyOverride': 'true',
            'silentBypass': 'true',
          },
        ),
      );
      
      // Cancel the override notification after brief display
      await Future.delayed(const Duration(milliseconds: 500));
      await AwesomeNotifications().cancel(999996);
      
      print('✅ Silent mode override notification deployed and cancelled');
      
    } catch (e) {
      print('❌ Error overriding silent mode: $e');
    }
  }

  // ===== STANDARD NOTIFICATION CREATION =====
  Future<void> createNotification({
    required int id,
    required String channelKey,
    required String title,
    required String body,
    Map<String, String>? payload,
    NotificationSchedule? schedule,
    NotificationLayout? layout,
    bool wakeUpScreen = false,
    bool fullScreenIntent = false,
    bool criticalAlert = false,
    NotificationCategory? category,
    Color? color,
  }) async {
    try {
      if (channelKey == 'amber_alert_channel') {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: id,
            channelKey: channelKey,
            title: title,
            body: body,
            payload: payload,
            notificationLayout: NotificationLayout.BigText,
            wakeUpScreen: true,
            fullScreenIntent: true,
            criticalAlert: true,
            category: NotificationCategory.Alarm,
            color: color ?? Colors.red,
            displayOnForeground: true,
            displayOnBackground: true,
            locked: true,
            autoDismissible: false,
            showWhen: true,
            actionType: ActionType.KeepOnTop,
          ),
          schedule: schedule,
        );
      } else {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: id,
            channelKey: channelKey,
            title: title,
            body: body,
            payload: payload,
            notificationLayout: layout ?? NotificationLayout.Default,
            wakeUpScreen: wakeUpScreen,
            fullScreenIntent: fullScreenIntent,
            criticalAlert: criticalAlert,
            category: category,
            color: color,
            displayOnForeground: true,
            displayOnBackground: true,
          ),
          schedule: schedule,
        );
      }
      
      print('✅ Notification created successfully: $title');
    } catch (e) {
      print('❌ Error creating notification: $e');
      rethrow;
    }
  }

  // ===== NOTIFICATION EVENT HANDLERS =====
  @pragma("vm:entry-point")
  static Future<void> _onNotificationCreated(ReceivedNotification receivedNotification) async {
    print('🔔 Notification created: ${receivedNotification.title}');
    
    // 🚨 IGNORE helper notifications to prevent loops
    if (receivedNotification.id == 999999) {
      print('🔄 Helper notification created (ignoring to prevent loops)');
      return;
    }
    
    // 🚨 If it's an amber alert, add extra logging
    if (receivedNotification.channelKey == 'amber_alert_channel') {
      print('🚨 AMBER ALERT NOTIFICATION CREATED: ${receivedNotification.title}');
      
      try {
        HapticFeedback.heavyImpact();
      } catch (e) {
        print('⚠️ Error triggering amber alert feedback: $e');
      }
    }
  }

  @pragma("vm:entry-point")
  static Future<void> _onNotificationDisplayed(ReceivedNotification receivedNotification) async {
    print('🔔 Notification displayed: ${receivedNotification.title}');
    
    // 🚨 CRITICAL: Ignore helper notifications to prevent infinite loops
    if (receivedNotification.id == 999999) {
      print('🔄 Helper notification displayed (ignoring to prevent loops)');
      return;
    }
    
    // 🚨 Handle amber alert trigger notifications (for future scheduled alerts)
    if (receivedNotification.payload?['triggerAmberAlert'] == 'true') {
      print('🚨 AMBER ALERT TRIGGER DETECTED - DEPLOYING AMBER ALERT NOW!');
      
      final taskDescription = receivedNotification.payload?['taskDescription'] ?? 'Emergency Task';
      final motivationalLine = receivedNotification.payload?['motivationalLine'] ?? 'Critical alert!';
      final audioFilePath = receivedNotification.payload?['audioFilePath'] ?? '';
      
      await _deployAmberAlert(
        taskDescription: taskDescription,
        motivationalLine: motivationalLine,
        audioFilePath: audioFilePath,
        triggerId: receivedNotification.id!,
      );
      
      try {
        await AwesomeNotifications().cancel(receivedNotification.id!);
        print('🚨 Trigger notification hidden - amber alert deployed');
      } catch (e) {
        print('⚠️ Could not hide trigger notification: $e');
      }
      
      return;
    }
    
    // 🚨 CRITICAL FIX: Handle amber alerts - ONLY STRATEGY A HIJACKS SCREEN
    if (receivedNotification.channelKey == 'amber_alert_channel') {
      print('🚨 AMBER ALERT DISPLAYED - CHECKING FOR AUTO-HIJACK...');
      
      final isEmergencyAlert = receivedNotification.payload?['emergency'] == 'true';
      final strategy = receivedNotification.payload?['strategy'];
      
      print('🔍 Emergency: $isEmergencyAlert, Strategy: $strategy');
      
      // 🎯 ONLY STRATEGY A TRIGGERS SCREEN HIJACKING
      if (isEmergencyAlert && strategy == 'A') {
        print('🚨 AMBER ALERT STRATEGY A - HIJACKING SCREEN AUTOMATICALLY');
        print('🚨 AUTO-LAUNCHING FULL SCREEN ALERT NOW!');
        
        NotificationManager.instance._showLockScreenBypassAlert(
          title: receivedNotification.title ?? '🚨 EMERGENCY ALERT 🚨',
          message: receivedNotification.payload?['motivationalLine'] ?? 'Critical motivational emergency requires your attention!',
          taskDescription: receivedNotification.payload?['taskDescription'],
          payload: receivedNotification.payload,
          audioPath: receivedNotification.payload?['audioFilePath'],
        );
      } else {
        print('🔄 Amber alert displayed but not Strategy A - no auto-hijack');
      }
    }
  }

  @pragma("vm:entry-point")
  static Future<void> _onNotificationDismissed(ReceivedAction receivedAction) async {
    print('🔔 Notification dismissed: ${receivedAction.title}');
    
    if (receivedAction.id == 999999) {
      print('🔄 Helper notification dismissed');
      return;
    }
    
    if (receivedAction.channelKey == 'amber_alert_channel') {
      print('🚨 AMBER ALERT DISMISSED');
      NotificationManager.instance._isAmberAlertActive = false;
      print('🔄 Amber alert flag reset due to dismissal');
    }
  }

  @pragma("vm:entry-point")
  static Future<void> _onNotificationActionReceived(ReceivedAction receivedAction) async {
    print('🔔 Notification tapped: ${receivedAction.payload}');
    print('🚨 DEBUG: _onNotificationActionReceived was called!');
    
    try {
      if (receivedAction.id == 999999) {
        print('🔄 Helper notification tapped (ignoring)');
        return;
      }
      
      final isAmberAlert = receivedAction.channelKey == 'amber_alert_channel';
      final isEmergencyAlert = receivedAction.payload?['emergency'] == 'true';
      final strategy = receivedAction.payload?['strategy'];
      
      if (isAmberAlert || isEmergencyAlert) {
        print('🚨 AMBER ALERT TAPPED - STRATEGY: $strategy');
        print('🚨 Amber alert screen already hijacked - providing feedback only');
        
        try {
          for (int i = 0; i < 3; i++) {
            HapticFeedback.heavyImpact();
            await Future.delayed(const Duration(milliseconds: 200));
          }
        } catch (e) {
          print('⚠️ Error with amber alert tap feedback: $e');
        }
        
        return;
      }
      
      // ===== NORMAL NOTIFICATION HANDLING (NON-AMBER ALERTS) =====
      if (receivedAction.payload != null && receivedAction.payload!.isNotEmpty) {
        final taskDescription = receivedAction.payload!['taskDescription'];
        final motivationalLine = receivedAction.payload!['motivationalLine'];
        final audioFilePath = receivedAction.payload!['audioFilePath'];
        final forceOverrideSilent = receivedAction.payload!['forceOverrideSilent'] == 'true';
        
        print('🎯 Task: $taskDescription');
        print('💬 Message: $motivationalLine');
        print('🎵 Audio file: $audioFilePath');
        print('🔊 Override silent: $forceOverrideSilent');
        
        if (audioFilePath != null && audioFilePath.isNotEmpty) {
          await NotificationManager.instance._playEmergencyAudio(audioFilePath, forceOverrideSilent);
        }
      }
    } catch (e) {
      print('❌ Error handling notification action: $e');
    }
  }

  // ===== AMBER ALERT DEPLOYMENT =====
  static Future<void> _deployAmberAlert({
    required String taskDescription,
    required String motivationalLine,
    required String audioFilePath,
    required int triggerId,
  }) async {
    print('🚨 DEPLOYING AMBER ALERT FROM TRIGGER');
    
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 888888,
          channelKey: 'amber_alert_channel',
          title: '🚨 EMERGENCY MOTIVATIONAL ALERT 🚨',
          body: 'CRITICAL ALERT: $taskDescription\n\nYour immediate attention is required!',
          summary: 'EMERGENCY ALERT SYSTEM',
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          locked: false,
          autoDismissible: false,
          showWhen: true,
          displayOnForeground: true,
          displayOnBackground: true,
          color: Colors.red,
          backgroundColor: Colors.red,
          payload: {
            'taskDescription': taskDescription,
            'motivationalLine': motivationalLine,
            'audioFilePath': audioFilePath,
            'alertType': 'full_screen_intent',
            'emergency': 'true',
            'priority': 'maximum',
            'strategy': 'A',
            'isAmberAlert': 'true',
            'playAudio': 'true',
          },
        ),
      );
      
      print('🚨 Amber alert deployed from trigger successfully!');
      
    } catch (e) {
      print('❌ Error deploying amber alert from trigger: $e');
    }
  }

  // 🚨 Show Lock Screen Bypass Amber Alert
  void _showLockScreenBypassAlert({
    required String title,
    required String message,
    String? taskDescription,
    Map<String, String?>? payload,
    String? audioPath,
  }) async {
    print('🚨 LOCK SCREEN BYPASS: Attempting to hijack screen for amber alert');
    
    if (_isAmberAlertActive) {
      print('🔄 Amber alert already active - skipping duplicate');
      return;
    }
    
    _isAmberAlertActive = true;
    
    try {
      // 🚨 STEP 1: Force app to foreground using native Android intent
      await _forceAppToForegroundNative();
      
      // 🚨 STEP 2: Small delay to let app come to foreground
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 🚨 STEP 3: Now attempt screen hijacking
      if (_navigatorKey?.currentState != null) {
        print('🚨 SCREEN HIJACK: Launching amber alert screen');
        
        await _navigatorKey!.currentState!.push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => AmberAlertScreen(
              title: title,
              message: message,
              taskDescription: taskDescription ?? 'Emergency Alert',
              audioPath: audioPath,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            settings: const RouteSettings(name: '/amber-alert'),
            barrierDismissible: false,
            fullscreenDialog: true,
          ),
        );
        
        _isAmberAlertActive = false;
        print('🔄 Amber alert screen closed');
        
        // Manual reset of amber alert flag when screen closes
        NotificationManager.instance.resetAmberAlertFlag();
        
      } else {
        print('❌ Navigator key not available for amber alert');
        _isAmberAlertActive = false;
      }
    } catch (e) {
      print('❌ Error showing amber alert screen: $e');
      _isAmberAlertActive = false;
    }
  }

  // 🚨 NEW: Force app to foreground using native Android mechanism
  Future<void> _forceAppToForegroundNative() async {
  print('🚨 FORCING APP TO FOREGROUND USING NATIVE INTENT');
  
  try {
    // Create a high-priority notification that forces the app to foreground
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999997,
        channelKey: 'amber_alert_channel',
        title: 'EMERGENCY SYSTEM OVERRIDE',
        body: 'Bringing app to foreground for critical alert...',
        payload: {
          'emergency': 'true',
          'strategy': 'A',
          'isAmberAlert': 'true',
          'taskDescription': 'System Override',
          'motivationalLine': 'Forcing app to foreground for emergency alert',
          'bypassLockScreen': 'true',
        },
        // 🚨 CRITICAL: Full screen intent settings for locked screen
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
        category: NotificationCategory.Alarm,
        displayOnForeground: true,
        displayOnBackground: true,
        locked: false,
        autoDismissible: true,
        showWhen: false,
        color: Colors.red,
      ),
    );
    
    print('✅ Foreground notification created successfully');
    
    // 🚨 STEP 2: Wait briefly for the notification to take effect
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 🚨 STEP 3: Cancel the helper notification immediately
    try {
      await AwesomeNotifications().cancel(999997);
      print('✅ Helper notification cleaned up');
    } catch (e) {
      print('⚠️ Could not clean up helper notification: $e');
    }
    
  } catch (e) {
    print('❌ Error forcing app to foreground: $e');
    rethrow;
  }
}

  // ===== AUDIO HANDLING =====
  Future<void> _playEmergencyAudio(String audioFilePath, bool forceOverrideSilent) async {
    print('🎵 Playing emergency audio: $audioFilePath');
    
    try {
      final player = AudioPlayer();
      
      if (forceOverrideSilent) {
        print('🔊 Force override silent mode enabled');
      }
      
      await player.setFilePath(audioFilePath);
      await player.setVolume(1.0);
      await player.play();
      
      print('✅ Emergency audio playback started');
      
    } catch (e) {
      print('❌ Error playing emergency audio: $e');
    }
  }

  // ===== UTILITY METHODS =====
  Future<bool> verifyAudioFile(String audioFilePath) async {
    try {
      if (audioFilePath.isEmpty) {
        print('⚠️ Empty audio file path provided');
        return false;
      }
      
      final file = File(audioFilePath);
      final exists = await file.exists();
      
      if (exists) {
        final size = await file.length();
        print('✅ Audio file verified: $audioFilePath ($size bytes)');
        return true;
      } else {
        print('❌ Audio file does not exist: $audioFilePath');
        return false;
      }
    } catch (e) {
      print('❌ Error verifying audio file: $e');
      return false;
    }
  }

  void resetAmberAlertFlag() {
    _isAmberAlertActive = false;
    print('🔄 Amber alert flag manually reset');
  }
  
  void forceResetAmberAlert() {
    _isAmberAlertActive = false;
    print('🔄 Amber alert state force reset');
  }

  Future<bool> areNotificationsAllowed() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  Future<bool> requestBasicPermissions() async {
    return await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  Future<List<NotificationModel>> getScheduledNotifications() async {
    return await AwesomeNotifications().listScheduledNotifications();
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  void debugTestAmberAlert() {
    print('🧪 DEBUG: Testing amber alert navigation...');
    _showLockScreenBypassAlert(
      title: 'DEBUG TEST ALERT',
      message: 'This is a debug test',
      taskDescription: 'debug test',
    );
  }
}