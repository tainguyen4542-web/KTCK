import 'package:flutter/material.dart';
import '../state/fithabit_controller.dart';
import 'auth_team_tab.dart';

class NotificationsSyncTab extends StatelessWidget {
  final FitHabitController controller;
  final void Function(String title, String message, Color color) onShowToast;

  const NotificationsSyncTab({
    super.key,
    required this.controller,
    required this.onShowToast,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTeamTab(controller: controller, onShowToast: onShowToast);
  }
}
