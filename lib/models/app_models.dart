import 'dart:typed_data';
import 'package:flutter/material.dart';

class TeamMember {
  final int stt;
  final String mssv;
  final String fullName;
  final String className;

  const TeamMember({
    required this.stt,
    required this.mssv,
    required this.fullName,
    required this.className,
  });

  String get email => '$mssv@student.edu.vn';
}

class HabitItem {
  final String id;
  String title;
  String category;
  String cycle;
  String time;
  int streak;
  bool completedToday;
  String note;

  HabitItem({
    required this.id,
    required this.title,
    required this.category,
    required this.cycle,
    required this.time,
    required this.streak,
    required this.completedToday,
    required this.note,
  });
}

class HealthLog {
  final String id;
  final String date;
  final double weight;
  final double height;
  final double bmi;
  final String status;

  const HealthLog({
    required this.id,
    required this.date,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.status,
  });
}

class FoodSample {
  final String key;
  final String name;
  final String serving;
  final int kcal;
  final String protein;
  final String carbs;
  final String fat;
  final String confidence;
  final String tip;
  final String emoji;
  final List<Color> gradientColors;
  final String? assetImage;
  final Uint8List? customImageBytes;

  const FoodSample({
    required this.key,
    required this.name,
    required this.serving,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    required this.tip,
    required this.emoji,
    required this.gradientColors,
    this.assetImage,
    this.customImageBytes,
  });
}

class MealLog {
  final String id;
  final String time;
  final String name;
  final int kcal;
  final String macros;

  const MealLog({
    required this.id,
    required this.time,
    required this.name,
    required this.kcal,
    required this.macros,
  });
}

class WorkoutPlanItem {
  final String day;
  final String title;
  final String duration;
  final int kcal;
  final String level;

  const WorkoutPlanItem({
    required this.day,
    required this.title,
    required this.duration,
    required this.kcal,
    required this.level,
  });
}

class NotificationSchedule {
  final String id;
  final String time;
  final String title;
  bool enabled;

  NotificationSchedule({
    required this.id,
    required this.time,
    required this.title,
    required this.enabled,
  });
}

class SyncQueueItem {
  final String time;
  final String action;

  const SyncQueueItem({
    required this.time,
    required this.action,
  });
}

class BmiEvaluation {
  final double bmi;
  final String status;
  final String advice;
  final Color color;
  final double markerFraction; // 0.0 -> 1.0

  const BmiEvaluation({
    required this.bmi,
    required this.status,
    required this.advice,
    required this.color,
    required this.markerFraction,
  });
}

