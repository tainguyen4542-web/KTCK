import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../utils/ai_nutrition_analyzer.dart';

class FitHabitController extends ChangeNotifier {
  static const List<TeamMember> group12Members = [
    TeamMember(
      stt: 7,
      mssv: '2380612739',
      fullName: 'Huỳnh Nguyễn Trung Hiếu',
      className: '23DTHD5',
    ),
    TeamMember(
      stt: 34,
      mssv: '2380602321',
      fullName: 'Trần Đình Trí',
      className: '23DTHD5',
    ),
    TeamMember(
      stt: 37,
      mssv: '2380601952',
      fullName: 'Nguyễn Hữu Tài',
      className: '23DTHD5',
    ),
    TeamMember(
      stt: 41,
      mssv: '2380602555',
      fullName: 'Lê Ngọc Quang Vinh',
      className: '23DTHD5',
    ),
  ];

  static const Map<String, FoodSample> sampleMeals = {
    'healthy_bowl': FoodSample(
      key: 'healthy_bowl',
      name: 'Healthy Bowl: Ức gà nướng, Gạo lứt & Bơ',
      serving: 'Khẩu phần ước tính bằng AI: 1 tô (420g)',
      kcal: 520,
      protein: '44g',
      carbs: '50g',
      fat: '16g',
      confidence: '98.4%',
      tip:
          'Nhận xét AI: Giàu đạm sạch và chất béo tốt từ quả bơ, rất phù hợp sau buổi tập Gym hoặc chạy bộ.',
      emoji: 'salad',
      gradientColors: [Color(0xFF0F3D2E), Color(0xFF10B981)],
      assetImage: 'assets/images/healthy_bowl.jpg',
    ),
    'pho_bo': FoodSample(
      key: 'pho_bo',
      name: 'Phở Bò Tái Nạm Truyền Thống',
      serving: 'Khẩu phần ước tính bằng AI: 1 tô lớn (550g)',
      kcal: 478,
      protein: '30g',
      carbs: '58g',
      fat: '14g',
      confidence: '97.9%',
      tip:
          'Nhận xét AI: Cân bằng năng lượng bữa sáng tốt; nên hạn chế nước béo để tối ưu lượng Natri và Fat.',
      emoji: 'noodle',
      gradientColors: [Color(0xFF0F3D2E), Color(0xFFF97316)],
      assetImage: 'assets/images/pho_bo.jpg',
    ),
    'banh_mi': FoodSample(
      key: 'banh_mi',
      name: 'Bánh Mì Thịt Nướng & Trứng Ốp La',
      serving: 'Khẩu phần ước tính bằng AI: 1 ổ đầy đủ (230g)',
      kcal: 441,
      protein: '19g',
      carbs: '53g',
      fat: '17g',
      confidence: '96.5%',
      tip:
          'Nhận xét AI: Cung cấp năng lượng nhanh trước giờ học hoặc làm việc; nên ăn kèm nhiều dưa leo và đồ chua.',
      emoji: 'bakery',
      gradientColors: [Color(0xFF0F3D2E), Color(0xFFF97316)],
      assetImage: 'assets/images/banh_mi.jpg',
    ),
  };

