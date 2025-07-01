import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:path_provider/path_provider.dart';

// ✅ Import our new organized files
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/motivator_home.dart';
import 'screens/amber_alert_screen.dart';
import 'services/motivator_api.dart';
import 'services/amber_alert_service.dart';
import 'services/notification_manager.dart';

// 🚨 Global navigator key for amber alerts
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 🚨 NEW: Background amber alert trigger
Future<void> _triggerBackgroundAmberAlert(Map<String, dynamic>? inputData) async {
  if (inputData == null) {
    print('❌ No input data for background amber alert');
    return;
  }
  
  print('🚨 Triggering background amber alert');
  print('📋 Task: ${inputData['taskDescription']}');
  
  try {
    // Create immediate notification to wake the app
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch % 2147483647,
        channelKey: 'amber_alert_channel',
        title: '🚨 BACKGROUND EMERGENCY ALERT 🚨',
        body: '${inputData['taskDescription']}\n\nTap to open full alert!',
        payload: {
          'triggerAmberAlert': 'true',
          'taskDescription': inputData['taskDescription'] ?? 'Background Alert',
          'motivationalLine': inputData['motivationalLine'] ?? 'Critical alert!',
          'audioFilePath': inputData['audioPath'] ?? '',
          'backgroundTriggered': 'true',
          'workManagerDelivery': 'true',
        },
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
        category: NotificationCategory.Alarm,
        color: Colors.red,
        displayOnForeground: true,
        displayOnBackground: true,
        locked: true,
      ),
    );
    
    print('✅ Background amber alert notification created');
    
    // Try to trigger system vibration if possible
    try {
      // This might not work in background, but worth trying
      HapticFeedback.heavyImpact();
    } catch (e) {
      print('⚠️ Could not trigger haptic feedback from background: $e');
    }
    
  } catch (e) {
    print('❌ Failed to trigger background amber alert: $e');
  }
}

// 🚨 NEW: Precision amber alert trigger (for immediate execution)
Future<void> _triggerPrecisionAmberAlert(Map<String, dynamic>? inputData) async {
  if (inputData == null) {
    print('❌ No input data for precision amber alert');
    return;
  }
  
  print('🎯 Triggering precision amber alert with AUTO-HIJACK');
  
  try {
    // Create immediate high-priority notification with hijack payload
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch % 2147483647,
        channelKey: 'amber_alert_channel',
        title: '🎯 PRECISION EMERGENCY ALERT 🎯',
        body: '${inputData['taskDescription']}\n\nDelivered with precision timing!',
        
        // 🚨 CRITICAL: Add the hijack flags
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
        displayOnForeground: true,
        displayOnBackground: true,
        color: Colors.red,
        
        payload: {
          'taskDescription': inputData['taskDescription'] ?? 'Precision Alert',
          'motivationalLine': inputData['motivationalLine'] ?? 'Precision alert delivered!',
          'audioFilePath': inputData['audioPath'] ?? '',
          
          // 🚨 CRITICAL: These trigger the auto-hijack
          'emergency': 'true',        // Must be 'true' as string
          'strategy': 'A',           // Must be 'A' for hijack
          'isAmberAlert': 'true',
          
          // Additional metadata
          'precisionDelivery': 'true',
          'backgroundTriggered': 'true',
          'workManagerDelivery': 'true',
        },
      ),
    );
    
    print('✅ Precision amber alert with auto-hijack created');
    
  } catch (e) {
    print('❌ Failed to trigger precision amber alert: $e');
  }
}

