import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../state/fithabit_controller.dart';
import '../utils/bento_theme.dart';

class AnalyticsTab extends StatelessWidget {
  final FitHabitController controller;
  final void Function(String title, String message, Color color) onShowToast;

  const AnalyticsTab({
    super.key,
    required this.controller,
    required this.onShowToast,
  });

  static const List<int> _weeklyRates = [78, 86, 65, 92, 88, 95, 84];
  static const List<String> _weekDays = [
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'CN',
  ];

  @override
  Widget build(BuildContext context) {
    final pct = controller.completionRatePercent;
    final catMap = controller.categoryCounts;
    final totalHabits = controller.habits.isEmpty
        ? 1
        : controller.habits.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        // 1. Lưới ngang 3 cột đồng nhất (Streak, Tỷ lệ hoàn thành, Tổng lượt Check-in)
        Row(
          children: [
            Expanded(
              child: _buildUniformKpiCard(
                icon: Icons.local_fire_department_rounded,
                value: '${controller.maxStreak}',
                unit: 'ngày',
                label: 'Chuỗi Streak',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildUniformKpiCard(
                icon: Icons.donut_large_rounded,
                value: '$pct%',
                unit: '',
                label: 'Tỷ lệ hoàn thành',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildUniformKpiCard(
                icon: Icons.verified_outlined,
                value: '${controller.totalCheckIns}',
                unit: 'lần',
                label: 'Tổng Check-in',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2. Habit Heatmap Calendar 12 tuần chuẩn GitHub Contributions
        BentoCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.showGradingMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CN 04 • HABIT HEATMAP CALENDAR (12 TUẦN)',
                        style: BentoTextStyles.subCaption(
                          color: BentoColors.deepForest,
                        ),
                      ),
                      Text(
                        'GITHUB STYLE',
                        style: BentoTextStyles.subCaption(),
                      ),
                    ],
                  ),
                ),
              const Text(
                'Bản đồ nhiệt duy trì thói quen (12 tuần)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BentoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Mỗi cột biểu thị 1 tuần • Chạm vào ô ngày để cập nhật mức độ hoàn thành',
                style: TextStyle(
                  fontSize: 12,
                  color: BentoColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),

              // Month Header Row
              const Padding(
                padding: EdgeInsets.only(left: 26, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tháng 8',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: BentoColors.textMuted,
                      ),
                    ),
                    Text(
                      'Tháng 9',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: BentoColors.textMuted,
                      ),
                    ),
                    Text(
                      'Tháng 10',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: BentoColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // GitHub Contributions 7-Row x 12-Week Matrix
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2),
                        Text(
                          'T2',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: BentoColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 19),
                        Text(
                          'T4',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: BentoColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 19),
                        Text(
                          'T6',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: BentoColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 19),
                        Text(
                          'CN',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: BentoColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.heatmapLevels.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 12,
                            crossAxisSpacing: 4.5,
                            mainAxisSpacing: 4.5,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (context, index) {
                        final lvl = controller.heatmapLevels[index];
                        return InkWell(
                          onTap: () {
                            final next = controller.cycleHeatmapLevel(index);
                            onShowToast(
                              'Cập nhật Heatmap',
                              'Ngày #${index + 1}: Cường độ hoàn thành mức $next/4.',
                              BentoColors.mintEmerald,
                            );
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            decoration: BoxDecoration(
                              color: _emeraldLevelColor(lvl),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bottom Legend: Ít -> Nhiều
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '84 ngày gần nhất',
                    style: BentoTextStyles.subCaption(
                      color: BentoColors.textMuted,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Ít',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: BentoColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ...[0, 1, 2, 3, 4].map(
                        (lvl) => Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: _emeraldLevelColor(lvl),
                            borderRadius: BorderRadius.circular(3.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: BentoColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Nhiều',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: BentoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. Biểu đồ Cột (Bar Chart) bo tròn đầu cột hiển thị tỷ lệ hoàn thành 7 ngày qua
        BentoCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.showGradingMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'CN 04 • BIỂU ĐỒ CỘT TỶ LỆ HOÀN THÀNH 7 NGÀY QUA',
                    style: BentoTextStyles.subCaption(
                      color: BentoColors.deepForest,
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hiệu suất 7 ngày qua',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: BentoColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tỷ lệ hoàn thành mục tiêu theo từng ngày trong tuần',
                        style: TextStyle(
                          fontSize: 12,
                          color: BentoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: BentoColors.mintSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'TB 84%',
                      style: BentoTextStyles.subCaption(
                        color: BentoColors.deepForest,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 170,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (idx) {
                    final val = idx == 6 ? pct : _weeklyRates[idx];
                    final isToday = idx == 6;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '$val%',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isToday
                                    ? BentoColors.deepForest
                                    : BentoColors.textSecondary,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 116,
                              width: double.infinity,
                              alignment: Alignment.bottomCenter,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                  bottom: Radius.circular(4),
                                ),
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                                width: double.infinity,
                                height: (val / 100.0) * 116.0,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                    bottom: Radius.circular(4),
                                  ),
                                  color: isToday
                                      ? BentoColors.deepForest
                                      : BentoColors.mintEmerald,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _weekDays[idx],
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isToday
                                    ? BentoColors.deepForest
                                    : BentoColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 4. Phân bổ danh mục thói quen (Doughnut Chart)
        BentoCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Phân bổ nhóm thói quen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BentoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 124,
                    height: 124,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(124, 124),
                          painter: _CategoryDonutPainter(catMap),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${controller.habits.length}',
                              style: BentoTextStyles.statLarge(
                                fontSize: 22,
                                color: BentoColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'Mục tiêu',
                              style: TextStyle(
                                fontSize: 10,
                                color: BentoColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _buildLegendRow(
                          'Vận động',
                          catMap['Vận động'] ?? 0,
                          totalHabits,
                          BentoColors.deepForest,
                        ),
                        const SizedBox(height: 10),
                        _buildLegendRow(
                          'Sức khỏe',
                          catMap['Sức khỏe'] ?? 0,
                          totalHabits,
                          BentoColors.mintEmerald,
                        ),
                        const SizedBox(height: 10),
                        _buildLegendRow(
                          'Học tập',
                          catMap['Học tập'] ?? 0,
                          totalHabits,
                          BentoColors.skyBlue,
                        ),
                        const SizedBox(height: 10),
                        _buildLegendRow(
                          'Tinh thần',
                          catMap['Tinh thần'] ?? 0,
                          totalHabits,
                          BentoColors.warmCoral,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUniformKpiCard({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
  }) {
    return BentoCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      backgroundColor: BentoColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: BentoColors.mintSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: BentoColors.deepForest),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: BentoTextStyles.statLarge(
                    fontSize: 22,
                    color: BentoColors.textPrimary,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: BentoColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: BentoColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String label, int count, int total, Color color) {
    final pct = ((count / total) * 100).round();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: BentoColors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          '$count ($pct%)',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: BentoColors.textPrimary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  // 4 Emerald levels + 0 empty level (GitHub Contributions style)
  static Color _emeraldLevelColor(int level) {
    switch (level) {
      case 0:
        return const Color(0xFFEBEDF0);
      case 1:
        return const Color(0xFFA7F3D0);
      case 2:
        return const Color(0xFF34D399);
      case 3:
        return const Color(0xFF059669);
      default:
        return BentoColors.deepForest;
    }
  }
}

class _CategoryDonutPainter extends CustomPainter {
  final Map<String, int> counts;

  _CategoryDonutPainter(this.counts);

  @override
  void paint(Canvas canvas, Size size) {
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.butt;

    if (total == 0) {
      paint.color = BentoColors.border;
      canvas.drawArc(rect.deflate(12), 0, math.pi * 2, false, paint);
      return;
    }

    final colors = {
      'Vận động': BentoColors.deepForest,
      'Sức khỏe': BentoColors.mintEmerald,
      'Học tập': BentoColors.skyBlue,
      'Tinh thần': BentoColors.warmCoral,
    };

    double startAngle = -math.pi / 2;
    counts.forEach((key, val) {
      if (val <= 0) return;
      final sweep = (val / total) * math.pi * 2;
      paint.color = colors[key] ?? BentoColors.mintEmerald;
      canvas.drawArc(rect.deflate(12), startAngle, sweep - 0.04, false, paint);
      startAngle += sweep;
    });
  }

  @override
  bool shouldRepaint(covariant _CategoryDonutPainter oldDelegate) => true;
}