  static const Map<String, List<WorkoutPlanItem>> workoutRoadmaps = {
    'fatloss': [
      WorkoutPlanItem(
        day: 'Thứ 2',
        title: 'HIIT Đốt Mỡ Toàn Thân (Tabata 4 Hiệp)',
        duration: '25 phút',
        kcal: 360,
        level: 'Cao',
      ),
      WorkoutPlanItem(
        day: 'Thứ 3',
        title: 'Chạy bộ biến tốc (Interval Running)',
        duration: '35 phút',
        kcal: 410,
        level: 'Cao',
      ),
      WorkoutPlanItem(
        day: 'Thứ 4',
        title: 'Bài tập Core Stability & Mountain Climbers',
        duration: '30 phút',
        kcal: 280,
        level: 'Trung bình',
      ),
      WorkoutPlanItem(
        day: 'Thứ 5',
        title: 'Nhảy dây 1000 cái + Burpees',
        duration: '30 phút',
        kcal: 390,
        level: 'Cao',
      ),
      WorkoutPlanItem(
        day: 'Thứ 6',
        title: 'Đi bộ nhanh dốc cao (Incline Walk)',
        duration: '40 phút',
        kcal: 320,
        level: 'Trung bình',
      ),
    ],
    'muscle': [
      WorkoutPlanItem(
        day: 'Thứ 2',
        title: 'Thân trên: Push-up, Vai & Tay sau',
        duration: '40 phút',
        kcal: 280,
        level: 'Khá',
      ),
      WorkoutPlanItem(
        day: 'Thứ 3',
        title: 'Thân dưới: Squat, Lunges & Bắp chân',
        duration: '40 phút',
        kcal: 330,
        level: 'Cao',
      ),
      WorkoutPlanItem(
        day: 'Thứ 4',
        title: 'Lưng Xô & Bụng Core 6 Múi',
        duration: '35 phút',
        kcal: 260,
        level: 'Trung bình',
      ),
      WorkoutPlanItem(
        day: 'Thứ 5',
        title: 'Nghỉ chủ động: Đi bộ & Giãn cơ sâu',
        duration: '25 phút',
        kcal: 140,
        level: 'Nhẹ',
      ),
      WorkoutPlanItem(
        day: 'Thứ 6',
        title: 'Tổ hợp Sức mạnh Toàn thân (Compound)',
        duration: '45 phút',
        kcal: 350,
        level: 'Cao',
      ),
    ],
    'endurance': [
      WorkoutPlanItem(
        day: 'Thứ 2',
        title: 'Chạy bộ Zone 2 & Giãn cơ toàn thân',
        duration: '30 phút',
        kcal: 240,
        level: 'Cơ bản',
      ),
      WorkoutPlanItem(
        day: 'Thứ 3',
        title: 'Plank, Squat & Core Stability',
        duration: '25 phút',
        kcal: 210,
        level: 'Trung bình',
      ),
      WorkoutPlanItem(
        day: 'Thứ 4',
        title: 'Đạp xe ngoài trời hoặc Nhảy dây bền',
        duration: '35 phút',
        kcal: 310,
        level: 'Trung bình',
      ),
      WorkoutPlanItem(
        day: 'Thứ 5',
        title: 'Yoga phục hồi cột sống & Hít thở sâu',
        duration: '30 phút',
        kcal: 160,
        level: 'Nhẹ nhàng',
      ),
      WorkoutPlanItem(
        day: 'Thứ 6',
        title: 'Full-body Cardio không dụng cụ',
        duration: '30 phút',
        kcal: 290,
        level: 'Khá',
      ),
    ],
  };

  int currentTabIndex = 0;
  bool showGradingMode = false;

  // Chức năng 1: Tài khoản & Khóa Sinh trắc học / PIN
  String currentUserName = 'Huỳnh Nguyễn Trung Hiếu';
  String currentUserEmail = '2380612739@student.edu.vn';
  String currentUserMssv = '2380612739';
  String savedPin = '1234';
  bool pinSecurityEnabled = true;
  bool isAppLocked = false;

  // Chức năng 2 & 6: Thói quen & Tìm kiếm / Bộ lọc
  String searchQuery = '';
  String selectedCategory = 'Tất cả';
  String selectedStatusFilter = 'all';

  // Chức năng 3: Chỉ số BMI & Nước uống
  double currentWeightKg = 66.0;
  double currentHeightCm = 173.0;
  int waterIntakeMl = 1500;
  int waterGoalMl = 2000;

  // Chức năng 4: Biểu đồ & Heatmap 12 tuần (84 ngày)
  final List<int> heatmapLevels = List<int>.generate(
    84,
    (index) => (index * 3 + 2) % 5,
  );

  // Chức năng 5 & 7: Thông báo cục bộ & Offline-First Sync
  bool waterReminderEvery2h = true;
  bool isOnline = true;
  String lastSyncTime = 'Vừa xong';

