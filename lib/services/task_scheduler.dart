import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'motivator_api.dart';
import 'notification_manager.dart';

class TaskScheduler {
  final MotivatorApi _api = MotivatorApi();
  
  // 🎯 Store active timers to prevent memory leaks
  static final Map<String, Timer> _activeTimers = {};
  
  // ========== PRECISION AMBER ALERT BYPASS SYSTEM ==========
  
  // 🎯 Main method for precision amber alert bypass
  Future<void> scheduleAmberAlertWithPrecisionBypass(Map<String, dynamic> taskData) async {
    print('🎯 PRECISION BYPASS: Starting amber alert scheduling');
    
    try {
      final scheduledTime = taskData['dateTime'] as DateTime;
      final timeUntilAlert = scheduledTime.difference(DateTime.now());
      final taskId = (taskData['description']?.toString() ?? 'task').hashCode.abs().toString();
      
      print('⏰ Time until alert: ${timeUntilAlert.inSeconds} seconds');
      
      // For alerts within 10 minutes, use precision Dart Timer
      if (timeUntilAlert.inMinutes <= 10) {
        await _scheduleDartTimerBypass(taskData, timeUntilAlert, taskId);
      } else {
        // For longer delays, fall back to traditional scheduling
        print('⏰ Long delay detected, using traditional scheduling');
        await _scheduleTraditionalAmberAlert(taskData);
      }
      
      print('✅ Precision bypass system activated for: ${taskData['description']?.toString() ?? 'Unknown Task'}');
      
    } catch (e) {
      print('❌ Error in precision bypass: $e');
      // Fallback to traditional notification
      await _scheduleTraditionalAmberAlert(taskData);
    }
  }
  
  // 🚀 Dart Timer Bypass (0-10 minutes)
  Future<void> _scheduleDartTimerBypass(
    Map<String, dynamic> taskData, 
    Duration timeUntilAlert, 
    String taskId
  ) async {
    print('🚀 Using DART TIMER precision bypass: ${timeUntilAlert.inSeconds}s');
    
    // Cancel any existing timer for this task
    _activeTimers[taskId]?.cancel();
    
    // Create new precision timer
    _activeTimers[taskId] = Timer(timeUntilAlert, () async {
      print('🎯 PRECISION TIMER FIRED - DEPLOYING AMBER ALERT NOW!');
      
      try {
        // Forceful emergency override
        await NotificationManager.instance.overrideSilentModeForEmergency();
        
        // Deploy amber alert
        await NotificationManager.instance.createForcefulAmberAlert(
          id: DateTime.now().millisecondsSinceEpoch % 2147483647,
          title: '🚨 PRECISION EMERGENCY ALERT 🚨',
          body: 'CRITICAL TASK: ${taskData['description']?.toString() ?? 'Unknown Task'}\n\nThis is your precision-timed amber alert!',
          payload: {
            'taskDescription': taskData['description'].toString(),
            'motivationalLine': (taskData['motivationalLine'] ?? 'Your precision alert is here!').toString(),
            'audioFilePath': (taskData['audioPath'] ?? '').toString(),
            'emergency': 'true',
            'strategy': 'A',
            'isAmberAlert': 'true',
            'precisionDelivery': 'true',
            'bypassLockScreen': 'true',
          },
        );
        
        print('✅ Precision amber alert deployed successfully!');
        
        // Clean up timer
        _activeTimers.remove(taskId);
        
      } catch (e) {
        print('❌ Error deploying precision amber alert: $e');
        // Fallback to regular notification
        await _deployFallbackNotification(taskData);
      }
    });
    
    print('⏰ Precision timer set for ${timeUntilAlert.inSeconds} seconds');
  }
  
  // 📅 Traditional Amber Alert (for longer delays)
  Future<void> _scheduleTraditionalAmberAlert(Map<String, dynamic> taskData) async {
    print('📅 Scheduling traditional amber alert');
    
    try {
      final scheduledTime = taskData['dateTime'] as DateTime;
      final motivationalLine = taskData['motivationalLine'] ?? 'Your scheduled task awaits!';
      final audioPath = taskData['audioPath'] ?? '';
      
      await NotificationManager.instance.createNotification(
        id: DateTime.now().millisecondsSinceEpoch % 2147483647,
        channelKey: 'amber_alert_channel',
        title: '🚨 SCHEDULED EMERGENCY ALERT 🚨',
        body: 'CRITICAL TASK: ${taskData['description']?.toString() ?? 'Unknown Task'}\n\n$motivationalLine',
        payload: {
          'taskDescription': taskData['description'].toString(),
          'motivationalLine': motivationalLine,
          'audioFilePath': audioPath,
          'emergency': 'true',
          'strategy': 'A',
          'isAmberAlert': 'true',
          'traditionalScheduling': 'true',
          'bypassLockScreen': 'true',
        },
        schedule: NotificationCalendar.fromDate(date: scheduledTime),
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
        category: NotificationCategory.Alarm,
        color: Colors.red,
      );
      
      print('✅ Traditional amber alert scheduled');
      
    } catch (e) {
      print('❌ Error scheduling traditional amber alert: $e');
    }
  }
  
