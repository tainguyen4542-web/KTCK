import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class PickedFoodImage {
  final Uint8List bytes;
  final String fileName;

  const PickedFoodImage({
    required this.bytes,
    required this.fileName,
  });
}

void ensureWebPluginsRegistered() {}

Future<PickedFoodImage?> pickFoodImageFromFile() async {
  return null;
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

  final client = HttpClient();
  try {
    for (final url in urls) {
      try {
        final uri = Uri.parse(url);
        final req = await client.postUrl(uri);
        req.headers.set('Content-Type', 'application/json; charset=utf-8');
        req.add(utf8.encode(payload));
        final resp = await req.close();
        final body = await resp.transform(utf8.decoder).join();
        if (resp.statusCode == 200 && body.contains('candidates')) {
          return body;
        }
      } catch (_) {}
    }
  } finally {
    client.close();
  }
  return null;
}
