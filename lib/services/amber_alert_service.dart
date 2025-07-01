import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
// 🔥 REMOVED: vibration import - using haptic only
import 'dart:async';

class AmberAlertService {
  
  // ===== BASIC NOTIFICATION TESTS =====
  
  static Future<void> testNotificationWithoutPayload(BuildContext context) async {
    print("🧪 Testing basic notification WITHOUT payload...");
    
    final now = DateTime.now();
    final scheduledTime = now.add(const Duration(seconds: 10));
    
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999,
        channelKey: 'test_channel',
        title: '🧪 Basic Test',
        body: 'Simple test - no payload',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledTime),
    );
    
    print("✅ Scheduled basic test notification for $scheduledTime");
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🧪 Basic notification scheduled for 10 seconds'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  static Future<void> testNotificationWithSimplePayload(BuildContext context) async {
    print("🧪 Testing enhanced notification WITH simple payload...");
    
    final now = DateTime.now();
    final scheduledTime = now.add(const Duration(seconds: 10));
    
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 998,
        channelKey: 'motivator_reminders',
        title: '🧪 Enhanced Test',
        body: 'Enhanced test - basic payload',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        payload: {'data': 'simple_string_test'},
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledTime),
    );
    
    print("✅ Scheduled enhanced test notification with simple payload");
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🧪 Enhanced payload test scheduled for 10 seconds'),
        backgroundColor: Colors.green,
      ),
    );
  }

  static Future<void> testNotificationWithJsonPayload(BuildContext context) async {
    print("🧪 Testing full payload notification...");
    
    final now = DateTime.now();
    final scheduledTime = now.add(const Duration(seconds: 10));
    
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 997,
        channelKey: 'motivator_reminders',
        title: '🧪 Full Test',
        body: 'Full payload data test with wake up',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        fullScreenIntent: true,
        payload: {
          'taskDescription': 'Test Task with Full Features',
          'motivationalLine': 'You can do this! This is a full test!',
          'audioFilePath': '/test/path/full_audio.mp3',
          'forceOverrideSilent': 'true',
        },
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledTime),
    );
    
    print("✅ Scheduled full test notification with payload data");
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🧪 Full payload test scheduled for 10 seconds'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // ===== ENHANCED HAPTIC FEEDBACK TESTS =====
  
  // 🔥 NEW: Test Enhanced Haptic Patterns (No Vibration Package)
  static Future<void> testEnhancedVibrationOnly(BuildContext context) async {
    print("🚨 Testing ENHANCED HAPTIC PATTERNS (No vibration package)...");
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 Testing enhanced haptic feedback patterns...'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
    
    try {
      // 🚨 SOS Pattern with haptic: 3 short, 3 long, 3 short
      print('🚨 Playing SOS haptic pattern...');
      
      // 3 short
      for (int i = 0; i < 3; i++) {
        HapticFeedback.selectionClick();
        await Future.delayed(Duration(milliseconds: 150));
      }
      await Future.delayed(Duration(milliseconds: 300));
      
      // 3 long (using heavy impact to simulate longer vibration)
      for (int i = 0; i < 3; i++) {
        HapticFeedback.heavyImpact();
        await Future.delayed(Duration(milliseconds: 100));
        HapticFeedback.heavyImpact();
        await Future.delayed(Duration(milliseconds: 200));
      }
      await Future.delayed(Duration(milliseconds: 300));
      
      // 3 short
      for (int i = 0; i < 3; i++) {
        HapticFeedback.selectionClick();
        await Future.delayed(Duration(milliseconds: 150));
      }
      
      await Future.delayed(Duration(milliseconds: 500));
      
      // Emergency burst pattern
      print('🚨 Playing emergency burst haptic pattern...');
      for (int i = 0; i < 8; i++) {
        HapticFeedback.heavyImpact();
        await Future.delayed(Duration(milliseconds: 100));
      }
      
      await Future.delayed(Duration(milliseconds: 300));
      
      // Final emergency haptic
      print('🚨 Playing final emergency haptic...');
      for (int i = 0; i < 5; i++) {
        HapticFeedback.heavyImpact();
        await Future.delayed(Duration(milliseconds: 200));
      }
      
      print('✅ Enhanced haptic feedback test completed successfully!');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Enhanced haptic feedback patterns completed!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      print('❌ Haptic feedback test failed: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Haptic feedback failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ===== ENHANCED COMBINATION TESTS =====

  // 🔥 NEW: Test All Amber Strategies WITH HAPTIC
  static Future<void> testAllAmberStrategiesWithVibration(BuildContext context) async {
    print("🚨 TESTING STRATEGY A WITH ENHANCED HAPTIC...");
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 Launching STRATEGY A with enhanced haptic in 3 seconds...'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
    
    // Wait 3 seconds, then launch enhanced version
    await Future.delayed(const Duration(seconds: 3));
    
    // Enhanced haptic first
    await testEnhancedVibrationOnly(context);
    
    // Wait for haptic to complete
    await Future.delayed(const Duration(seconds: 2));
    
    // Then launch Strategy A with haptic integration
    await createFullScreenIntentNotification(context);
    
    print("🚨 Strategy A with enhanced haptic deployed!");
  }

  // 🔥 NEW: Ultimate test with haptic
  static Future<void> testTrueFullScreenAmberAlertWithVibration(BuildContext context) async {
    print("🚨 Testing ULTIMATE FULL SCREEN amber alert WITH HAPTIC...");
    
    // 1. Request permissions
    await requestFullScreenPermissions(context);
    
    // 2. Enhanced haptic sequence
    await testEnhancedVibrationOnly(context);
    
    // 3. Wait for haptic to complete
    await Future.delayed(const Duration(seconds: 3));
    
    // 4. Full screen intent with haptic
    await createFullScreenIntentNotification(context);
    
    print("🚨 ULTIMATE amber alert with enhanced haptic completed!");
  }

  // ===== AMBER ALERT TESTS =====
  
  // 🚨 ENHANCED TRUE AMBER ALERT TEST
  static Future<void> testAmberAlertNotification(BuildContext context) async {
    print("🚨 Starting TRUE AMBER ALERT test...");
    
    // 1. Check all permissions first
    await checkAllPermissions(context);
    
    // 2. Check if notifications are actually allowed
    final bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    print("🔐 Notification permission status: $isAllowed");
    
    if (!isAllowed) {
      print("❌ Notifications not allowed - requesting permission");
      final granted = await AwesomeNotifications().requestPermissionToSendNotifications();
      print("🔐 Permission request result: $granted");
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Notification permissions denied! Cannot test amber alerts.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    // 3. Check battery optimization
    await checkBatteryOptimization(context);
    
    // 4. Schedule with IMMEDIATE delivery (2 seconds)
    final now = DateTime.now();
    final scheduledTime = now.add(const Duration(seconds: 2));
    
    print("🚨 Scheduling TRUE AMBER ALERT for: $scheduledTime");
    print("🚨 ALERT SCREEN WILL AUTO-APPEAR (NO TAP REQUIRED)");
    
    try {
      // 5. Create with MAXIMUM URGENCY and FULL SCREEN TAKEOVER
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 995,
          channelKey: 'amber_alert_channel',
          
          // 🚨 AMBER ALERT STYLING
          title: '🚨 EMERGENCY ALERT 🚨',
          body: 'CRITICAL MOTIVATIONAL EMERGENCY\nScreen will hijack automatically!',
          summary: 'EMERGENCY ALERT SYSTEM',
          
          // 🚨 FULL SCREEN LAYOUT
          notificationLayout: NotificationLayout.BigText,
          
          // 🚨 MAXIMUM URGENCY FLAGS
          category: NotificationCategory.Alarm, // Critical for full screen
          wakeUpScreen: true,
          fullScreenIntent: true, // KEY: Forces full screen
          locked: false, // Allow dismissal for testing
          criticalAlert: true,
          autoDismissible: false,
          
          // 🚨 VISIBILITY FLAGS
          showWhen: true,
          displayOnForeground: true,
          displayOnBackground: true,
          
          // 🚨 VISUAL STYLING
          color: Colors.red,
          
          payload: {
            'taskDescription': 'CRITICAL: Test the auto-hijack amber alert system',
            'motivationalLine': 'This alert should automatically take over your screen without requiring any taps!',
            'audioFilePath': '/test/path/emergency_audio.mp3',
            'forceOverrideSilent': 'true',
            'isAmberAlert': 'true',
            'testMode': 'full_screen',
            'emergency': 'true', // 🚨 KEY: This triggers auto-display
            'strategy': 'A',     // 🔥 FIXED: Added missing strategy A!
          },
        ),
        
        // 🚨 IMMEDIATE SCHEDULING
        schedule: NotificationCalendar.fromDate(date: scheduledTime),
      );
      
      print("✅ TRUE Amber alert scheduled successfully");
      print("📱 INSTRUCTIONS: Turn off screen NOW and wait 2 seconds");
      print("🚨 Expected: AUTOMATIC SCREEN HIJACK (NO TAP REQUIRED)");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚨 AUTO-HIJACK AMBER ALERT scheduled for 2 seconds'),
              const Text('📱 Turn off screen NOW - will AUTO-APPEAR!'),
              const Text('🚨 NO TAPPING REQUIRED - AUTOMATIC TAKEOVER!'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => openDeviceSettings(context),
                child: const Text('Open Settings if Needed'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
      
    } catch (e) {
      print("❌ Error scheduling TRUE amber alert: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to schedule: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🆕 ALTERNATIVE TEST: Immediate notification (no scheduling)
  static Future<void> testImmediateAmberAlert(BuildContext context) async {
    print("🚨 Testing IMMEDIATE amber alert (no scheduling)...");
    
    try {
      // Create notification immediately without scheduling
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 994,
          channelKey: 'amber_alert_channel',
          title: '🚨 IMMEDIATE AMBER ALERT',
          body: 'This should hijack the screen instantly!',
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          displayOnForeground: true,
          displayOnBackground: true,
          payload: {
            'emergency': 'true',     // 🚨 IMPORTANT: Include this  
            'strategy': 'A',         // 🔥 FIXED: Added missing strategy A!
            'isAmberAlert': 'true',
            'taskDescription': 'Immediate amber alert test',
            'motivationalLine': 'This is an immediate amber alert test!',
          },
        ),
        // No schedule = immediate delivery
      );
      
      print("✅ Immediate amber alert created - should hijack NOW");
      
    } catch (e) {
      print("❌ Error creating immediate amber alert: $e");
    }
  }

  // 🆕 NEW: Test Immediate Auto-Hijack Alert
  static Future<void> testImmediateAutoHijackAlert(BuildContext context) async {
    print("🚨 Testing IMMEDIATE AUTO-HIJACK amber alert...");
    
    try {
      // Create notification that will auto-hijack immediately
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 989,
          channelKey: 'amber_alert_channel',
          title: '🚨 IMMEDIATE AUTO-HIJACK TEST',
          body: 'Screen should hijack NOW without any delay!',
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          displayOnForeground: true,
          displayOnBackground: true,
          payload: {
            'taskDescription': 'IMMEDIATE TEST: Auto-hijack verification',
            'motivationalLine': 'This alert hijacked your screen immediately!',
            'emergency': 'true',     // 🚨 KEY: Triggers auto-display
            'strategy': 'A',         // 🔥 FIXED: Added missing strategy A!
            'isAmberAlert': 'true',
            'testMode': 'immediate_hijack',
          },
        ),
        // No schedule = immediate delivery and auto-hijack
      );
      
      print("✅ Immediate auto-hijack alert created - should hijack NOW");
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚨 Immediate auto-hijack triggered - screen should takeover NOW!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      
    } catch (e) {
      print("❌ Error creating immediate auto-hijack alert: $e");
    }
  }

  // 🆕 ALTERNATIVE TEST: Native Android Alarm Alert
  static Future<void> testNativeAlarmAlert(BuildContext context) async {
    print("🚨 Testing NATIVE ANDROID ALARM alert...");
    
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 993,
          channelKey: 'amber_alert_channel',
          
          // 🚨 NATIVE ALARM STYLING
          title: '⚠️ SYSTEM ALARM ⚠️',
          body: 'EMERGENCY SYSTEM NOTIFICATION\nThis should take over your screen!',
          
          // 🚨 NATIVE ALARM CATEGORY
          category: NotificationCategory.Alarm,
          notificationLayout: NotificationLayout.BigText,
          
          // 🚨 MAXIMUM OVERRIDE FLAGS
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          locked: false,
          autoDismissible: false,
          
          // 🚨 ALARM SPECIFIC SETTINGS
          showWhen: true,
          
          // 🚨 VISUAL IMPACT
          color: Colors.red,
          actionType: ActionType.Default,
          
          payload: {
            'alertType': 'native_alarm',
            'priority': 'maximum',
            'override': 'all_settings',
            'emergency': 'true',     // 🚨 IMPORTANT: Include this
            'strategy': 'A',         // 🔥 FIXED: Added missing strategy A!
            'isAmberAlert': 'true',
          },
        ),
        // No schedule = immediate
      );
      
      print("✅ Native alarm alert created - should hijack immediately");
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Native alarm alert triggered immediately!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      
    } catch (e) {
      print("❌ Error creating native alarm alert: $e");
    }
  }

  // ===== REST OF THE METHODS (PERMISSIONS, DIAGNOSTICS, ETC.) =====
  
  static Future<void> checkAllPermissions(BuildContext context) async {
    print("🔐 Checking all permissions...");
    
    final notifications = await AwesomeNotifications().isNotificationAllowed();
    final overlay = await Permission.systemAlertWindow.status;
    final battery = await Permission.ignoreBatteryOptimizations.status;
    
    print("🔐 Notifications: $notifications");
    print("🔐 System overlay: $overlay");
    print("🔐 Battery optimization: $battery");
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔐 Permissions - Notifications: $notifications, Overlay: $overlay, Battery: $battery'),
        backgroundColor: Colors.indigo,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static Future<void> checkBatteryOptimization(BuildContext context) async {
    print("🔋 Checking battery optimization...");
    
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      print("🔋 Battery optimization status: $status");
      
      if (status.isDenied) {
        final granted = await Permission.ignoreBatteryOptimizations.request();
        print("🔋 Battery optimization permission result: $granted");
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔋 Battery optimization: $status'),
          backgroundColor: Colors.teal,
        ),
      );
      
    } catch (e) {
      print("❌ Error checking battery optimization: $e");
    }
  }

  static Future<void> checkScheduledNotifications(BuildContext context) async {
    print("📋 Checking scheduled notifications...");
    
    try {
      final notifications = await AwesomeNotifications().listScheduledNotifications();
      print("📋 Found ${notifications.length} scheduled notifications");
      
      for (final notification in notifications) {
        print("📋 ID: ${notification.content?.id}, Title: ${notification.content?.title}");
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📋 Found ${notifications.length} scheduled notifications'),
          backgroundColor: Colors.purple,
        ),
      );
      
    } catch (e) {
      print("❌ Error checking scheduled notifications: $e");
    }
  }

  static Future<void> openDeviceSettings(BuildContext context) async {
    print("⚙️ Opening device settings...");
    
    try {
      await openAppSettings();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚙️ Device settings opened'),
          backgroundColor: Colors.grey,
        ),
      );
      
    } catch (e) {
      print("❌ Error opening settings: $e");
    }
  }

  static void showPermissionInstructions(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔐 Enable these permissions for amber alerts:'),
            const Text('1. "Display over other apps"'),
            const Text('2. "Ignore battery optimization"'),
            const Text('3. "Critical alerts" in notification settings'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => openDeviceSettings(context),
              child: const Text('Open Settings'),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 10),
      ),
    );
  }

  // 🚨 COMBINED TEST: Only Strategy A 
  static Future<void> testAllAmberStrategies(BuildContext context) async {
  print("🚨 TESTING STRATEGY A ONLY...");
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('🚨 Launching STRATEGY A ONLY in 3 seconds...'),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );
  
  // Wait 3 seconds, then launch only Strategy A
  await Future.delayed(const Duration(seconds: 3));
  
  // Strategy 1: Enhanced notification (ONLY THIS ONE)
  await createFullScreenIntentNotification(context);
  
  print("🚨 Strategy A only deployed for testing!");
}
static Future<void> testDirectAmberAlert(BuildContext context) async {
  print("🚨 DIRECT AMBER ALERT TEST - SKIPPING NOTIFICATION FLOW");
  
  // Trigger vibration pattern first
  for (int i = 0; i < 5; i++) {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
  }
  
  // Navigate directly to AmberAlertScreen
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const AmberAlertScreen(
        title: '🚨 DIRECT TEST EMERGENCY ALERT 🚨',
        message: 'This is a direct test bypassing the notification flow!',
        taskDescription: 'Direct test - bypassing notifications',
      ),
      fullscreenDialog: true,
      transitionDuration: Duration.zero,
      settings: const RouteSettings(name: '/amber-alert'),
    ),
  );
}
  // 🚨 ULTIMATE TEST: All permissions + Strategy A
  static Future<void> testTrueFullScreenAmberAlert(BuildContext context) async {
    print("🚨 Testing ULTIMATE FULL SCREEN amber alert...");
    
    // 1. Request special permissions first
    await requestFullScreenPermissions(context);
    
    // 2. Test Strategy A: Enhanced Full Screen Intent
    await createFullScreenIntentNotification(context);
    
    // 3. Wait 3 seconds, then try Strategy B if needed
    await Future.delayed(const Duration(seconds: 3));
    await createSystemOverlayAlert(context);
  }

  // 🔐 Request full-screen specific permissions
  static Future<void> requestFullScreenPermissions(BuildContext context) async {
    print("🔐 Requesting full-screen permissions...");
    
    try {
      // Request system alert window (overlay) permission
      final overlayStatus = await Permission.systemAlertWindow.request();
      print("🔐 System overlay permission: $overlayStatus");
      
      // Request ignore battery optimizations
      final batteryStatus = await Permission.ignoreBatteryOptimizations.request();
      print("🔐 Battery optimization permission: $batteryStatus");
      
      // Show user instructions if permissions denied
      if (overlayStatus.isDenied) {
        showPermissionInstructions(context);
      }
      
    } catch (e) {
      print("⚠️ Error requesting full-screen permissions: $e");
    }
  }

  // 🚨 Strategy A: Enhanced Full Screen Intent Notification
  // ===== VERIFY YOUR createFullScreenIntentNotification METHOD HAS THIS PAYLOAD =====

