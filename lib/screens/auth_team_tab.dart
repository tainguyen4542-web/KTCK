import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/fithabit_controller.dart';
import '../utils/bento_theme.dart';

class AuthTeamTab extends StatefulWidget {
  final FitHabitController controller;
  final void Function(String title, String message, Color color) onShowToast;

  const AuthTeamTab({
    super.key,
    required this.controller,
    required this.onShowToast,
  });

  @override
  State<AuthTeamTab> createState() => _AuthTeamTabState();
}

class _AuthTeamTabState extends State<AuthTeamTab> {
  late final List<TextEditingController> _pinDigitCtrls;
  late final List<FocusNode> _pinFocusNodes;
  late final TextEditingController _remTimeCtrl;
  late final TextEditingController _remTitleCtrl;
  bool _showSyncLogs = false;

  @override
  void initState() {
    super.initState();
    final pin = widget.controller.savedPin.padRight(4, '0');
    _pinDigitCtrls = List.generate(
      4,
      (i) => TextEditingController(text: pin[i]),
    );
    _pinFocusNodes = List.generate(4, (_) => FocusNode());
    _remTimeCtrl = TextEditingController(text: '17:30');
    _remTitleCtrl = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in _pinDigitCtrls) {
      c.dispose();
    }
    for (final f in _pinFocusNodes) {
      f.dispose();
    }
    _remTimeCtrl.dispose();
    _remTitleCtrl.dispose();
    super.dispose();
  }

  void _onPinDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _pinFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _pinFocusNodes[index - 1].requestFocus();
    }
  }

  void _saveFourBoxPin() {
    final combined = _pinDigitCtrls.map((c) => c.text.trim()).join();
    final ok = widget.controller.updateSavedPin(combined);
    if (ok) {
      widget.onShowToast(
        'Đã lưu mã PIN',
        'Mã PIN bảo mật 4 số mới là ${widget.controller.savedPin}.',
        BentoColors.mintEmerald,
      );
    } else {
      widget.onShowToast(
        'Mã PIN chưa đủ 4 số',
        'Vui lòng điền đủ 4 ô số PIN.',
        BentoColors.danger,
      );
    }
  }

  void _addSchedule() {
    final title = _remTitleCtrl.text.trim();
    if (title.isEmpty) {
      widget.onShowToast(
        'Thiếu nội dung nhắc',
        'Vui lòng nhập nội dung thông báo nhắc nhở.',
        BentoColors.warmCoral,
      );
      return;
    }
    widget.controller.addNotificationSchedule(
      time: _remTimeCtrl.text.trim().isEmpty
          ? '17:30'
          : _remTimeCtrl.text.trim(),
      title: title,
    );
    _remTitleCtrl.clear();
    widget.onShowToast(
      'Đã thêm lịch nhắc',
      'Đã đăng ký Local Notification cho "$title".',
      BentoColors.mintEmerald,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        // User Profile Header Card (iOS Apple ID style)
        BentoCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: BentoColors.deepForest,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  ctrl.currentUserName.isNotEmpty
                      ? ctrl.currentUserName.trim().split(' ').last[0]
                      : 'H',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ctrl.currentUserName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: BentoColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ctrl.currentUserEmail} • MSSV ${ctrl.currentUserMssv}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: BentoColors.textSecondary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ctrl.simulateGoogleSignIn();
                  widget.onShowToast(
                    'Đồng bộ Google OAuth2',
                    'Đã xác thực tài khoản ${ctrl.currentUserEmail}.',
                    BentoColors.skyBlue,
                  );
                },
                tooltip: 'Xác thực Google OAuth2',
                icon: const Icon(
                  Icons.verified_user_outlined,
                  color: BentoColors.mintEmerald,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ==================== GROUP 1: ĐỒNG BỘ DỮ LIỆU (OFFLINE-FIRST) ====================
        _buildGroupHeader(
          title: 'ĐỒNG BỘ DỮ LIỆU (OFFLINE-FIRST)',
          badge: ctrl.showGradingMode ? 'CN 07 • SQLITE + FIREBASE' : null,
        ),
        BentoCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Row 1: SQLite Local Status
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    const BentoIconBadge(
                      icon: Icons.storage_rounded,
                      color: BentoColors.deepForest,
                      backgroundColor: BentoColors.mintSoft,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cơ sở dữ liệu SQLite Local',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: BentoColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Hoạt động 0ms • Hàng đợi chờ: ${ctrl.pendingQueue.length} bản ghi',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: BentoColors.textSecondary,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: BentoColors.mintSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: BentoTextStyles.subCaption(
                          color: BentoColors.deepForest,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 64, color: BentoColors.border),

              // Row 2: Online / Offline Switch.adaptive
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    BentoIconBadge(
                      icon: ctrl.isOnline
                          ? Icons.wifi_rounded
                          : Icons.airplanemode_active_rounded,
                      color: ctrl.isOnline
                          ? BentoColors.mintEmerald
                          : BentoColors.warmCoral,
                      backgroundColor: ctrl.isOnline
                          ? BentoColors.mintSoft
                          : BentoColors.coralSoft,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kết nối mạng Cloud Realtime',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: BentoColors.textPrimary,
                            ),
                          ),
                          Text(
                            ctrl.isOnline
                                ? 'Trực tuyến • Tự động đẩy lên Firebase'
                                : 'Ngoại tuyến • Lưu tạm vào SQLite Queue',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: BentoColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: ctrl.isOnline,
                      activeThumbColor: BentoColors.mintEmerald,
                      onChanged: (_) {
                        ctrl.toggleNetworkMode();
                        widget.onShowToast(
                          ctrl.isOnline
                              ? 'Đã kết nối Cloud'
                              : 'Chế độ Offline SQLite',
                          ctrl.isOnline
                              ? 'Tự động đồng bộ hàng đợi lên Firebase.'
                              : 'Thao tác được lưu an toàn vào SQLite cục bộ.',
                          ctrl.isOnline
                              ? BentoColors.mintEmerald
                              : BentoColors.warmCoral,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 64, color: BentoColors.border),

              // Row 3: Firebase Sync Action + Last Sync Timestamp
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const BentoIconBadge(
                      icon: Icons.cloud_sync_outlined,
                      color: BentoColors.skyBlue,
                      backgroundColor: BentoColors.skySoft,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Firebase Cloud Firestore',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: BentoColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Đồng bộ gần nhất: ${ctrl.lastSyncTime}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: BentoColors.textSecondary,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        final count = ctrl.syncPendingQueueNow();
                        widget.onShowToast(
                          'Đồng bộ Firebase hoàn tất',
                          count > 0
                              ? 'Đã đẩy $count bản ghi từ SQLite lên Cloud.'
                              : 'Dữ liệu đã ở trạng thái mới nhất.',
                          BentoColors.mintEmerald,
                        );
                      },
                      icon: const Icon(Icons.sync_rounded, size: 16),
                      label: const Text(
                        'Sync ngay',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: BentoColors.mintSoft,
                        foregroundColor: BentoColors.deepForest,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: BentoColors.border),

              // Expandable Sync Console Log
              InkWell(
                onTap: () => setState(() => _showSyncLogs = !_showSyncLogs),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nhật ký giao dịch SQLite ↔ Firebase (${ctrl.syncLogs.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: BentoColors.textSecondary,
                        ),
                      ),
                      Icon(
                        _showSyncLogs
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: BentoColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showSyncLogs)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: ctrl.syncLogs.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        ctrl.syncLogs[i],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10.5,
                          color: Color(0xFF6EE7B7),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ==================== GROUP 2: NHẮC NHỞ THÔNG MINH ====================
        _buildGroupHeader(
          title: 'NHẮC NHỞ THÔNG MINH',
          badge: ctrl.showGradingMode ? 'CN 05 • LOCAL NOTIFICATIONS' : null,
        ),
        BentoCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // 2-Hour Water Reminder with Switch.adaptive
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const BentoIconBadge(
                      icon: Icons.water_drop_outlined,
                      color: BentoColors.skyBlue,
                      backgroundColor: BentoColors.skySoft,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nhắc uống nước mỗi 2 tiếng',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: BentoColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Khung giờ tự động: 08:00 – 20:00 (250ml / lần)',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: BentoColors.textSecondary,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: ctrl.waterReminderEvery2h,
                      activeThumbColor: BentoColors.skyBlue,
                      onChanged: (val) {
                        ctrl.toggleWaterReminderEvery2h(val);
                        widget.onShowToast(
                          val ? 'Đã bật nhắc nước 2h' : 'Đã tắt nhắc nước 2h',
                          val
                              ? 'Sẽ nhắc uống 250ml nước định kỳ mỗi 2 tiếng.'
                              : 'Đã tạm dừng lịch nhắc uống nước.',
                          BentoColors.skyBlue,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 64, color: BentoColors.border),

              // Scheduled Notification Items with Switch.adaptive
              ...ctrl.notifications.map(
                (item) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: BentoColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: BentoColors.border),
                            ),
                            child: Text(
                              item.time,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: BentoColors.deepForest,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: BentoColors.textPrimary,
                              ),
                            ),
                          ),
                          Switch.adaptive(
                            value: item.enabled,
                            activeThumbColor: BentoColors.mintEmerald,
                            onChanged: (v) =>
                                ctrl.toggleNotificationSchedule(item.id, v),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      indent: 16,
                      color: BentoColors.border,
                    ),
                  ],
                ),
              ),

              // Quick Add Reminder Input Row
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: TextField(
                        controller: _remTimeCtrl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                        decoration: _compactDeco('17:30'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _remTitleCtrl,
                        style: const TextStyle(fontSize: 12.5),
                        decoration: _compactDeco('Thêm lời nhắc mới...'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _addSchedule,
                      style: FilledButton.styleFrom(
                        backgroundColor: BentoColors.deepForest,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Thêm',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ==================== GROUP 3: BẢO MẬT & THÔNG TIN NHÓM 12 ====================
        _buildGroupHeader(
          title: 'BẢO MẬT & THÔNG TIN NHÓM 12',
          badge: ctrl.showGradingMode ? 'CN 01 • BIOMETRIC & 4-BOX PIN' : null,
        ),
        BentoCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Biometric / PIN Lock Switch.adaptive
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const BentoIconBadge(
                      icon: Icons.fingerprint_rounded,
                      color: BentoColors.deepForest,
                      backgroundColor: BentoColors.mintSoft,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Khóa Sinh trắc học & Mã PIN',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: BentoColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Bảo vệ dữ liệu sức khỏe bằng FaceID / Mã PIN 4 số',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: BentoColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: ctrl.pinSecurityEnabled,
                      activeThumbColor: BentoColors.deepForest,
                      onChanged: (v) {
                        ctrl.togglePinSecurity(v);
                        widget.onShowToast(
                          v ? 'Đã bật khóa bảo mật' : 'Đã tắt khóa bảo mật',
                          v
                              ? 'Ứng dụng được bảo vệ bằng mã PIN (${ctrl.savedPin}).'
                              : 'Đã tắt yêu cầu mã PIN khi mở ứng dụng.',
                          BentoColors.deepForest,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 64, color: BentoColors.border),

              // 4 Separate Square PIN Digit Boxes (Zero Overflow Guarantee)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cấu hình 4 ô số PIN riêng biệt',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: BentoColors.textSecondary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: ctrl.lockApp,
                          icon: const Icon(
                            Icons.lock_outline_rounded,
                            size: 15,
                          ),
                          label: const Text(
                            'Khóa thử ngay',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: BentoColors.deepForest,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(4, (idx) {
                            return Container(
                              width: 46,
                              height: 48,
                              margin: EdgeInsets.only(right: idx == 3 ? 0 : 8),
                              child: TextField(
                                controller: _pinDigitCtrls[idx],
                                focusNode: _pinFocusNodes[idx],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: BentoTextStyles.statMedium(
                                  fontSize: 18,
                                  color: BentoColors.deepForest,
                                ),
                                onChanged: (v) => _onPinDigitChanged(idx, v),
                                decoration: InputDecoration(
                                  counterText: '',
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  filled: true,
                                  fillColor: BentoColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: BentoColors.border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: BentoColors.border,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: BentoColors.deepForest,
                                      width: 1.8,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        FilledButton.icon(
                          onPressed: _saveFourBoxPin,
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                          ),
                          label: const Text(
                            'Lưu PIN',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: BentoColors.deepForest,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: BentoColors.border),

              // Honor Card for 4 Members of Nhóm 12 - 23DTHD5
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.workspace_premium_rounded,
                              size: 18,
                              color: BentoColors.deepForest,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Thành viên Nhóm 12 • Lớp 23DTHD5',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: BentoColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: BentoColors.mintSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '4 MEMBERS',
                            style: BentoTextStyles.subCaption(
                              color: BentoColors.deepForest,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...FitHabitController.group12Members.map((member) {
                      final isSelected = ctrl.currentUserMssv == member.mssv;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            ctrl.switchMemberProfile(member);
                            widget.onShowToast(
                              'Đã chuyển hồ sơ thành viên',
                              'Đang sử dụng hồ sơ: ${member.fullName} (${member.mssv}).',
                              BentoColors.mintEmerald,
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? BentoColors.mintSoft
                                  : BentoColors.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? BentoColors.mintEmerald
                                    : BentoColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? BentoColors.deepForest
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: BentoColors.border,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${member.stt}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : BentoColors.textPrimary,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.fullName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: BentoColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'MSSV: ${member.mssv} • ${member.className}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: BentoColors.textSecondary,
                                          fontFeatures: [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.chevron_right_rounded,
                                  size: 18,
                                  color: isSelected
                                      ? BentoColors.mintEmerald
                                      : BentoColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupHeader({required String title, String? badge}) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: BentoTextStyles.subCaption(color: BentoColors.textSecondary),
          ),
          if (badge != null)
            Text(
              badge,
              style: BentoTextStyles.subCaption(color: BentoColors.mintEmerald),
            ),
        ],
      ),
    );
  }

  InputDecoration _compactDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: BentoColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: BentoColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: BentoColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: BentoColors.deepForest,
          width: 1.4,
        ),
      ),
    );
  }
}
