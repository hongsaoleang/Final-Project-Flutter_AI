import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/chat_message.dart';

class AiService {
  final http.Client _client = http.Client();

  Future<String> sendMultimodalPrompt({
    required AiMode mode,
    required String prompt,
    String? conversationId,
    String? imageData,
  }) async {
    final endpoint = switch (mode) {
      AiMode.textGeneration => ApiConstants.textGenEndpoint,
      AiMode.textToImage => ApiConstants.textToImageEndpoint,
      AiMode.imageToText => ApiConstants.imageToTextEndpoint,
      AiMode.ocr => ApiConstants.ocrEndpoint,
      AiMode.imageUnderstanding => ApiConstants.imageUnderstandingEndpoint,
    };

    final Map<String, dynamic> payload = {
      'conversationId': conversationId ?? 'conv-default',
      'prompt': prompt,
    };
    if (imageData != null) {
      payload['imageData'] = imageData;
    }

    final response = await _client.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] ?? 'No response content';
    } else {
      throw Exception('Server returned error ${response.statusCode}: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> uploadFile({
    required String filename,
    required List<int> bytes,
  }) async {
    final uri = Uri.parse(ApiConstants.uploadEndpoint);
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ),
    );
    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('File upload failed: status ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> checkHealth() async {
    final response = await _client
        .get(Uri.parse(ApiConstants.healthEndpoint))
        .timeout(const Duration(seconds: 4));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Backend health check returned ${response.statusCode}');
  }
}