  // 🔄 Fallback Notification
  Future<void> _deployFallbackNotification(Map<String, dynamic> taskData) async {
    print('🔄 Deploying fallback notification');
    
    try {
      await NotificationManager.instance.createNotification(
        id: DateTime.now().millisecondsSinceEpoch % 2147483647,
        channelKey: 'motivator_reminders',
        title: '⚠️ FALLBACK ALERT',
        body: 'Task: ${taskData['description']?.toString() ?? 'Unknown Task'}\n\nFallback notification deployed.',
        payload: {
          'taskDescription': taskData['description'].toString(),
          'motivationalLine': (taskData['motivationalLine'] ?? 'Fallback alert').toString(),
          'audioFilePath': (taskData['audioPath'] ?? '').toString(),
          'fallbackMode': 'true',
        },
        wakeUpScreen: true,
        color: Colors.orange,
      );
      
    } catch (e) {
      print('❌ Error deploying fallback notification: $e');
    }
  }

  // ========== ORIGINAL SCHEDULING METHODS ==========
  
  // Main task scheduling method - FIXED to accept Map parameter like task_dialog.dart expects
  Future<void> scheduleTask(Map<String, dynamic> taskData) async {
    final isRecurring = taskData['isRecurring'] ?? false;
    final isAmberAlert = taskData['isAmberAlert'] == true;
    
    print('📅 Scheduling ${isAmberAlert ? 'AMBER ALERT' : 'regular'} task: ${taskData['description']?.toString() ?? 'Unknown Task'}');
    print('🔄 Recurring: $isRecurring');
    
    try {
      // Generate motivational line and audio
      final motivationalLine = await _generateMotivationalLine(taskData);
      final audioFilePath = await _generateAndSaveAudio(taskData, motivationalLine);
      
      // 🎯 NEW: Use precision bypass for amber alerts
      if (isAmberAlert && !isRecurring) {
        print('🎯 Using precision bypass for amber alert');
        await scheduleAmberAlertWithPrecisionBypass(taskData);
        return;
      }
      
      // Use traditional scheduling for regular notifications and recurring amber alerts
      if (isRecurring) {
        await _scheduleRecurringNotifications(taskData, motivationalLine, audioFilePath);
      } else {
        await _scheduleSingleNotification(taskData, motivationalLine, audioFilePath);
      }
      
      print('✅ Task scheduled successfully');
      
    } catch (e) {
      print('❌ Error scheduling task: $e');
      rethrow;
    }
  }
  
  // Generate motivational line
  Future<String> _generateMotivationalLine(Map<String, dynamic> taskData) async {
    try {
      return await _api.generateLine(
        taskData['description']?.toString() ?? 'Complete your task!',
        toneStyle: taskData['toneStyle']?.toString() ?? 'Balanced',
      );
    } catch (e) {
      print('⚠️ Error generating motivational line: $e');
      return 'You can do this! Time to tackle ${taskData['description']?.toString() ?? 'your task'}!';
    }
  }
  
  // Generate and save audio
  Future<String> _generateAndSaveAudio(Map<String, dynamic> taskData, String motivationalLine) async {
    try {
      if (taskData['backendVoiceStyle'] != null || taskData['voiceStyle'] != null) {
        print('🎵 Generating voice audio...');
        
        final voiceStyle = taskData['backendVoiceStyle'] ?? taskData['voiceStyle'];
        final audioBytes = await _api.generateVoice(
          motivationalLine,
          voiceStyle: voiceStyle,
        );
        
        return await _saveAudioToDevice(audioBytes, taskData['description']?.toString() ?? 'unknown_task');
      }
      
      return '';
    } catch (e) {
      print('⚠️ Error generating audio: $e');
      return '';
    }
  }
  
