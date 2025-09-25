import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiResult {
  final Uint8List bytes;
  final String? styleName;

  GeminiResult(this.bytes, this.styleName);
}

class GeminiService {
  final String apiKey;
  GeminiService(this.apiKey);

  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent';

  Future<GeminiResult> generateAiRecommendation({
    required File imageFile,
  }) async {
    final String base64Data = base64Encode(await imageFile.readAsBytes());

    final request = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': _aiPrompt},
            {
              'inlineData': {
                'mimeType': 'image/${_mimeFromPath(imageFile.path)}',
                'data': base64Data,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'topK': 5,
        'topP': 0.3,
        'maxOutputTokens': 1024,
        'candidateCount': 1,
      },
      'safetySettings': [
        {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_NONE'},
        {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_NONE'},
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_NONE',
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_NONE',
        },
      ],
    };

    _ensureApiKey();
    final uri = Uri.parse('$_endpoint?key=$apiKey');
    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(request),
        )
        .timeout(const Duration(minutes: 2));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Gemini API error: ${res.statusCode}');
    }

    return _parseResponse(res.body);
  }

  Future<GeminiResult> editWithPrompt({
    required File imageFile,
    required String prompt,
  }) async {
    final String base64Data = base64Encode(await imageFile.readAsBytes());

    // Strengthen instructions so the model always returns an edited image inline
    final String composedPrompt =
        """
Apply the following hairstyle to the person in the provided image. Keep the person's face, expression, skin, pose, and all non-hair details completely unchanged. Start your response with the exact style name followed by a colon on the first line, then include exactly one edited image as inline data (do not provide links or file references).

Hairstyle to apply:
$prompt
""".trim();

    final request = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': composedPrompt},
            {
              'inlineData': {
                'mimeType': 'image/${_mimeFromPath(imageFile.path)}',
                'data': base64Data,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'topK': 5,
        'topP': 0.3,
        'maxOutputTokens': 1024,
        'candidateCount': 1,
      },
      'safetySettings': [
        {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_NONE'},
        {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_NONE'},
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_NONE',
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_NONE',
        },
      ],
    };

    _ensureApiKey();
    final uri = Uri.parse('$_endpoint?key=$apiKey');
    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(request),
        )
        .timeout(const Duration(minutes: 2));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Gemini API error: ${res.statusCode}');
    }

    return _parseResponse(res.body);
  }

  void _ensureApiKey() {
    if (apiKey.isEmpty) {
      throw StateError(
          'GEMINI_API_KEY is missing. Set it in .env and ensure it is bundled as an asset.');
    }
  }

  GeminiResult _parseResponse(String bodyStr) {
    final dynamic body = jsonDecode(bodyStr);
    if (body is Map && body['error'] != null) {
      final err = body['error'];
      final msg = err is Map && err['message'] is String
          ? err['message']
          : 'Unknown API error';
      throw Exception('Gemini API error: $msg');
    }
    final candidates = body['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No candidates in response');
    }
    final content = candidates.first['content'];
    final parts = (content['parts'] as List?) ?? const [];

    String? styleName;
    Uint8List? imageBytes;

    for (final p in parts) {
      if (p['text'] is String) {
        final String text = p['text'];
        final firstLine = text.split('\n').first.trim();
        if (firstLine.contains(':')) {
          styleName = firstLine.split(':').first.trim();
        }
      }
      // Handle possible variations in response keys
      final inline =
          p['inlineData'] ??
          p['inline_data'] ??
          p['fileData'] ??
          p['file_data'];
      if (inline is Map) {
        final mime = inline['mimeType'] ?? inline['mime_type'];
        if (mime is String && mime.startsWith('image/')) {
          final data =
              inline['data'] ?? inline['bytesBase64'] ?? inline['bytes_base64'];
          if (data is String && data.isNotEmpty) {
            imageBytes = Uint8List.fromList(base64Decode(data));
          }
          // Some responses may return fileUri/fileId instead of inline bytes; unsupported here
        }
      }
    }

    if (imageBytes == null) {
      throw Exception('No image in response');
    }
    return GeminiResult(imageBytes, styleName);
  }

  String _mimeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'jpeg';
    if (lower.endsWith('.webp')) return 'webp';
    return 'jpeg';
  }

  static const String _aiPrompt =
      'Analyze this person\'s image and apply the BEST SUITED hairstyle from the provided options. Start your response with the chosen style name followed by a colon, then include the styled image. Keep face unchanged.';
}
