// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:camera_web/camera_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';

class PickedFoodImage {
  final Uint8List bytes;
  final String fileName;

  const PickedFoodImage({
    required this.bytes,
    required this.fileName,
  });
}

bool _webPluginsRegistered = false;

void ensureWebPluginsRegistered() {
  if (_webPluginsRegistered) return;
  try {
    final Registrar registrar = webPluginRegistrar;
    CameraPlugin.registerWith(registrar);
    ImagePickerPlugin.registerWith(registrar);
    registrar.registerMessageHandler();
    _webPluginsRegistered = true;
  } catch (_) {}
}

Future<PickedFoodImage?> pickFoodImageFromFile() async {
  final completer = Completer<PickedFoodImage?>();
  final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
  uploadInput.click();

  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }
    final file = files.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result is Uint8List) {
        if (!completer.isCompleted) {
          completer.complete(
            PickedFoodImage(bytes: result, fileName: file.name),
          );
        }
      } else if (result is ByteBuffer) {
        if (!completer.isCompleted) {
          completer.complete(
            PickedFoodImage(
              bytes: Uint8List.view(result),
              fileName: file.name,
            ),
          );
        }
      } else {
        if (!completer.isCompleted) completer.complete(null);
      }
    });
    reader.onError.listen((_) {
      if (!completer.isCompleted) completer.complete(null);
    });
  });

  return completer.future;
}

String detectImageMimeType(Uint8List bytes) {
  if (bytes.length >= 4) {
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      return 'image/webp';
    }
  }
  return 'image/jpeg';
}

Future<String?> postGeminiVisionRequest({
  required String apiKey,
  required String base64Image,
  required String mimeType,
  required String systemPrompt,
}) async {
  final cleanKey = apiKey.trim();
  final isVertexKey = cleanKey.startsWith('AQ.');
  final models = ['gemini-2.0-flash', 'gemini-2.5-flash', 'gemini-1.5-flash'];

  final urls = <String>[
    if (isVertexKey) ...[
      for (final m in models)
        'https://aiplatform.googleapis.com/v1/publishers/google/models/$m:generateContent?key=$cleanKey',
      for (final m in models)
        'https://aiplatform.googleapis.com/v1beta1/publishers/google/models/$m:generateContent?key=$cleanKey',
      for (final m in models)
        'https://generativelanguage.googleapis.com/v1beta/models/$m:generateContent?key=$cleanKey',
    ] else ...[
      for (final m in models)
        'https://generativelanguage.googleapis.com/v1beta/models/$m:generateContent?key=$cleanKey',
      for (final m in models)
        'https://aiplatform.googleapis.com/v1/publishers/google/models/$m:generateContent?key=$cleanKey',
    ],
  ];

  final payload = jsonEncode({
    'contents': [
      {
        'role': 'user',
        'parts': [
          {'text': systemPrompt},
          {
            'inlineData': {
              'mimeType': mimeType,
              'data': base64Image,
            },
          },
        ],
      },
    ],
    'generationConfig': {
      'temperature': 0.1,
    },
  });

  for (final url in urls) {
    try {
      final req = await html.HttpRequest.request(
        url,
        method: 'POST',
        requestHeaders: {'Content-Type': 'application/json'},
        sendData: payload,
      );
      if (req.status == 200 &&
          req.responseText != null &&
          req.responseText!.contains('candidates')) {
        return req.responseText;
      }
    } catch (_) {}
  }
  return null;
}