  // Chức năng 8: AI Food Scanner & Lộ trình tập
  String selectedSampleMealKey = 'healthy_bowl';
  FoodSample currentScannedMeal = sampleMeals['healthy_bowl']!;
  bool isScanningFood = false;
  String selectedWorkoutGoal = 'fatloss';
  String geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  final List<HabitItem> habits = [
    HabitItem(
      id: 'h1',
      title: 'Chạy bộ buổi sáng 30 phút quanh công viên',
      category: 'Vận động',
      cycle: 'Hằng ngày',
      time: '06:00',
      streak: 14,
      completedToday: true,
      note: 'Giữ nhịp tim vùng Zone 2, khởi động kỹ khớp cổ chân',
    ),
    HabitItem(
      id: 'h2',
      title: 'Uống đủ 8 cốc nước lọc (2000ml)',
      category: 'Sức khỏe',
      cycle: 'Hằng ngày',
      time: '08:00',
      streak: 12,
      completedToday: true,
      note: 'Uống 250ml nước ấm ngay sau khi thức dậy',
    ),
    HabitItem(
      id: 'h3',
      title: 'Ôn luyện lập trình Mobile Flutter',
      category: 'Học tập',
      cycle: 'Thứ 2 - Thứ 6',
      time: '19:30',
      streak: 9,
      completedToday: true,
      note: 'Hoàn thành kiến trúc Offline-first SQLite & Firebase Sync',
    ),
    HabitItem(
      id: 'h4',
      title: 'Thiền định & Thư giãn mắt 15 phút trước khi ngủ',
      category: 'Tinh thần',
      cycle: 'Hằng ngày',
      time: '22:15',
      streak: 6,
      completedToday: false,
      note: 'Tắt màn hình thiết bị điện tử trước 22:30',
    ),
    HabitItem(
      id: 'h5',
      title: 'Ăn tối lành mạnh giàu Protein (Healthy Bowl)',
      category: 'Sức khỏe',
      cycle: 'Hằng ngày',
      time: '18:30',
      streak: 8,
      completedToday: true,
      note: 'Quét khẩu phần bằng AI Scanner để kiểm soát Calo',
    ),
    HabitItem(
      id: 'h6',
      title: 'Đọc 15 trang sách chuyên ngành Công nghệ',
      category: 'Học tập',
      cycle: 'Hằng ngày',
      time: '21:00',
      streak: 5,
      completedToday: false,
      note: 'Tổng hợp 3 ý chính vào sổ tay cá nhân',
    ),
  ];

  final List<HealthLog> healthLogs = [
    const HealthLog(
      id: 'bmi1',
      date: '26/10/2026',
      weight: 66.0,
      height: 173,
      bmi: 22.05,
      status: 'Bình thường',
    ),
    const HealthLog(
      id: 'bmi2',
      date: '15/10/2026',
      weight: 66.8,
      height: 173,
      bmi: 22.32,
      status: 'Bình thường',
    ),
    const HealthLog(
      id: 'bmi3',
      date: '01/10/2026',
      weight: 67.5,
      height: 173,
      bmi: 22.55,
      status: 'Bình thường',
    ),
  ];

  final List<MealLog> mealLogs = [
    const MealLog(
      id: 'm1',
      time: '07:30',
      name: 'Phở Bò Tái Nạm Truyền Thống',
      kcal: 478,
      macros: 'P: 30g • C: 58g • F: 14g',
    ),
    const MealLog(
      id: 'm2',
      time: '12:15',
      name: 'Healthy Bowl: Ức gà nướng, Gạo lứt & Bơ',
      kcal: 520,
      macros: 'P: 44g • C: 50g • F: 16g',
    ),
    const MealLog(
      id: 'm3',
      time: '16:00',
      name: 'Sữa chua Hy Lạp & Hạnh nhân',
      kcal: 420,
      macros: 'P: 18g • C: 32g • F: 15g',
    ),
  ];

  final List<NotificationSchedule> notifications = [
    NotificationSchedule(
      id: 'n1',
      time: '06:00',
      title: 'Chạy bộ buổi sáng 30 phút (Zone 2)',
      enabled: true,
    ),
    NotificationSchedule(
      id: 'n2',
      time: '08:00 - 20:00',
      title: 'Nhắc uống 250ml nước định kỳ mỗi 2 giờ',
      enabled: true,
    ),
    NotificationSchedule(
      id: 'n3',
      time: '19:30',
      title: 'Ôn luyện lập trình Mobile Đồ án Nhóm 12',
      enabled: true,
    ),
    NotificationSchedule(
      id: 'n4',
      time: '22:15',
      title: 'Thiền định & Nghỉ ngơi trước 23:00',
      enabled: true,
    ),
  ];

