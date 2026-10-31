import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../state/fithabit_controller.dart';
import '../utils/bento_theme.dart';

class DashboardTab extends StatelessWidget {
  final FitHabitController controller;
  final void Function(String title, String message, Color color) onShowToast;

  const DashboardTab({
    super.key,
    required this.controller,
    required this.onShowToast,
  });

  static const List<Map<String, String>> _unifiedFilters = [
    {'type': 'cat', 'key': 'Tất cả', 'label': 'Tất cả'},
    {'type': 'cat', 'key': 'Sức khỏe', 'label': 'Sức khỏe'},
    {'type': 'cat', 'key': 'Vận động', 'label': 'Vận động'},
    {'type': 'cat', 'key': 'Học tập', 'label': 'Học tập'},
    {'type': 'cat', 'key': 'Tinh thần', 'label': 'Tinh thần'},
    {'type': 'status', 'key': 'pending', 'label': 'Chưa xong'},
    {'type': 'status', 'key': 'completed', 'label': 'Đã xong'},
  ];

  bool _isFilterChipSelected(Map<String, String> chip) {
    if (chip['type'] == 'status') {
      return controller.selectedStatusFilter == chip['key'];
    }
    return controller.selectedStatusFilter == 'all' &&
        controller.selectedCategory == chip['key'];
  }

  void _selectFilterChip(Map<String, String> chip) {
    if (chip['type'] == 'status') {
      final isAlreadySelected = controller.selectedStatusFilter == chip['key'];
      controller.setStatusFilter(isAlreadySelected ? 'all' : chip['key']!);
    } else {
      controller.setStatusFilter('all');
      controller.setCategoryFilter(chip['key']!);
    }
  }