  // Single notification scheduling
  Future<void> _scheduleSingleNotification(
    Map<String, dynamic> taskData, 
    String motivationalLine, 
    String audioFilePath
  ) async {
    final scheduledTime = taskData['dateTime'] as DateTime;
    final isAmberAlert = taskData['isAmberAlert'] == true;
    final notificationId = (taskData['description']?.toString() ?? 'task').hashCode.abs() % 2147483647;
    
    print('🔔 Scheduling ${isAmberAlert ? 'AMBER ALERT' : 'regular'} notification for: $scheduledTime');
    
    final channelKey = isAmberAlert ? 'amber_alert_channel' : 'motivator_reminders';
    final schedule = NotificationCalendar.fromDate(date: scheduledTime);
    
    try {
      await NotificationManager.instance.createNotification(
        id: notificationId,
        channelKey: channelKey,
        title: isAmberAlert ? '🚨 EMERGENCY MOTIVATIONAL ALERT 🚨' : '🎯 Time for Action!',
        body: taskData['description']?.toString() ?? 'Motivational Reminder',
        payload: {
          'taskDescription': (taskData['description'] ?? 'Unknown Task').toString(),
          'motivationalLine': motivationalLine,
          'audioFilePath': audioFilePath,
          'voiceStyle': (taskData['backendVoiceStyle'] ?? taskData['voiceStyle'] ?? 'Default').toString(),
          'toneStyle': (taskData['toneStyle'] ?? 'Balanced').toString(),
          'isRecurring': 'false',
          'isAmberAlert': isAmberAlert.toString(),
          'forceOverrideSilent': (taskData['forceOverrideSilent'] ?? false).toString(),
          ...(isAmberAlert ? {
            'emergency': 'true',
            'strategy': 'A',
            'bypassLockScreen': 'true',
          } : {}),
        },
        schedule: schedule,
        layout: NotificationLayout.Default,
        wakeUpScreen: isAmberAlert,
        fullScreenIntent: isAmberAlert,
        criticalAlert: isAmberAlert,
        category: isAmberAlert ? NotificationCategory.Alarm : NotificationCategory.Reminder,
        color: isAmberAlert ? Colors.red : Colors.teal,
      );
      
      print('✅ ${isAmberAlert ? 'AMBER ALERT' : 'Regular'} notification scheduled successfully');
      
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      rethrow;
    }
  }
  
  Future<void> _scheduleRecurringNotifications(
    Map<String, dynamic> taskData,
    String motivationalLine,
    String audioFilePath,
  ) async {
    final isAmberAlert = taskData['isAmberAlert'] == true;
    final recurringType = taskData['recurringType'] ?? 'daily';
    final selectedWeekdays = taskData['selectedWeekdays'] ?? <int>[];
    final endDate = taskData['recurringEndDate'];
    final neverEnds = taskData['neverEnds'] ?? false;
    final startTime = taskData['dateTime'] as DateTime;
    
    List<DateTime> scheduleDates = [];
    
    switch (recurringType) {
      case 'daily':
        scheduleDates = generateDailyDates(startTime, endDate, neverEnds);
        break;
      case 'weekly':
        scheduleDates = generateWeeklyDates(startTime, selectedWeekdays, endDate, neverEnds);
        break;
      case 'monthly':
        scheduleDates = generateMonthlyDates(startTime, endDate, neverEnds);
        break;
      default:
        scheduleDates = [startTime];
    }
    
    print('📅 Scheduling ${scheduleDates.length} recurring notifications');
    
    for (final date in scheduleDates) {
      final payload = <String, String>{
        'taskDescription': taskData['description'].toString(),
        'motivationalLine': motivationalLine,
        'audioFilePath': audioFilePath,
        'forceOverrideSilent': isAmberAlert.toString(),
        'recurringType': recurringType,
      };
      
      if (isAmberAlert) {
        payload.addAll({
          'emergency': 'true',
          'strategy': 'A',
          'isAmberAlert': 'true',
          'bypassLockScreen': 'true',
        });
      }
      
      await NotificationManager.instance.createNotification(
        id: date.millisecondsSinceEpoch % 2147483647,
        channelKey: isAmberAlert ? 'amber_alert_channel' : 'motivator_reminders',
        title: isAmberAlert ? '🚨 EMERGENCY ALERT 🚨' : '🎯 Motivational Reminder',
        body: isAmberAlert 
          ? 'CRITICAL TASK: ${taskData['description']?.toString() ?? 'Unknown Task'}\n\n$motivationalLine'
          : '${taskData['description']?.toString() ?? 'Unknown Task'}\n\n$motivationalLine',
        payload: payload,
        schedule: NotificationCalendar.fromDate(date: date),
        wakeUpScreen: isAmberAlert,
        fullScreenIntent: isAmberAlert,
        criticalAlert: isAmberAlert,
        category: isAmberAlert ? NotificationCategory.Alarm : NotificationCategory.Reminder,
        color: isAmberAlert ? Colors.red : Colors.teal,
      );
    }
    
    print('✅ Scheduled ${scheduleDates.length} ${isAmberAlert ? 'amber alert' : 'regular'} recurring notifications');
  }
  