  final List<SyncQueueItem> pendingQueue = [];
  final List<String> syncLogs = [
    '[15:50:02] [SQLITE] Khởi tạo cơ sở dữ liệu cục bộ hoàn tất (6 thói quen, 3 bản ghi BMI).',
    '[15:50:05] [CLOUD] Đồng bộ Firebase Firestore thành công cho hồ sơ Huỳnh Nguyễn Trung Hiếu.',
  ];

  // ==================== GETTERS & KPI ====================
  int get completedCount => habits.where((h) => h.completedToday).length;

  int get completionRatePercent => habits.isEmpty
      ? 0
      : ((completedCount / habits.length) * 100).round();

  int get maxStreak => habits.isEmpty
      ? 0
      : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

  int get totalCheckIns =>
      habits.fold(0, (sum, item) => sum + item.streak) + 84;

  int get totalCaloriesToday =>
      mealLogs.fold(0, (sum, item) => sum + item.kcal);

  int get activeWaterCups => (waterIntakeMl / 250).floor().clamp(0, 8);

  bool get hasGeminiApiKey => geminiApiKey.trim().isNotEmpty;

  List<HabitItem> get filteredHabits {
    final q = searchQuery.toLowerCase().trim();
    return habits.where((h) {
      final matchSearch =
          q.isEmpty ||
          h.title.toLowerCase().contains(q) ||
          h.note.toLowerCase().contains(q);
      final matchCategory =
          selectedCategory == 'Tất cả' || h.category == selectedCategory;
      final matchStatus =
          selectedStatusFilter == 'all' ||
          (selectedStatusFilter == 'completed' && h.completedToday) ||
          (selectedStatusFilter == 'pending' && !h.completedToday);
      return matchSearch && matchCategory && matchStatus;
    }).toList();
  }

  Map<String, int> get categoryCounts {
    final counts = <String, int>{
      'Vận động': 0,
      'Sức khỏe': 0,
      'Học tập': 0,
      'Tinh thần': 0,
    };
    for (final h in habits) {
      counts[h.category] = (counts[h.category] ?? 0) + 1;
    }
    return counts;
  }

  String _nowTimeStr() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String _todayDateStr() {
    final now = DateTime.now();
    final dd = now.day.toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    return '$dd/$mm/${now.year}';
  }

  void logSqliteAndSync(String actionDescription) {
    final t = _nowTimeStr();
    if (isOnline) {
      syncLogs.insert(0, '[$t] [SYNCED] SQLite -> Firebase: $actionDescription');
      lastSyncTime = t;
    } else {
      pendingQueue.add(SyncQueueItem(time: t, action: actionDescription));
      syncLogs.insert(
        0,
        '[$t] [OFFLINE QUEUE] Đã ghi SQLite cục bộ: $actionDescription',
      );
    }
    notifyListeners();
  }

  void toggleGradingMode() {
    showGradingMode = !showGradingMode;
    notifyListeners();
  }

  // ==================== CHỨC NĂNG 1: AUTH & SECURITY LOCK ====================
  void lockApp() {
    isAppLocked = true;
    notifyListeners();
  }

  void unlockByBiometric() {
    isAppLocked = false;
    logSqliteAndSync('Mở khóa ứng dụng bằng xác thực Sinh trắc học');
  }

