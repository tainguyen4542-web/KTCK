import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_models.dart';
import '../state/fithabit_controller.dart';
import '../utils/bento_theme.dart';
import '../utils/camera_upload_helper.dart';

class AiScannerTab extends StatefulWidget {
  final FitHabitController controller;
  final void Function(String title, String message, Color color) onShowToast;

  const AiScannerTab({
    super.key,
    required this.controller,
    required this.onShowToast,
  });

  @override
  State<AiScannerTab> createState() => _AiScannerTabState();
}

class _AiScannerTabState extends State<AiScannerTab>
    with SingleTickerProviderStateMixin {
  AnimationController? _laserController;
  final ImagePicker _imagePicker = ImagePicker();
  CameraController? _cameraController;
  bool _isCameraActive = false;
  bool _isStartingCamera = false;
  bool _isCapturingPhoto = false;
  Object? _cameraError;
  bool _showJsonDetail = false;
  bool _showApiKeyInput = false;
  late final TextEditingController _apiKeyCtrl;

  AnimationController _ensureLaserController() {
    return _laserController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);
  }

  @override
  void initState() {
    super.initState();
    ensureWebPluginsRegistered();
    _ensureLaserController();
    _apiKeyCtrl = TextEditingController(text: widget.controller.geminiApiKey);
  }

  @override
  void dispose() {
    _disposeCameraController();
    _laserController?.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _disposeCameraController() async {
    final oldController = _cameraController;
    _cameraController = null;
    if (oldController != null) {
      try {
        await oldController.dispose();
      } catch (_) {}
    }
  }

  Future<void> _pickMeal(String key) async {
    if (_isCameraActive || _cameraError != null) {
      await _disposeCameraController();
      if (mounted) {
        setState(() {
          _isCameraActive = false;
          _cameraError = null;
        });
      }
    }
    await widget.controller.selectSampleMeal(key);
    final meal = widget.controller.currentScannedMeal;
    widget.onShowToast(
      'Nhận diện AI hoàn tất',
      'Đã phân tích "${meal.name}" (${meal.kcal} kcal).',
      BentoColors.mintEmerald,
    );
  }

  Future<void> _handleUploadImage() async {
    if (_isCameraActive || _cameraError != null) {
      await _disposeCameraController();
      if (mounted) {
        setState(() {
          _isCameraActive = false;
          _cameraError = null;
        });
      }
    }

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (!mounted) return;
        await widget.controller.analyzeUploadedOrCapturedFood(
          imageBytes: bytes,
          fileName: pickedFile.name,
          fromCamera: false,
        );
        final meal = widget.controller.currentScannedMeal;
        widget.onShowToast(
          'Phân tích ảnh thành công',
          'Nhận diện "${meal.name}" • ${meal.kcal} kcal (${meal.protein} P, ${meal.carbs} C, ${meal.fat} F).',
          BentoColors.mintEmerald,
        );
        return;
      }
    } catch (_) {
      final fallbackPicked = await pickFoodImageFromFile();
      if (fallbackPicked == null) return;
      await widget.controller.analyzeUploadedOrCapturedFood(
        imageBytes: fallbackPicked.bytes,
        fileName: fallbackPicked.fileName,
        fromCamera: false,
      );
      final meal = widget.controller.currentScannedMeal;
      widget.onShowToast(
        'Phân tích ảnh thành công',
        'Nhận diện "${meal.name}" • ${meal.kcal} kcal.',
        BentoColors.mintEmerald,
      );
    }
  }

  Future<void> _handleShutterButtonPressed() async {
    if (_isCameraActive) {
      await _handleCaptureFromCamera();
    } else {
      await _handleOpenCamera();
    }
  }

  Future<void> _handleOpenCamera() async {
    setState(() {
      _isStartingCamera = true;
      _cameraError = null;
    });

    await _disposeCameraController();

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException(
          'NoCameraAvailable',
          'Không tìm thấy thiết bị Camera / Webcam trên máy.',
        );
      }

      final selectedCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isCameraActive = true;
        _isStartingCamera = false;
        _cameraError = null;
      });
    } catch (error) {
      await _disposeCameraController();
      if (!mounted) return;
      setState(() {
        _isCameraActive = false;
        _isStartingCamera = false;
        _cameraError = error;
      });
      widget.onShowToast(
        'Lỗi khởi tạo Camera',
        error.toString(),
        BentoColors.danger,
      );
    }
  }

  Future<void> _handleCaptureFromCamera() async {
    final camCtrl = _cameraController;
    if (camCtrl == null || !camCtrl.value.isInitialized || _isCapturingPhoto) {
      return;
    }

    setState(() {
      _isCapturingPhoto = true;
    });

    try {
      final XFile capturedFile = await camCtrl.takePicture();
      final bytes = await capturedFile.readAsBytes();
      final capturedName = capturedFile.name.isNotEmpty
          ? capturedFile.name
          : 'camera_capture_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _disposeCameraController();

      if (!mounted) return;
      setState(() {
        _isCameraActive = false;
        _isCapturingPhoto = false;
        _cameraError = null;
      });

      await widget.controller.analyzeUploadedOrCapturedFood(
        imageBytes: bytes,
        fileName: capturedName,
        fromCamera: true,
      );

      final meal = widget.controller.currentScannedMeal;
      widget.onShowToast(
        'Đã chụp & Tính Calo',
        'Nhận diện "${meal.name}" (${meal.kcal} kcal).',
        BentoColors.mintEmerald,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isCapturingPhoto = false;
      });
      widget.onShowToast(
        'Không thể chụp ảnh',
        error.toString(),
        BentoColors.danger,
      );
    }
  }

  Future<void> _handleCloseCamera() async {
    await _disposeCameraController();
    if (!mounted) return;
    setState(() {
      _isCameraActive = false;
      _cameraError = null;
    });
  }

  Widget _buildViewportStage(FoodSample meal) {
    final camCtrl = _cameraController;

    if (_isStartingCamera) {
      return Container(
        color: const Color(0xFF0F172A),
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text(
              'Đang khởi tạo ống kính Camera AI...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_cameraError != null) {
      return Container(
        color: const Color(0xFF0F172A),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 70),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_outlined,
                color: BentoColors.warmCoral,
                size: 30,
              ),
              const SizedBox(height: 6),
              const Text(
                'Chưa truy cập được Camera trực tiếp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _cameraError.toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _handleOpenCamera,
                icon: const Icon(Icons.refresh_rounded, size: 15),
                label: const Text(
                  'Thử cấp quyền lại',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: BentoColors.mintEmerald,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isCameraActive && camCtrl != null && camCtrl.value.isInitialized) {
      return Container(
        color: const Color(0xFF0F172A),
        width: double.infinity,
        height: double.infinity,
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: camCtrl.value.previewSize?.height ?? 640,
            height: camCtrl.value.previewSize?.width ?? 480,
            child: CameraPreview(camCtrl),
          ),
        ),
      );
    }

    if (meal.customImageBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: const Color(0xFF0F172A)),
          Opacity(
            opacity: 0.85,
            child: Image.memory(
              meal.customImageBytes!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
        ],
      );
    }

    if (meal.assetImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: const Color(0xFF0F172A)),
          Opacity(
            opacity: 0.82,
            child: Image.asset(
              meal.assetImage!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDarkViewfinderBackdrop();
              },
            ),
          ),
        ],
      );
    }

    return _buildDarkViewfinderBackdrop();
  }

  Widget _buildDarkViewfinderBackdrop() {
    return Container(
      color: const Color(0xFF0F172A),
      alignment: Alignment.center,
      child: const Icon(
        Icons.center_focus_weak_rounded,
        size: 56,
        color: Color(0xFF334155),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final meal = ctrl.currentScannedMeal;
    final totalKcal = ctrl.totalCaloriesToday;
    final latestBmi = ctrl.bmiEvaluation.bmi.toStringAsFixed(1);

    final proteinG =
        (int.tryParse(meal.protein.replaceAll(RegExp(r'[^0-9]'), '')) ?? 25)
            .clamp(0, 100);
    final carbsG =
        (int.tryParse(meal.carbs.replaceAll(RegExp(r'[^0-9]'), '')) ?? 45)
            .clamp(0, 120);
    final fatG =
        (int.tryParse(meal.fat.replaceAll(RegExp(r'[^0-9]'), '')) ?? 15).clamp(
          0,
          70,
        );

    final sampleCards = [
      {
        'key': 'pho_bo',
        'title': 'Phở bò',
        'kcal': '478 kcal',
        'asset': 'assets/images/pho_bo.jpg',
        'icon': Icons.ramen_dining_rounded,
      },
      {
        'key': 'healthy_bowl',
        'title': 'Cơm gạo lứt',
        'kcal': '520 kcal',
        'asset': 'assets/images/healthy_bowl.jpg',
        'icon': Icons.rice_bowl_rounded,
      },
      {
        'key': 'banh_mi',
        'title': 'Bánh mì',
        'kcal': '441 kcal',
        'asset': 'assets/images/banh_mi.jpg',
        'icon': Icons.bakery_dining_rounded,
      },
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        // 1. Khu vực Camera Viewfinder (#0F172A) + 4 góc vuông trắng + Nút chụp viền kép + Thẻ món mẫu ngang
        BentoCard(
          padding: const EdgeInsets.all(18),
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
                        'CN 08 • AI CALO SCANNER (ATWATER 4P+4C+9F)',
                        style: BentoTextStyles.subCaption(
                          color: BentoColors.deepForest,
                        ),
                      ),
                      Text(
                        'VISION AI',
                        style: BentoTextStyles.subCaption(
                          color: BentoColors.mintEmerald,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ống kính AI Nutrition Scanner',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: BentoColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Đưa món ăn vào khung định vị hoặc chọn mẫu bên dưới',
                          style: TextStyle(
                            fontSize: 12,
                            color: BentoColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _showApiKeyInput = !_showApiKeyInput);
                    },
                    icon: Icon(
                      Icons.key_rounded,
                      size: 19,
                      color: ctrl.hasGeminiApiKey
                          ? BentoColors.mintEmerald
                          : BentoColors.textSecondary,
                    ),
                    tooltip: 'Cấu hình Gemini Vision API Key',
                  ),
                ],
              ),

              if (_showApiKeyInput) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BentoColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: BentoColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _apiKeyCtrl,
                          obscureText: true,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Gemini API Key (AIzaSy... / AQ...)',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: BentoColors.border,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          ctrl.setGeminiApiKey(_apiKeyCtrl.text);
                          setState(() => _showApiKeyInput = false);
                          widget.onShowToast(
                            'Đã lưu API Key',
                            'Đã cập nhật khóa Gemini Vision API.',
                            BentoColors.mintEmerald,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: BentoColors.deepForest,
                        ),
                        child: const Text('Lưu'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Dark Viewfinder (#0F172A) with 4 White Square Corners & Double-Ring Shutter Button
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  height: 268,
                  width: double.infinity,
                  color: const Color(0xFF0F172A),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildViewportStage(meal),

                      // Dark subtle vignette
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF0F172A).withValues(alpha: 0.45),
                              Colors.transparent,
                              const Color(0xFF0F172A).withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),

                      // Top Viewfinder Status Pill
                      Positioned(
                        top: 14,
                        left: 14,
                        right: 14,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0F172A,
                                ).withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.16),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: _isCameraActive
                                          ? BentoColors.warmCoral
                                          : BentoColors.mintEmerald,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isCameraActive
                                        ? 'LIVE VIEWFINDER'
                                        : 'AI READY • ${meal.confidence}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isCameraActive)
                              IconButton(
                                onPressed: _handleCloseCamera,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  foregroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.close_rounded, size: 16),
                              ),
                          ],
                        ),
                      ),

                      // 4 White Corner Brackets Defining Scan Area
                      Positioned(
                        left: 28,
                        right: 28,
                        top: 48,
                        bottom: 78,
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _WhiteViewfinderCornersPainter(),
                          ),
                        ),
                      ),

                      // Laser Scan Line inside Viewfinder
                      AnimatedBuilder(
                        animation: _ensureLaserController(),
                        builder: (context, child) {
                          final topPos =
                              52.0 + (_ensureLaserController().value * 130.0);
                          return Positioned(
                            left: 34,
                            right: 34,
                            top: topPos,
                            child: IgnorePointer(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: BentoColors.mintEmerald,
                                      blurRadius: 10,
                                      spreadRadius: 1.5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Scanning Overlay
                      if (ctrl.isScanningFood || _isCapturingPhoto)
                        Container(
                          color: const Color(
                            0xFF0F172A,
                          ).withValues(alpha: 0.72),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Đang bóc tách khẩu phần & tính Atwater...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Bottom Camera Control Bar with Double-Ring Circular Shutter Button
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Left: Upload from Gallery
                            _buildViewfinderSideButton(
                              icon: Icons.photo_library_outlined,
                              label: 'Thư viện',
                              onTap: _handleUploadImage,
                            ),

                            // Center: Double-Ring Circular Shutter Button
                            GestureDetector(
                              onTap: (_isStartingCamera || _isCapturingPhoto)
                                  ? null
                                  : _handleShutterButtonPressed,
                              child: Container(
                                width: 62,
                                height: 62,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isCameraActive
                                        ? BentoColors.warmCoral
                                        : Colors.white,
                                  ),
                                  child: Icon(
                                    _isCameraActive
                                        ? Icons.camera_rounded
                                        : Icons.camera_alt_rounded,
                                    color: _isCameraActive
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),

                            // Right: JSON Atwater / Switch Mode
                            _buildViewfinderSideButton(
                              icon: Icons.data_object_rounded,
                              label: _showJsonDetail ? 'Ẩn JSON' : 'JSON AI',
                              onTap: () {
                                setState(
                                  () => _showJsonDetail = !_showJsonDetail,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Horizontal Sample Meal Cards with Thumbnails
              Text(
                'MÓN ĂN MẪU (CHẠM ĐỂ QUÉT NHANH)',
                style: BentoTextStyles.subCaption(),
              ),
              const SizedBox(height: 8),
              Row(
                children: sampleCards.map((item) {
                  final key = item['key'] as String;
                  final active =
                      !_isCameraActive && ctrl.selectedSampleMealKey == key;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: key == 'banh_mi' ? 0 : 8,
                      ),
                      child: InkWell(
                        onTap: () => _pickMeal(key),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: active
                                ? BentoColors.mintSoft
                                : BentoColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: active
                                  ? BentoColors.mintEmerald
                                  : BentoColors.border,
                              width: active ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Image.asset(
                                    item['asset'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) => Container(
                                      color: BentoColors.deepForest,
                                      child: Icon(
                                        item['icon'] as IconData,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: active
                                            ? BentoColors.deepForest
                                            : BentoColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      item['kcal'] as String,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: BentoColors.warmCoral,
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 2. Kết quả phân tích dinh dưỡng (Calo, Carbs, Protein, Fat kèm thanh progress nhỏ cho từng chất)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BentoColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BentoColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: BentoColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                meal.serving,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: BentoColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${meal.kcal}',
                              style: BentoTextStyles.statLarge(
                                fontSize: 28,
                                color: BentoColors.warmCoral,
                              ),
                            ),
                            Text(
                              'KCAL (ATWATER)',
                              style: BentoTextStyles.subCaption(
                                color: BentoColors.warmCoral,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 3 Macro Cards with Mini Progress Bars
                    Row(
                      children: [
                        Expanded(
                          child: _buildMacroProgressCard(
                            label: 'Tinh bột (Carbs)',
                            value: meal.carbs,
                            progress: (carbsG / 90.0).clamp(0.08, 1.0),
                            color: BentoColors.warmCoral,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMacroProgressCard(
                            label: 'Chất đạm (Protein)',
                            value: meal.protein,
                            progress: (proteinG / 60.0).clamp(0.08, 1.0),
                            color: BentoColors.skyBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMacroProgressCard(
                            label: 'Chất béo (Fat)',
                            value: meal.fat,
                            progress: (fatG / 40.0).clamp(0.08, 1.0),
                            color: BentoColors.mintEmerald,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: BentoColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.auto_awesome_outlined,
                            size: 16,
                            color: BentoColors.mintEmerald,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              meal.tip,
                              style: const TextStyle(
                                fontSize: 12,
                                color: BentoColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showJsonDetail) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SelectableText(
                          ctrl.lastRecognizedNutritionJson,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Color(0xFF6EE7B7),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          final added = ctrl.logCurrentScannedMeal();
                          widget.onShowToast(
                            'Đã ghi nhận bữa ăn',
                            'Đã cộng +${added.kcal} kcal từ "${added.name}".',
                            BentoColors.mintEmerald,
                          );
                        },
                        icon: const Icon(Icons.add_task_rounded, size: 18),
                        label: const Text('Lưu bữa ăn vào Nhật ký hôm nay'),
                        style: FilledButton.styleFrom(
                          backgroundColor: BentoColors.deepForest,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Ngay bên dưới: Thẻ "Smart Workout Roadmap" gợi ý bài tập đốt lượng calo tương ứng
        BentoCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SMART WORKOUT ROADMAP',
                    style: BentoTextStyles.subCaption(
                      color: BentoColors.warmCoral,
                    ),
                  ),
                  Text(
                    'ĐỐT ~${meal.kcal} KCAL',
                    style: BentoTextStyles.subCaption(
                      color: BentoColors.deepForest,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const BentoIconBadge(
                    icon: Icons.fitness_center_rounded,
                    color: BentoColors.warmCoral,
                    backgroundColor: BentoColors.coralSoft,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lộ trình tập luyện đối ứng Calo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: BentoColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Gợi ý bài tập để tiêu hao ${meal.kcal} kcal từ "${meal.name}" (BMI: $latestBmi)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: BentoColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BentoColors.coralSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: BentoColors.warmCoral.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: BentoColors.warmCoral,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tổng nạp trong ngày: $totalKcal / 2000 kcal • Chọn nhanh 1 bài tập bên dưới để cân bằng năng lượng.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: BentoColors.textPrimary,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    {'key': 'fatloss', 'label': 'Đốt mỡ nhanh (HIIT)'},
                    {'key': 'muscle', 'label': 'Tăng cơ (Strength)'},
                    {'key': 'endurance', 'label': 'Bền bỉ (Cardio)'},
                  ].map((g) {
                    final active = ctrl.selectedWorkoutGoal == g['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(g['label']!),
                        selected: active,
                        onSelected: (_) => ctrl.setWorkoutGoal(g['key']!),
                        selectedColor: BentoColors.deepForest,
                        backgroundColor: BentoColors.background,
                        side: BorderSide(
                          color: active
                              ? BentoColors.deepForest
                              : BentoColors.border,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? Colors.white
                              : BentoColors.textSecondary,
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              ...ctrl.currentWorkoutPlan.map(
                (w) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BentoColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: BentoColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${w.day} • Mức độ ${w.level}',
                              style: BentoTextStyles.subCaption(
                                color: BentoColors.deepForest,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              w.title,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: BentoColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Thời lượng: ${w.duration} • Đốt ~${w.kcal} kcal',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: BentoColors.textSecondary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          final created = ctrl.applyWorkoutToHabit(w);
                          widget.onShowToast(
                            'Đã thêm vào Thói quen',
                            'Đã tạo lịch "${created.title}" vào danh sách.',
                            BentoColors.mintEmerald,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: BentoColors.mintSoft,
                          foregroundColor: BentoColors.deepForest,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text(
                          '+ Áp dụng',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

  Widget _buildViewfinderSideButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroProgressCard({
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BentoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: BentoColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: BentoTextStyles.statMedium(fontSize: 16, color: color),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteViewfinderCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const len = 24.0;
    // Top-left corner
    canvas.drawLine(const Offset(0, 0), const Offset(len, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, len), paint);

    // Top-right corner
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - len, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, len),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(0, size.height),
      Offset(len, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - len),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - len, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