  // ===== DATE GENERATION METHODS =====
  
  List<DateTime> generateDailyDates(DateTime startTime, DateTime? endDate, bool neverEnds) {
    List<DateTime> dates = [];
    DateTime current = startTime;
    final maxDate = neverEnds ? DateTime.now().add(const Duration(days: 365)) : endDate!;
    
    while (current.isBefore(maxDate) && dates.length < 365) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }
  
  List<DateTime> generateWeeklyDates(DateTime startTime, List<int> selectedWeekdays, DateTime? endDate, bool neverEnds) {
    List<DateTime> dates = [];
    DateTime current = startTime;
    final maxDate = neverEnds ? DateTime.now().add(const Duration(days: 365)) : endDate!;
    
    while (current.isBefore(maxDate) && dates.length < 200) {
      if (selectedWeekdays.contains(current.weekday)) {
        dates.add(current);
      }
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }
  
  List<DateTime> generateMonthlyDates(DateTime startTime, DateTime? endDate, bool neverEnds) {
    List<DateTime> dates = [];
    DateTime current = startTime;
    final maxDate = neverEnds ? DateTime.now().add(const Duration(days: 365)) : endDate!;
    
    while (current.isBefore(maxDate) && dates.length < 24) {
      dates.add(current);
      current = DateTime(current.year, current.month + 1, current.day, current.hour, current.minute);
    }
    
    return dates;
  }
  
  // ===== HELPER METHODS =====
  
  String getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
  
  Future<String> _saveAudioToDevice(Uint8List audioBytes, String taskDescription) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/audio');
      
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeTaskName = taskDescription.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
      final fileName = '${safeTaskName}_$timestamp.mp3';
      final filePath = '${audioDir.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(audioBytes);
      
      print('💾 Audio file saved: $filePath (${audioBytes.length} bytes)');
      return filePath;
      
    } catch (e) {
      print('❌ Error saving audio file: $e');
      rethrow;
    }
  }
  
  // ===== UTILITY METHODS =====
  
  Future<void> cancelTaskNotifications(String taskDescription) async {
    try {
      final scheduledNotifications = await NotificationManager.instance.getScheduledNotifications();
      
      for (final notification in scheduledNotifications) {
        final payload = notification.content?.payload;
        if (payload != null && payload['taskDescription'] == taskDescription) {
          await NotificationManager.instance.cancelNotification(notification.content!.id!);
          print('🗑️ Cancelled notification for task: $taskDescription');
        }
      }
    } catch (e) {
      print('❌ Error cancelling task notifications: $e');
    }
  }
  
  Future<int> getScheduledNotificationCount() async {
    try {
      final notifications = await NotificationManager.instance.getScheduledNotifications();
      return notifications.length;
    } catch (e) {
      print('❌ Error getting notification count: $e');
      return 0;
    }
  }
  
  Future<List<Map<String, dynamic>>> getScheduledNotificationsInfo() async {
    try {
      final notifications = await NotificationManager.instance.getScheduledNotifications();
      
      return notifications.map((notification) {
        return {
          'id': notification.content?.id,
          'title': notification.content?.title,
          'body': notification.content?.body,
          'scheduledDate': notification.schedule?.toString(),
          'isAmberAlert': notification.content?.channelKey == 'amber_alert_channel',
          'payload': notification.content?.payload,
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting notifications info: $e');
      return [];
    }
  }
  
  // ===== TIMER CLEANUP =====
  
  static void cancelTimer(String taskId) {
    _activeTimers[taskId]?.cancel();
    _activeTimers.remove(taskId);
    print('⏰ Timer cancelled for task: $taskId');
  }
  
  static void cancelAllTimers() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    print('⏰ All precision timers cancelled');
  }
  
  static Map<String, Timer> get activeTimers => Map.unmodifiable(_activeTimers);
}