  bool verifyPin(String pin) {
    if (pin.trim() == savedPin) {
      isAppLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  void togglePinSecurity(bool enabled) {
    pinSecurityEnabled = enabled;
    logSqliteAndSync(
      'Cập nhật khóa bảo mật PIN: ${enabled ? "Đang bật" : "Đã tắt"}',
    );
  }

  bool updateSavedPin(String newPin) {
    final trimmed = newPin.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(trimmed)) {
      return false;
    }
    savedPin = trimmed;
    logSqliteAndSync('Cập nhật mã PIN bảo mật thành $trimmed');
    return true;
  }

  void loginWithCredentials({required String name, required String email}) {
    if (name.trim().isEmpty) return;
    currentUserName = name.trim();
    if (email.trim().isNotEmpty) {
      currentUserEmail = email.trim();
    }
    logSqliteAndSync('Cập nhật thông tin tài khoản: $currentUserName');
  }

  void simulateGoogleSignIn() {
    currentUserName = 'Huỳnh Nguyễn Trung Hiếu';
    currentUserEmail = 'trunghieu.nhom12@gmail.com';
    logSqliteAndSync('Xác thực OAuth2 qua Google Sign-In thành công');
  }

  void switchMemberProfile(TeamMember member) {
    currentUserName = member.fullName;
    currentUserMssv = member.mssv;
    currentUserEmail = member.email;
    logSqliteAndSync('Chuyển hồ sơ thành viên Nhóm 12: ${member.fullName}');
  }

  // ==================== CHỨC NĂNG 2 & 6: HABIT CRUD & FILTER ====================
  void setSearchQuery(String val) {
    searchQuery = val;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    selectedStatusFilter = status;
    notifyListeners();
  }

  HabitItem? toggleHabitCheckIn(String id) {
    final idx = habits.indexWhere((h) => h.id == id);
    if (idx == -1) return null;
    final habit = habits[idx];
    habit.completedToday = !habit.completedToday;
    habit.streak = habit.completedToday
        ? habit.streak + 1
        : (habit.streak > 0 ? habit.streak - 1 : 0);
    logSqliteAndSync(
      'Check-in "${habit.title}" (${habit.completedToday ? "Hoàn thành" : "Bỏ chọn"})',
    );
    return habit;
  }

  void saveHabit({
    String? id,
    required String title,
    required String category,
    required String cycle,
    required String time,
    required int streak,
    required String note,
  }) {
    if (id != null && id.isNotEmpty) {
      final idx = habits.indexWhere((h) => h.id == id);
      if (idx != -1) {
        habits[idx]
          ..title = title
          ..category = category
          ..cycle = cycle
          ..time = time
          ..streak = streak
          ..note = note;
        logSqliteAndSync('Cập nhật thói quen "$title"');
        return;
      }
    }

    habits.insert(
      0,
      HabitItem(
        id: 'h_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        category: category,
        cycle: cycle,
        time: time,
        streak: streak,
        completedToday: false,
        note: note,
      ),
    );
    logSqliteAndSync('Thêm thói quen mới "$title"');
  }

  HabitItem? deleteHabit(String id) {
    final idx = habits.indexWhere((h) => h.id == id);
    if (idx == -1) return null;
    final removed = habits.removeAt(idx);
    logSqliteAndSync('Xóa thói quen "${removed.title}"');
    return removed;
  }

  // ==================== CHỨC NĂNG 3: BMI & WATER TRACKER ====================
  BmiEvaluation evaluateBmi(double weightKg, double heightCm) {
    final hMeter = (heightCm <= 0 ? 170 : heightCm) / 100.0;
    final bmi = weightKg / (hMeter * hMeter);

    if (bmi < 18.5) {
      return BmiEvaluation(
        bmi: double.parse(bmi.toStringAsFixed(2)),
        status: 'Thiếu cân',
        advice:
            'Khuyến nghị tăng cường thực phẩm giàu Protein, tinh bột hấp thu chậm và tập kháng lực.',
        color: const Color(0xFF0284C7),
        markerFraction: 0.18,
      );
    } else if (bmi < 23.0) {
      return BmiEvaluation(
        bmi: double.parse(bmi.toStringAsFixed(2)),
        status: 'Bình thường',
        advice:
            'Chỉ số cơ thể đạt chuẩn WHO. Hãy duy trì uống đủ 2000ml nước và vận động 30 phút mỗi ngày.',
        color: const Color(0xFF10B981),
        markerFraction: 0.48,
      );
    } else if (bmi < 25.0) {
      return BmiEvaluation(
        bmi: double.parse(bmi.toStringAsFixed(2)),
        status: 'Thừa cân',
        advice:
            'Nên ưu tiên thực đơn giảm tinh bột tinh chế và tăng 25–30 phút Cardio mỗi ngày.',
        color: const Color(0xFFF97316),
        markerFraction: 0.68,
      );
    } else {
      return BmiEvaluation(
        bmi: double.parse(bmi.toStringAsFixed(2)),
        status: 'Béo phì',
        advice:
            'Khuyến nghị áp dụng lộ trình HIIT Đốt mỡ và kiểm soát năng lượng nạp qua AI Scanner.',
        color: const Color(0xFFDC2626),
        markerFraction: 0.86,
      );
    }
  }

  BmiEvaluation get bmiEvaluation =>
      evaluateBmi(currentWeightKg, currentHeightCm);

  BmiEvaluation updateAndSaveBmi({
    required double weight,
    required double height,
  }) {
    currentWeightKg = weight;
    currentHeightCm = height;
    final eval = evaluateBmi(weight, height);
    healthLogs.insert(
      0,
      HealthLog(
        id: 'bmi_${DateTime.now().millisecondsSinceEpoch}',
        date: _todayDateStr(),
        weight: weight,
        height: height,
        bmi: eval.bmi,
        status: eval.status,
      ),
    );
    logSqliteAndSync(
      'Lưu chỉ số BMI: ${weight.toStringAsFixed(1)}kg, ${height.toStringAsFixed(0)}cm (BMI ${eval.bmi})',
    );
    return eval;
  }

  void deleteHealthLog(String id) {
    healthLogs.removeWhere((r) => r.id == id);
    logSqliteAndSync('Xóa bản ghi lịch sử BMI');
  }

  void setWaterByCupIndex(int cupIndex) {
    final targetCups = cupIndex + 1;
    waterIntakeMl = (targetCups * 250).clamp(0, 3500);
    logSqliteAndSync(
      'Cập nhật lượng nước uống: $waterIntakeMl ml ($targetCups/8 cốc)',
    );
  }

  void addWater(int deltaMl) {
    waterIntakeMl = (waterIntakeMl + deltaMl).clamp(0, 3500);
    logSqliteAndSync('Ghi nhận thêm +$deltaMl ml nước (Tổng: $waterIntakeMl ml)');
  }

  void resetWater() {
    waterIntakeMl = 0;
    logSqliteAndSync('Đặt lại lượng nước uống hôm nay về 0 ml');
  }

  // ==================== CHỨC NĂNG 4: ANALYTICS & HEATMAP ====================
  int cycleHeatmapLevel(int index) {
    if (index < 0 || index >= heatmapLevels.length) return 0;
    heatmapLevels[index] = (heatmapLevels[index] + 1) % 5;
    notifyListeners();
    return heatmapLevels[index];
  }

  // ==================== CHỨC NĂNG 5 & 7: NOTIFICATIONS & SYNC ====================
  void toggleWaterReminderEvery2h(bool val) {
    waterReminderEvery2h = val;
    logSqliteAndSync(
      'Cấu hình nhắc uống nước định kỳ mỗi 2h: ${val ? "Bật" : "Tắt"}',
    );
  }

  void addNotificationSchedule({required String time, required String title}) {
    if (title.trim().isEmpty) return;
    notifications.insert(
      0,
      NotificationSchedule(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        time: time,
        title: title.trim(),
        enabled: true,
      ),
    );
    logSqliteAndSync('Thêm lịch nhắc cục bộ lúc $time: ${title.trim()}');
  }

  void toggleNotificationSchedule(String id, bool enabled) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    notifications[idx].enabled = enabled;
    logSqliteAndSync(
      'Cập nhật lịch nhắc "${notifications[idx].title}": ${enabled ? "Bật" : "Tắt"}',
    );
  }

