import 'package:flutter/material.dart';
import '../state/fithabit_controller.dart';
import '../utils/bento_theme.dart';

class LockScreenOverlay extends StatefulWidget {
  final FitHabitController controller;
  final void Function(String title, String message, Color color) onShowToast;

  const LockScreenOverlay({
    super.key,
    required this.controller,
    required this.onShowToast,
  });

  @override
  State<LockScreenOverlay> createState() => _LockScreenOverlayState();
}

class _LockScreenOverlayState extends State<LockScreenOverlay> {
  String _pinBuffer = '';

  void _onKeyPress(String key) {
    if (key == 'clear') {
      if (_pinBuffer.isNotEmpty) {
        setState(() {
          _pinBuffer = _pinBuffer.substring(0, _pinBuffer.length - 1);
        });
      }
      return;
    }

    if (key == 'bio') {
      widget.controller.unlockByBiometric();
      widget.onShowToast(
        'Mở khóa Sinh trắc học',
        'Xác thực FaceID / Vân tay thành công.',
        BentoColors.mintEmerald,
      );
      setState(() => _pinBuffer = '');
      return;
    }

    if (_pinBuffer.length < 4) {
      setState(() {
        _pinBuffer += key;
      });
      if (_pinBuffer.length == 4) {
        Future.delayed(const Duration(milliseconds: 160), () {
          if (!mounted) return;
          final ok = widget.controller.verifyPin(_pinBuffer);
          if (ok) {
            widget.onShowToast(
              'Mở khóa thành công',
              'Mã PIN chính xác. Chào mừng bạn quay lại FitHabit!',
              BentoColors.mintEmerald,
            );
          } else {
            widget.onShowToast(
              'Sai mã PIN',
              'Mã PIN không đúng (Mặc định: ${widget.controller.savedPin}).',
              BentoColors.danger,
            );
          }
          setState(() => _pinBuffer = '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'bio',
      '0',
      'clear',
    ];

    return Positioned.fill(
      child: Material(
        color: BentoColors.deepForest.withValues(alpha: 0.98),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: BentoColors.mintEmerald.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: BentoColors.mintEmerald.withValues(alpha: 0.4),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: BentoColors.mintEmerald,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'FitHabit Security',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Nhập mã PIN 4 số (Mặc định: ${widget.controller.savedPin}) hoặc xác thực sinh trắc học để tiếp tục',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFA7F3D0),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final filled = index < _pinBuffer.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? BentoColors.mintEmerald
                                : Colors.white.withValues(alpha: 0.12),
                            border: Border.all(
                              color: filled
                                  ? BentoColors.mintEmerald
                                  : Colors.white.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: keys.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.35,
                          ),
                      itemBuilder: (context, index) {
                        final k = keys[index];
                        final isAction = k == 'bio' || k == 'clear';
                        return InkWell(
                          onTap: () => _onKeyPress(k),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isAction
                                  ? BentoColors.mintEmerald.withValues(
                                      alpha: 0.14,
                                    )
                                  : Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isAction
                                    ? BentoColors.mintEmerald.withValues(
                                        alpha: 0.35,
                                      )
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: k == 'bio'
                                ? const Icon(
                                    Icons.fingerprint_rounded,
                                    color: BentoColors.mintEmerald,
                                    size: 26,
                                  )
                                : k == 'clear'
                                ? const Icon(
                                    Icons.backspace_outlined,
                                    color: Colors.white70,
                                    size: 22,
                                  )
                                : Text(
                                    k,
                                    style: BentoTextStyles.statMedium(
                                      fontSize: 22,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _onKeyPress('bio'),
                        icon: const Icon(Icons.face_unlock_outlined, size: 18),
                        label: const Text('Mở khóa nhanh bằng FaceID / TouchID'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFA7F3D0),
                          side: BorderSide(
                            color: BentoColors.mintEmerald.withValues(
                              alpha: 0.45,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