// ===== APP INITIALIZATION =====
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("🚀 Initializing MotivatorAI with enhanced amber alert support...");
  
  // ✅ FIRST: Initialize AwesomeNotifications with enhanced amber alert capabilities
  await AwesomeNotifications().initialize(
    null,
    [
      // 🚨 AMBER ALERT CHANNEL (HIGH PRIORITY)
      NotificationChannel(
        channelKey: 'amber_alert_channel',
        channelName: 'Emergency Motivational Alerts',
        channelDescription: 'Emergency-level motivational notifications that bypass silent mode',
        importance: NotificationImportance.Max,
        defaultColor: Colors.red,
        ledColor: Colors.red,
        playSound: true,
        enableVibration: true,
        criticalAlerts: true,
        enableLights: true,
        channelShowBadge: true,
        onlyAlertOnce: false,
        locked: true,
        // 🚨 ADD THESE CRITICAL FLAGS:
        defaultRingtoneType: DefaultRingtoneType.Alarm,
        groupAlertBehavior: GroupAlertBehavior.All,
        groupSort: GroupSort.Desc,
      ),
      
      // 🔔 REGULAR MOTIVATIONAL REMINDERS (Keep existing)
      NotificationChannel(
        channelKey: 'motivator_reminders',
        channelName: 'Motivational Reminders',
        channelDescription: 'Personalized motivational notifications with audio',
        importance: NotificationImportance.Max,
        defaultColor: Colors.tealAccent,
        ledColor: Colors.white,
        playSound: true,
        enableVibration: true,
      ),
      
      // 🔔 BASIC CHANNEL
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Standard notifications',
        importance: NotificationImportance.High,
        defaultColor: Colors.blue,
        playSound: true,
        enableVibration: true,
      ),
    ],
    debug: true,
  );
  print("✅ AwesomeNotifications initialized with enhanced amber alert support");
  
  // 🚨 FIX #1: SET UP NOTIFICATION MANAGER WITH NAVIGATOR KEY
  NotificationManager.instance.setNavigatorKey(navigatorKey);
  print("✅ NotificationManager navigator key set");
  
  // 🚨 FIX #2: SET UP NOTIFICATION LISTENERS  
  NotificationManager.instance.setupNotificationListeners();
  print("✅ NotificationManager listeners set up");
  
  // Initialize timezone data after AwesomeNotifications
  tz.initializeTimeZones();
  print("✅ Timezone data initialized");
  
  // 🚨 Request enhanced permissions for amber alerts
  await _requestEnhancedPermissions();
  
  // ✅ THEN run the app
  runApp(const MotivatorApp());
}

// ===== ENHANCED PERMISSION HANDLING FOR AMBER ALERTS =====
Future<void> _requestEnhancedPermissions() async {
  print("🔐 Requesting enhanced permissions for amber alerts...");
  
  try {
    // 1. Basic notification permissions
    await NotificationManager.instance.requestAwesomeNotificationPermissions();
    
    // 2. Enhanced Android permissions for amber alerts
    final List<Permission> permissionsToRequest = [
      Permission.notification,
      Permission.systemAlertWindow,
      Permission.ignoreBatteryOptimizations,
    ];
    
    Map<Permission, PermissionStatus> statuses = await permissionsToRequest.request();
    
    for (final entry in statuses.entries) {
      print("🔐 ${entry.key}: ${entry.value}");
    }
    
    print("✅ Enhanced permissions requested");
    
  } catch (e) {
    print("⚠️ Enhanced permission request failed: $e");
    print("   Continuing with basic permissions...");
  }
}

// ===== FLUTTER APP =====
class MotivatorApp extends StatelessWidget {
  const MotivatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotivatorAI',
      navigatorKey: navigatorKey, // 🚨 CRITICAL: Use global navigator key
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const MotivatorHome(),
        '/settings': (context) => const SettingsScreen(),
        '/amber-alert': (context) => const AmberAlertScreen(),
      },
      // 🚨 Global route observer for debugging
      navigatorObservers: [
        _AmberAlertRouteObserver(),
      ],
    );
  }
}

// 🚨 Route observer for amber alert debugging
class _AmberAlertRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/amber-alert') {
      print('🚨 ROUTE: Amber alert screen pushed');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route.settings.name == '/amber-alert') {
      print('🚨 ROUTE: Amber alert screen popped');
      // Reset amber alert flag when route is popped
      NotificationManager.instance.resetAmberAlertFlag();
    }
  }
}