  int toggleNetworkMode() {
    isOnline = !isOnline;
    final t = _nowTimeStr();
    int syncedCount = 0;
    if (isOnline) {
      syncedCount = pendingQueue.length;
      syncLogs.insert(
        0,
        '[$t] [ONLINE] Kết nối mạng khôi phục. Đã đồng bộ $syncedCount bản ghi lên Firebase.',
      );
      pendingQueue.clear();
      lastSyncTime = t;
    } else {
      syncLogs.insert(
        0,
        '[$t] [OFFLINE] Đang ở chế độ Ngoại tuyến. Dữ liệu ghi vào SQLite cục bộ.',
      );
    }
    notifyListeners();
    return syncedCount;
  }

  int syncPendingQueueNow() {
    final count = pendingQueue.length;
    isOnline = true;
    final t = _nowTimeStr();
    pendingQueue.clear();
    lastSyncTime = t;
    syncLogs.insert(
      0,
      '[$t] [MANUAL SYNC] Đồng bộ SQLite -> Firebase hoàn tất ($count tác vụ chờ).',
    );
    notifyListeners();
    return count;
  }

  // ==================== CHỨC NĂNG 8: AI FOOD SCANNER & WORKOUT ====================
  void setGeminiApiKey(String key) {
    geminiApiKey = key.trim();
    notifyListeners();
  }

