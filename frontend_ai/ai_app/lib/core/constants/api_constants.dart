import 'package:flutter/foundation.dart';

class ApiConstants {
  // Point directly to your live Render Spring Boot backend in production,
  // with fallbacks for local development if needed.
  static String get defaultHost {
    // If you are building a release APK for production use:
    return 'der-leng-spring-backend-ai.onrender.com';

    // (Optional: If you want to keep dynamic local/remote switching,
    // you can replace the return above with your previous platform check,
    // but default it to your Render domain for release builds).
  }

  static final ValueNotifier<String> serverHostNotifier = ValueNotifier<String>(
    defaultHost,
  );

  static String get serverHost => serverHostNotifier.value;
  static set serverHost(String host) {
    serverHostNotifier.value = host.trim().isEmpty ? defaultHost : host.trim();
  }

  // Use https:// and remove :8080 for Render cloud hosting
  static String get baseUrl => 'https://${serverHostNotifier.value}/api/v1';

  // Google Maps Platform API Key
  static const String googleMapsApiKey =
      'AIzaSyBQ8fT204M9HYh3DcMJ99l0QP3wMAvFiuI';

  static String get healthEndpoint => '$baseUrl/ai/health';
  static String get textGenEndpoint => '$baseUrl/ai/generate-text';
  static String get textToImageEndpoint => '$baseUrl/ai/text-to-image';
  static String get imageToTextEndpoint => '$baseUrl/ai/image-to-text';
  static String get ocrEndpoint => '$baseUrl/ai/ocr';
  static String get imageUnderstandingEndpoint =>
      '$baseUrl/ai/image-understanding';
  static String get historyEndpoint => '$baseUrl/ai/history';

  // Training endpoints
  static String get trainEndpoint => '$baseUrl/ai/train';
  static String trainStatusEndpoint(String jobId) =>
      '$baseUrl/ai/train/status/$jobId';
  static String get trainJobsEndpoint => '$baseUrl/ai/train/jobs';
  static String get inferTrainedEndpoint => '$baseUrl/ai/infer-trained';

  // Conversation endpoints
  static String get conversationsEndpoint => '$baseUrl/conversations';
  static String conversationMessagesEndpoint(String uuid) =>
      '$baseUrl/conversations/$uuid/messages';

  // File upload endpoints
  static String get uploadEndpoint => '$baseUrl/files/upload';
}
