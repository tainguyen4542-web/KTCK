import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../state/fithabit_controller.dart';
import '../utils/bento_theme.dart';

class HealthTab extends StatefulWidget {
  final FitHabitController controller;
  final void Function(String title, String message, Color color) onShowToast;

  const HealthTab({
    super.key,
    required this.controller,
    required this.onShowToast,
  });

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> {
  late double _sliderWeight;
  late double _sliderHeight;

  @override
  void initState() {
    super.initState();
    _sliderWeight = widget.controller.currentWeightKg.clamp(35.0, 140.0);
    _sliderHeight = widget.controller.currentHeightCm.clamp(140.0, 210.0);
  }

  void _handleSaveBmi() {
    widget.controller.updateAndSaveBmi(
      weight: _sliderWeight,
      height: _sliderHeight,
    );
    final eval = widget.controller.bmiEvaluation;
    widget.onShowToast(
      'Đã lưu chỉ số BMI',
      'BMI = ${eval.bmi.toStringAsFixed(2)} (${eval.status}).',
      BentoColors.mintEmerald,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final eval = ctrl.evaluateBmi(_sliderWeight, _sliderHeight);
    final waterPct = (ctrl.waterIntakeMl / ctrl.waterGoalMl).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        // 1. Khu vực Nước uống: Biểu đồ Cốc Sóng Nước trực quan + Nút cộng nhanh 1 chạm
        BentoCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ctrl.showGradingMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CN 03 • THEO DÕI LƯỢNG NƯỚC UỐNG HẰNG NGÀY',
                        style: BentoTextStyles.subCaption(
                          color: BentoColors.skyBlue,
                        ),
                      ),
                      Text(
                        'HYDRATION WAVE',
                        style: BentoTextStyles.subCaption(),
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      BentoIconBadge(
                        icon: Icons.water_drop_rounded,
                        color: BentoColors.skyBlue,
                        backgroundColor: BentoColors.skySoft,
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cân bằng nước hằng ngày',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: BentoColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Chạm nhanh để bù nước cho cơ thể',
                            style: TextStyle(
                              fontSize: 12,
                              color: BentoColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      ctrl.resetWater();
                      widget.onShowToast(
                        'Đã đặt lại lượng nước',
                        'Lượng nước hôm nay đã đưa về 0 ml.',
                        BentoColors.textSecondary,
                      );
                    },
                    child: const Text(
                      'Đặt lại',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: BentoColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Visual Water Wave Vessel + Metrics
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BentoColors.skySoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: BentoColors.skyBlue.withValues(alpha: 0.22),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Visual Water Cup with Wave Level
                        SizedBox(
                          width: 82,
                          height: 102,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                              bottom: Radius.circular(22),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(82, 102),
                                  painter: _WaterWaveCupPainter(
                                    fillFraction: waterPct,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(waterPct * 100).round()}%',
                                      style: BentoTextStyles.statMedium(
                                        fontSize: 18,
                                        color: waterPct > 0.48
                                            ? Colors.white
                                            : BentoColors.skyBlue,
                                      ),
                                    ),
                                    Text(
                                      '${ctrl.activeWaterCups}/8 cốc',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: waterPct > 0.48
                                            ? Colors.white.withValues(
                                                alpha: 0.9,
                                              )
                                            : BentoColors.textSecondary,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right Water Stats & Wave Bar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ĐÃ UỐNG HÔM NAY',
                                style: BentoTextStyles.subCaption(
                                  color: BentoColors.skyBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${ctrl.waterIntakeMl}',
                                      style: BentoTextStyles.statLarge(
                                        fontSize: 28,
                                        color: BentoColors.textPrimary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' / ${ctrl.waterGoalMl} ml',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: BentoColors.textSecondary,
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: waterPct,
                                  minHeight: 10,
                                  backgroundColor: Colors.white,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        BentoColors.skyBlue,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ctrl.waterIntakeMl >= ctrl.waterGoalMl
                                    ? 'Tuyệt vời! Bạn đã hoàn thành mục tiêu nước hôm nay.'
                                    : 'Còn thiếu ${ctrl.waterGoalMl - ctrl.waterIntakeMl} ml để đạt chuẩn 2 lít/ngày.',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: BentoColors.textSecondary,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 8 Mini Cup Selector
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 8,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                            crossAxisSpacing: 6,
                            childAspectRatio: 0.9,
                          ),
                      itemBuilder: (context, index) {
                        final active = index < ctrl.activeWaterCups;
                        return InkWell(
                          onTap: () => ctrl.setWaterByCupIndex(index),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: active
                                  ? BentoColors.skyBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: active
                                    ? BentoColors.skyBlue
                                    : BentoColors.border,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_drink_rounded,
                                  size: 14,
                                  color: active
                                      ? Colors.white
                                      : BentoColors.textMuted,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: active
                                        ? Colors.white
                                        : BentoColors.textSecondary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 1-Tap Quick Add Buttons (+200ml, +350ml, +500ml)
              Row(
                children: [
                  _buildQuickWaterBtn(ctrl, 200, 'Cốc nhỏ'),
                  const SizedBox(width: 8),
                  _buildQuickWaterBtn(ctrl, 350, 'Ly vừa'),
                  const SizedBox(width: 8),
                  _buildQuickWaterBtn(ctrl, 500, 'Bình thể thao'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Khu vực BMI: Thẻ Dark Mode (#111827) với Thước đo Gauge & Con trỏ Tam giác + Sliders
        BentoCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ctrl.showGradingMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CN 03 • CHỈ SỐ KHỐI CƠ THỂ (BMI GAUGE)',
                        style: BentoTextStyles.subCaption(
                          color: BentoColors.deepForest,
                        ),
                      ),
                      Text(
                        'WHO STANDARD',
                        style: BentoTextStyles.subCaption(),
                      ),
                    ],
                  ),
                ),

              // Dark Mode (#111827) BMI Gauge Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF111827).withValues(alpha: 0.16),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CHỈ SỐ BMI HIỆN TẠI',
                              style: BentoTextStyles.subCaption(
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  eval.bmi.toStringAsFixed(1),
                                  style: BentoTextStyles.statLarge(
                                    fontSize: 34,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'kg/m²',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: eval.color.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: eval.color.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: eval.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                eval.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: eval.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Refined Gauge Spectrum with Triangle Pointer
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final pointerX =
                            (constraints.maxWidth * eval.markerFraction).clamp(
                              10.0,
                              constraints.maxWidth - 10.0,
                            );
                        return Column(
                          children: [
                            SizedBox(
                              height: 24,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      height: 9,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF38BDF8),
                                            Color(0xFF10B981),
                                            Color(0xFFF59E0B),
                                            Color(0xFFEF4444),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOutCubic,
                                    left: pointerX - 7,
                                    top: 0,
                                    child: CustomPaint(
                                      size: const Size(14, 11),
                                      painter: _TrianglePointerPainter(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '<18.5 Thiếu',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9CA3AF),
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                Text(
                                  '18.5–22.9 Chuẩn',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9CA3AF),
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                Text(
                                  '23–24.9 Thừa',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9CA3AF),
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                Text(
                                  '≥25 Béo phì',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9CA3AF),
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      eval.advice,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD1D5DB),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Smooth Sliders for Weight & Height
              _buildSliderControl(
                label: 'Cân nặng hiện tại',
                valueText: '${_sliderWeight.toStringAsFixed(1)} kg',
                value: _sliderWeight,
                min: 35.0,
                max: 140.0,
                divisions: 210,
                activeColor: BentoColors.deepForest,
                onChanged: (val) => setState(() => _sliderWeight = val),
              ),
              const SizedBox(height: 12),
              _buildSliderControl(
                label: 'Chiều cao cơ thể',
                valueText: '${_sliderHeight.toStringAsFixed(0)} cm',
                value: _sliderHeight,
                min: 140.0,
                max: 210.0,
                divisions: 70,
                activeColor: BentoColors.mintEmerald,
                onChanged: (val) => setState(() => _sliderHeight = val),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _handleSaveBmi,
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: const Text('Lưu chỉ số vào Lịch sử BMI'),
                  style: FilledButton.styleFrom(
                    backgroundColor: BentoColors.deepForest,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Saved BMI Logs
              const Text(
                'Lịch sử đo gần đây',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: BentoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...ctrl.healthLogs.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: BentoColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BentoColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: BentoColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.date} • ${item.weight}kg / ${item.height.toStringAsFixed(0)}cm',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: BentoColors.textPrimary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            Text(
                              'BMI: ${item.bmi} (${item.status})',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: BentoColors.mintEmerald,
                                fontWeight: FontWeight.w600,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ctrl.deleteHealthLog(item.id);
                          widget.onShowToast(
                            'Đã xóa bản ghi',
                            'Đã xóa lịch sử đo ngày ${item.date}.',
                            BentoColors.textSecondary,
                          );
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: BentoColors.danger,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickWaterBtn(
    FitHabitController ctrl,
    int ml,
    String subtitle,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          ctrl.addWater(ml);
          widget.onShowToast(
            'Đã cộng +$ml ml nước',
            'Tổng lượng nước hôm nay: ${ctrl.waterIntakeMl}/${ctrl.waterGoalMl} ml.',
            BentoColors.skyBlue,
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
          decoration: BoxDecoration(
            color: BentoColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: BentoColors.skyBlue.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 15,
                    color: BentoColors.skyBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+$ml ml',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: BentoColors.skyBlue,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: BentoColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderControl({
    required String label,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      decoration: BoxDecoration(
        color: BentoColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BentoColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: BentoColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: BentoColors.border),
                ),
                child: Text(
                  valueText,
                  style: BentoTextStyles.statMedium(
                    fontSize: 14,
                    color: BentoColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeColor,
              inactiveTrackColor: BentoColors.border,
              thumbColor: activeColor,
              overlayColor: activeColor.withValues(alpha: 0.12),
              trackHeight: 5,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterWaveCupPainter extends CustomPainter {
  final double fillFraction;

  _WaterWaveCupPainter({required this.fillFraction});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final waterHeight = size.height * fillFraction.clamp(0.0, 1.0);
    final baseTopY = size.height - waterHeight;

    final path = Path()..moveTo(0, size.height);
    path.lineTo(0, baseTopY);

    for (double x = 0; x <= size.width; x += 2) {
      final waveY =
          baseTopY + math.sin((x / size.width) * math.pi * 2) * 3.5;
      path.lineTo(x, waveY);
    }

    path.lineTo(size.width, size.height);
    path.close();

    final waterPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, waterPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFBAE6FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Offset.zero & size,
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
        bottomLeft: const Radius.circular(22),
        bottomRight: const Radius.circular(22),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WaterWaveCupPainter oldDelegate) {
    return oldDelegate.fillFraction != fillFraction;
  }
}

class _TrianglePointerPainter extends CustomPainter {
  final Color color;

  _TrianglePointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePointerPainter oldDelegate) => false;
}