// 🚨 Strategy A: Enhanced Full Screen Intent Notification - FIXED VERSION
static Future<void> createFullScreenIntentNotification(BuildContext context) async {
  print("🚨 Creating enhanced full-screen intent notification...");
  
  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 991,
        channelKey: 'amber_alert_channel',
        
        // 🚨 EMERGENCY STYLING
        title: '🚨 EMERGENCY MOTIVATIONAL ALERT 🚨',
        body: 'CRITICAL ALERT: Your immediate attention is required!\n\nScreen will hijack automatically.',
        summary: 'EMERGENCY ALERT SYSTEM',
        
        // 🚨 MAXIMUM VISIBILITY SETTINGS
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Alarm,
        
        // 🚨 CRITICAL FIX: REMOVE fullScreenIntent to prevent app opening
        wakeUpScreen: true,
        // fullScreenIntent: true,  // ❌ REMOVED - This opens the main app instead of hijack flow
        criticalAlert: true,
        
        // 🚨 PERSISTENCE SETTINGS
        locked: false, // Allow dismissal for testing
        autoDismissible: false,
        
        // 🚨 VISIBILITY FLAGS
        showWhen: true,
        displayOnForeground: true,
        displayOnBackground: true,
        
        // 🚨 VISUAL IMPACT
        color: Colors.red,
        backgroundColor: Colors.red,
        actionType: ActionType.Default,
        
        // 🚨 CRITICAL PAYLOAD - MUST MATCH EXACTLY FOR HIJACK DETECTION
        payload: {
          'alertType': 'full_screen_intent',
          'emergency': 'true',        // 🎯 CRITICAL - TRIGGERS AUTO-HIJACK
          'priority': 'maximum',
          'strategy': 'A',           // 🎯 CRITICAL - MUST BE 'A' FOR HIJACK
          'isAmberAlert': 'true',
          'taskDescription': 'Emergency amber alert test',
          'motivationalLine': 'Critical alert requiring immediate attention!',
          'audioFilePath': '',
          'bypassLockScreen': 'true',
        },
      ),
    );
    
    print("✅ Full-screen intent notification created (without fullScreenIntent)");
    print("🎯 This should trigger _onNotificationDisplayed() → hijack flow → AmberAlertScreen");
    
  } catch (e) {
    print("❌ Error creating full-screen intent notification: $e");
  }
}

  // 🚨 Strategy B: System Overlay Alert (Alternative approach)
  static Future<void> createSystemOverlayAlert(BuildContext context) async {
    print("🚨 Creating system overlay alert as fallback...");
    
    try {
      // Check if we have overlay permission
      final hasOverlayPermission = await Permission.systemAlertWindow.isGranted;
      
      if (hasOverlayPermission) {
        // Create a persistent, high-priority notification
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 990,
            channelKey: 'amber_alert_channel',
            
            // 🚨 SYSTEM-LEVEL EMERGENCY
            title: '🔴 SYSTEM EMERGENCY ALERT 🔴',
            body: 'CRITICAL SYSTEM NOTIFICATION\n\nThis is a high-priority emergency alert that requires immediate attention.',
            
            // 🚨 SYSTEM ALARM LAYOUT
            notificationLayout: NotificationLayout.BigText,
            category: NotificationCategory.Alarm,
            
            // 🚨 SYSTEM OVERRIDE SETTINGS
            wakeUpScreen: true,
            fullScreenIntent: true,
            criticalAlert: true,
            locked: true, // Make it harder to dismiss
            autoDismissible: false,
            
            // 🚨 EMERGENCY COLORS
            color: Colors.red,
            
            payload: {
              'alertType': 'system_overlay',
              'emergency': 'true',
              'strategy': 'B',
              'persistent': 'true',
              'isAmberAlert': 'true',
              'taskDescription': 'System overlay test',
              'motivationalLine': 'This is a system overlay amber alert test!',
            },
          ),
        );
        
        print("✅ System overlay alert created");
        
      } else {
        print("❌ System overlay permission not granted");
        showPermissionInstructions(context);
      }
      
    } catch (e) {
      print("❌ Error creating system overlay alert: $e");
    }
  }

  // 🔄 CONTINUOUS ALARM TEST
  static Future<void> testContinuousAlarm(BuildContext context) async {
    print("🚨 Testing CONTINUOUS ALARM...");
    
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 992,
          channelKey: 'amber_alert_channel',
          title: '🔴 CONTINUOUS EMERGENCY ALARM',
          body: 'PERSISTENT ALERT\nThis will continue until acknowledged!',
          category: NotificationCategory.Alarm,
          notificationLayout: NotificationLayout.BigText,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          locked: true,
          autoDismissible: false,
          color: Colors.red,
          payload: {
            'alertType': 'continuous_alarm',
            'persistent': 'true',
            'emergency': 'true',
            'strategy': 'A',         // 🔥 FIXED: Added missing strategy A!
            'isAmberAlert': 'true',
          },
        ),
      );
      
      print("✅ Continuous alarm created");
      
    } catch (e) {
      print("❌ Error creating continuous alarm: $e");
    }
  }
}