  void _openHabitModal(BuildContext context, {HabitItem? editing}) {
    final titleCtrl = TextEditingController(text: editing?.title ?? '');
    final timeCtrl = TextEditingController(text: editing?.time ?? '06:30');
    final streakCtrl = TextEditingController(
      text: (editing?.streak ?? 1).toString(),
    );
    final noteCtrl = TextEditingController(text: editing?.note ?? '');
    String selectedCategory = editing?.category ?? 'Vận động';
    String selectedCycle = editing?.cycle ?? 'Hằng ngày';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: BentoColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (controller.showGradingMode)
                              Text(
                                'CN 02 • FORM CRUD THÓI QUEN',
                                style: BentoTextStyles.subCaption(
                                  color: BentoColors.mintEmerald,
                                ),
                              ),
                            Text(
                              editing == null
                                  ? 'Tạo thói quen mới'
                                  : 'Cập nhật thói quen',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: BentoColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Tên thói quen'),
                    TextField(
                      controller: titleCtrl,
                      decoration: _inputDecoration(
                        'VD: Chạy bộ 5km hoặc Đọc sách 30 phút',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Danh mục'),
                              DropdownButtonFormField<String>(
                                initialValue: selectedCategory,
                                decoration: _inputDecoration(''),
                                items:
                                    const [
                                          'Vận động',
                                          'Sức khỏe',
                                          'Học tập',
                                          'Tinh thần',
                                        ]
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(
                                              c,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(() => selectedCategory = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Chu kỳ lặp'),
                              DropdownButtonFormField<String>(
                                initialValue: selectedCycle,
                                decoration: _inputDecoration(''),
                                items:
                                    const [
                                          'Hằng ngày',
                                          'Thứ 2 - Thứ 6',
                                          'Cuối tuần',
                                        ]
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(
                                              c,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(() => selectedCycle = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Giờ nhắc (HH:MM)'),
                              TextField(
                                controller: timeCtrl,
                                decoration: _inputDecoration('06:30'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Chuỗi Streak hiện tại'),
                              TextField(
                                controller: streakCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('1'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('Ghi chú mục tiêu'),
                    TextField(
                      controller: noteCtrl,
                      decoration: _inputDecoration(
                        'VD: Duy trì nhịp tim vùng Zone 2',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: BentoColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: BentoColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final title = titleCtrl.text.trim();
                              if (title.isEmpty) {
                                onShowToast(
                                  'Thiếu thông tin',
                                  'Vui lòng nhập tên thói quen.',
                                  BentoColors.warmCoral,
                                );
                                return;
                              }
                              controller.saveHabit(
                                id: editing?.id,
                                title: title,
                                category: selectedCategory,
                                cycle: selectedCycle,
                                time: timeCtrl.text.trim().isEmpty
                                    ? '07:00'
                                    : timeCtrl.text.trim(),
                                streak: int.tryParse(streakCtrl.text) ?? 1,
                                note: noteCtrl.text.trim().isEmpty
                                    ? 'Mục tiêu cá nhân FitHabit'
                                    : noteCtrl.text.trim(),
                              );
                              Navigator.pop(ctx);
                              onShowToast(
                                editing == null
                                    ? 'Đã thêm thói quen'
                                    : 'Đã lưu cập nhật',
                                'Dữ liệu "$title" đã được ghi vào SQLite.',
                                BentoColors.mintEmerald,
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: BentoColors.deepForest,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Lưu thói quen',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: BentoColors.textSecondary,
        ),
      ),
    );
  }

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: BentoColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: BentoColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: BentoColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: BentoColors.deepForest,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = controller.filteredHabits;
    final pct = controller.completionRatePercent;
    final doneCount = controller.completedCount;
    final totalCount = controller.habits.length;
    final streakFraction = (controller.maxStreak / 21.0).clamp(0.1, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        // 1. Daily Progress Ring Card (Vòng tròn tiến độ kép: % Hoàn thành + Chuỗi Streak)
        BentoCard(
          padding: const EdgeInsets.all(20),
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
                        'DAILY PROGRESS RING',
                        style: BentoTextStyles.subCaption(
                          color: BentoColors.deepForest,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Chào buổi sáng, ${controller.currentUserName.split(' ').last}',
                        style: const TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w700,
                          color: BentoColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _openHabitModal(context),
                    icon: const Icon(Icons.add_rounded, size: 17),
                    label: const Text(
                      'Thói quen',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: BentoColors.mintSoft,
                      foregroundColor: BentoColors.deepForest,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  // Dual Concentric Ring
                  SizedBox(
                    width: 132,
                    height: 132,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(132, 132),
                          painter: _DualProgressRingPainter(
                            outerProgress: (pct / 100.0).clamp(0.0, 1.0),
                            innerProgress: streakFraction,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$pct%',
                              style: BentoTextStyles.statLarge(
                                fontSize: 25,
                                color: BentoColors.deepForest,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$doneCount/$totalCount xong',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: BentoColors.textSecondary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),

                  // Right Ring Metrics Breakdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRingMetricRow(
                          dotColor: BentoColors.mintEmerald,
                          label: 'Tiến độ thói quen',
                          value: '$pct%',
                          sub: 'Hoàn thành $doneCount/$totalCount mục tiêu',
                        ),
                        const SizedBox(height: 12),
                        _buildRingMetricRow(
                          dotColor: BentoColors.warmCoral,
                          label: 'Chuỗi Streak kỷ lục',
                          value: '${controller.maxStreak} ngày',
                          sub: 'Mục tiêu mốc 21 ngày liên tiếp',
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: BentoColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: BentoColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.water_drop_rounded,
                                    size: 14,
                                    color: BentoColors.skyBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${controller.waterIntakeMl}ml',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: BentoColors.textPrimary,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 12,
                                color: BentoColors.border,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    size: 15,
                                    color: BentoColors.warmCoral,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${controller.totalCaloriesToday} kcal',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: BentoColors.textPrimary,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Rounded Search Bar & Smooth Animated Filter Chips (Chức năng 6)
        BentoCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.showGradingMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'CN 06 • TÌM KIẾM & BỘ LỌC ĐA TIÊU CHÍ',
                    style: BentoTextStyles.subCaption(
                      color: BentoColors.deepForest,
                    ),
                  ),
                ),
              TextField(
                onChanged: controller.setSearchQuery,
                style: const TextStyle(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm thói quen, ghi chú...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: BentoColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 19,
                    color: BentoColors.textSecondary,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: BentoColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: BentoColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: BentoColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(
                      color: BentoColors.deepForest,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _unifiedFilters.map((chip) {
                    final active = _isFilterChipSelected(chip);
                    return Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: GestureDetector(
                        onTap: () => _selectFilterChip(chip),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? BentoColors.deepForest
                                : BentoColors.background,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: active
                                  ? BentoColors.deepForest
                                  : BentoColors.border,
                            ),
                          ),
                          child: Text(
                            chip['label']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active
                                  ? Colors.white
                                  : BentoColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Section Header with Swipe Hint
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Thói quen hằng ngày',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: BentoColors.textPrimary,
                    ),
                  ),
                  if (controller.showGradingMode) ...[
                    const SizedBox(width: 8),
                    Text(
                      'CN 02 • SLIDABLE CRUD',
                      style: BentoTextStyles.subCaption(
                        color: BentoColors.mintEmerald,
                      ),
                    ),
                  ],
                ],
              ),
              const Row(
                children: [
                  Icon(
                    Icons.swipe_left_outlined,
                    size: 14,
                    color: BentoColors.textMuted,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Vuốt trái để Sửa / Xóa',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: BentoColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        if (filtered.isEmpty)
          BentoCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const BentoIconBadge(
                  icon: Icons.filter_list_off_rounded,
                  color: BentoColors.textSecondary,
                  backgroundColor: BentoColors.background,
                  size: 46,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Không tìm thấy thói quen phù hợp',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: BentoColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hãy thử đổi từ khóa hoặc chọn bộ lọc khác.',
                  style: TextStyle(
                    fontSize: 12,
                    color: BentoColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...filtered.map(
            (habit) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SlidableHabitCard(
                key: ValueKey(habit.id),
                habit: habit,
                onToggleCheckIn: () {
                  final updated = controller.toggleHabitCheckIn(habit.id);
                  if (updated != null && updated.completedToday) {
                    onShowToast(
                      'Hoàn thành mục tiêu',
                      'Chuỗi Streak "${updated.title}" tăng lên ${updated.streak} ngày.',
                      BentoColors.mintEmerald,
                    );
                  }
                },
                onEdit: () => _openHabitModal(context, editing: habit),
                onDelete: () {
                  final removed = controller.deleteHabit(habit.id);
                  if (removed != null) {
                    onShowToast(
                      'Đã xóa thói quen',
                      'Đã xóa "${removed.title}" khỏi danh sách.',
                      BentoColors.danger,
                    );
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRingMetricRow({
    required Color dotColor,
    required String label,
    required String value,
    required String sub,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: BentoColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: BentoTextStyles.statMedium(
                      fontSize: 14,
                      color: BentoColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 11,
                  color: BentoColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DualProgressRingPainter extends CustomPainter {
  final double outerProgress;
  final double innerProgress;

  _DualProgressRingPainter({
    required this.outerProgress,
    required this.innerProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.width / 2) - 8;
    final innerRadius = outerRadius - 14;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE5E7EB);

    final innerTrackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFFEDD5);

    canvas.drawCircle(center, outerRadius, trackPaint);
    canvas.drawCircle(center, innerRadius, innerTrackPaint);

    final outerArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = BentoColors.mintEmerald;

    final innerArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = BentoColors.warmCoral;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -math.pi / 2,
      math.pi * 2 * outerProgress,
      false,
      outerArcPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      -math.pi / 2,
      math.pi * 2 * innerProgress,
      false,
      innerArcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DualProgressRingPainter oldDelegate) {
    return oldDelegate.outerProgress != outerProgress ||
        oldDelegate.innerProgress != innerProgress;
  }
}

class _SlidableHabitCard extends StatefulWidget {
  final HabitItem habit;
  final VoidCallback onToggleCheckIn;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SlidableHabitCard({
    super.key,
    required this.habit,
    required this.onToggleCheckIn,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_SlidableHabitCard> createState() => _SlidableHabitCardState();
}

class _SlidableHabitCardState extends State<_SlidableHabitCard> {
  double _dragOffset = 0.0;
  static const double _maxSlide = 132.0;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(-_maxSlide, 0.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      if (_dragOffset < -_maxSlide / 2.2) {
        _dragOffset = -_maxSlide;
      } else {
        _dragOffset = 0.0;
      }
    });
  }

  void _toggleSlideMenu() {
    setState(() {
      _dragOffset = _dragOffset < -20 ? 0.0 : -_maxSlide;
    });
  }

  Color _categoryAccentColor(String category) {
    switch (category) {
      case 'Vận động':
        return BentoColors.mintEmerald;
      case 'Sức khỏe':
        return BentoColors.skyBlue;
      case 'Học tập':
        return const Color(0xFF6366F1);
      default:
        return BentoColors.warmCoral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final accent = _categoryAccentColor(habit.category);

    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // Background Slidable Actions (Sửa / Xóa)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BentoColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildSlideActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Sửa',
                    color: BentoColors.deepForest,
                    onTap: () {
                      setState(() => _dragOffset = 0);
                      widget.onEdit();
                    },
                  ),
                  const SizedBox(width: 6),
                  _buildSlideActionButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Xóa',
                    color: BentoColors.danger,
                    onTap: () {
                      setState(() => _dragOffset = 0);
                      widget.onDelete();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Foreground Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: BentoCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              borderColor: habit.completedToday
                  ? BentoColors.mintEmerald.withValues(alpha: 0.45)
                  : BentoColors.border,
              child: Row(
                children: [
                  // Circular Animated Check-in Button
                  GestureDetector(
                    onTap: widget.onToggleCheckIn,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutBack,
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: habit.completedToday
                            ? BentoColors.mintEmerald
                            : Colors.white,
                        border: Border.all(
                          color: habit.completedToday
                              ? BentoColors.mintEmerald
                              : const Color(0xFFD1D5DB),
                          width: 2.2,
                        ),
                        boxShadow: habit.completedToday
                            ? [
                                BoxShadow(
                                  color: BentoColors.mintEmerald.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: AnimatedScale(
                        scale: habit.completedToday ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: const Icon(
                          Icons.check_rounded,
                          size: 19,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),

                  // Habit Content
                  Expanded(
                    child: InkWell(
                      onTap: _toggleSlideMenu,
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: habit.completedToday
                                  ? BentoColors.textMuted
                                  : BentoColors.textPrimary,
                              decoration: habit.completedToday
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            habit.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: BentoColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildMiniBadge(
                                icon: Icons.label_outline_rounded,
                                text: habit.category,
                                color: accent,
                              ),
                              _buildMiniBadge(
                                icon: Icons.schedule_rounded,
                                text: '${habit.time} • ${habit.cycle}',
                                color: BentoColors.textSecondary,
                              ),
                              _buildMiniBadge(
                                icon: Icons.local_fire_department_rounded,
                                text: '${habit.streak} ngày',
                                color: BentoColors.warmCoral,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Subtle slide handle indicator
                  InkWell(
                    onTap: _toggleSlideMenu,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Icon(
                        _dragOffset < -20
                            ? Icons.chevron_right_rounded
                            : Icons.more_vert_rounded,
                        size: 18,
                        color: BentoColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 54,
        height: 68,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.5, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