  String get lastRecognizedNutritionJson {
    final p = int.tryParse(currentScannedMeal.protein.replaceAll('g', '')) ?? 0;
    final c = int.tryParse(currentScannedMeal.carbs.replaceAll('g', '')) ?? 0;
    final f = int.tryParse(currentScannedMeal.fat.replaceAll('g', '')) ?? 0;
    final computedKcal = (p * 4) + (c * 4) + (f * 9);
    final map = {
      'name': currentScannedMeal.name,
      'serving': currentScannedMeal.serving,
      'protein_g': p,
      'carbs_g': c,
      'fat_g': f,
      'kcal': computedKcal,
      'confidence': currentScannedMeal.confidence,
      'tip': currentScannedMeal.tip,
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  Future<void> selectSampleMeal(String key) async {
    final meal = sampleMeals[key];
    if (meal == null) return;
    selectedSampleMealKey = key;
    isScanningFood = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 380));
    currentScannedMeal = meal;
    isScanningFood = false;
    notifyListeners();
  }

  Future<void> analyzeUploadedOrCapturedFood({
    required Uint8List imageBytes,
    required String fileName,
    required bool fromCamera,
  }) async {
    selectedSampleMealKey = '';
    isScanningFood = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 450));

    final aiResult = await AiNutritionAnalyzer.analyzeFoodImage(
      imageBytes: imageBytes,
      fileName: fileName,
      fromCamera: fromCamera,
      geminiApiKey: geminiApiKey,
    );

    currentScannedMeal = FoodSample(
      key: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: aiResult.name,
      serving: aiResult.serving,
      kcal: aiResult.kcal,
      protein: '${aiResult.proteinG}g',
      carbs: '${aiResult.carbsG}g',
      fat: '${aiResult.fatG}g',
      confidence: aiResult.confidence,
      tip: aiResult.tip,
      emoji: aiResult.emoji,
      gradientColors: const [Color(0xFF0F3D2E), Color(0xFF10B981)],
      customImageBytes: imageBytes,
    );
    isScanningFood = false;
    logSqliteAndSync(
      '${fromCamera ? "Chụp Camera AI" : "Tải ảnh"} & tính Atwater (4P+4C+9F): "${aiResult.name}" (${aiResult.kcal} kcal)',
    );
  }

  MealLog logCurrentScannedMeal() {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final log = MealLog(
      id: 'm_${now.millisecondsSinceEpoch}',
      time: timeStr,
      name: currentScannedMeal.name,
      kcal: currentScannedMeal.kcal,
      macros:
          'P: ${currentScannedMeal.protein} • C: ${currentScannedMeal.carbs} • F: ${currentScannedMeal.fat}',
    );
    mealLogs.insert(0, log);
    logSqliteAndSync(
      'Ghi nhật ký dinh dưỡng: "${currentScannedMeal.name}" (+${currentScannedMeal.kcal} kcal)',
    );
    return log;
  }

  void setWorkoutGoal(String goal) {
    selectedWorkoutGoal = goal;
    notifyListeners();
  }

  List<WorkoutPlanItem> get currentWorkoutPlan =>
      workoutRoadmaps[selectedWorkoutGoal] ?? workoutRoadmaps['fatloss']!;

  HabitItem applyWorkoutToHabit(WorkoutPlanItem workout) {
    final created = HabitItem(
      id: 'h_${DateTime.now().millisecondsSinceEpoch}',
      title: '${workout.title} (${workout.duration})',
      category: 'Vận động',
      cycle: 'Hằng ngày',
      time: '17:30',
      streak: 1,
      completedToday: false,
      note: 'Tiêu hao khoảng ${workout.kcal} kcal theo lộ trình cân bằng năng lượng',
    );
    habits.insert(0, created);
    logSqliteAndSync(
      'Áp dụng bài tập "${workout.title}" vào danh sách thói quen',
    );
    return created;
  }
}
