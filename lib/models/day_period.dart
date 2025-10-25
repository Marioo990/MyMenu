import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DayPeriod {
  final String id;
  final Map<String, String> name;
  final Map<String, String>? description;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isActive;
  final int order;
  final String? icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DayPeriod({
    required this.id,
    required this.name,
    this.description,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
    this.order = 0,
    this.icon,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor from Firestore
  factory DayPeriod.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse time strings
    final startTimeStr = data['startTime'] as String;
    final endTimeStr = data['endTime'] as String;

    return DayPeriod(
      id: doc.id,
      name: Map<String, String>.from(data['name'] ?? {}),
      description: data['description'] != null
          ? Map<String, String>.from(data['description'])
          : null,
      startTime: _parseTimeString(startTimeStr),
      endTime: _parseTimeString(endTimeStr),
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      icon: data['icon'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'startTime': _formatTime(startTime),
      'endTime': _formatTime(endTime),
      'isActive': isActive,
      'order': order,
      'icon': icon,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Copy with method
  DayPeriod copyWith({
    String? id,
    Map<String, String>? name,
    Map<String, String>? description,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isActive,
    int? order,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DayPeriod(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  String getName(String locale) {
    return name[locale] ?? name['en'] ?? name.values.first;
  }

  String? getDescription(String locale) {
    if (description == null) return null;
    return description![locale] ?? description!['en'] ?? description!.values.first;
  }

  String getDisplayIcon() {
    if (icon != null && icon!.isNotEmpty) {
      return icon!;
    }

    // Default icons based on time
    if (_isTimeInRange(TimeOfDay(hour: 5, minute: 0), TimeOfDay(hour: 11, minute: 0))) {
      return '🌅'; // Morning/Breakfast
    } else if (_isTimeInRange(TimeOfDay(hour: 11, minute: 0), TimeOfDay(hour: 15, minute: 0))) {
      return '☀️'; // Lunch
    } else if (_isTimeInRange(TimeOfDay(hour: 15, minute: 0), TimeOfDay(hour: 18, minute: 0))) {
      return '🌤️'; // Afternoon
    } else if (_isTimeInRange(TimeOfDay(hour: 18, minute: 0), TimeOfDay(hour: 22, minute: 0))) {
      return '🌆'; // Dinner/Evening
    } else {
      return '🌙'; // Night
    }
  }

  bool isCurrentlyActive() {
    final now = TimeOfDay.now();
    return _isTimeInRange(now, now);
  }

  bool _isTimeInRange(TimeOfDay time, TimeOfDay _) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (startMinutes <= endMinutes) {
      // Normal range (e.g., 8:00 - 14:00)
      return timeMinutes >= startMinutes && timeMinutes < endMinutes;
    } else {
      // Range crosses midnight (e.g., 22:00 - 2:00)
      return timeMinutes >= startMinutes || timeMinutes < endMinutes;
    }
  }

  String getTimeRangeString() {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  static TimeOfDay _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Get the current active day period from a list
  static DayPeriod? getCurrentPeriod(List<DayPeriod> periods) {
    if (periods.isEmpty) return null;

    final activePeriods = periods
        .where((p) => p.isActive && p.isCurrentlyActive())
        .toList();

    if (activePeriods.isEmpty) return null;

    // Return the one with highest priority (lowest order number)
    activePeriods.sort((a, b) => a.order.compareTo(b.order));
    return activePeriods.first;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DayPeriod &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Common day periods
class CommonDayPeriods {
  static DayPeriod breakfast(Map<String, String> name, {Map<String, String>? description}) {
    return DayPeriod(
      id: 'breakfast',
      name: name,
      description: description,
      startTime: const TimeOfDay(hour: 7, minute: 0),
      endTime: const TimeOfDay(hour: 11, minute: 0),
      icon: '🍳',
      order: 1,
    );
  }

  static DayPeriod lunch(Map<String, String> name, {Map<String, String>? description}) {
    return DayPeriod(
      id: 'lunch',
      name: name,
      description: description,
      startTime: const TimeOfDay(hour: 11, minute: 0),
      endTime: const TimeOfDay(hour: 15, minute: 0),
      icon: '🍽️',
      order: 2,
    );
  }

  static DayPeriod dinner(Map<String, String> name, {Map<String, String>? description}) {
    return DayPeriod(
      id: 'dinner',
      name: name,
      description: description,
      startTime: const TimeOfDay(hour: 18, minute: 0),
      endTime: const TimeOfDay(hour: 22, minute: 0),
      icon: '🍷',
      order: 3,
    );
  }

  static DayPeriod allDay(Map<String, String> name) {
    return DayPeriod(
      id: 'all-day',
      name: name,
      startTime: const TimeOfDay(hour: 0, minute: 0),
      endTime: const TimeOfDay(hour: 23, minute: 59),
      icon: '⏰',
      order: 0,
    );
  }
}