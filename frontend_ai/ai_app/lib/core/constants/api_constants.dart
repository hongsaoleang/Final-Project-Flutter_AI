import 'package:flutter/foundation.dart';

class ApiConstants {
  // Computes default host based on platform:
  // - Web: Uri.base.host or 'localhost'
  // - Android (Emulator): '10.0.2.2'
  // - Desktop (Windows/macOS/Linux): 'localhost'
  static String get defaultHost {
    if (kIsWeb) {
      final webHost = Uri.base.host;
      if (webHost.isNotEmpty && webHost != 'localhost' && webHost != '127.0.0.1') {
        return webHost;
      }
      return 'localhost';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '10.0.2.2'; // Standard Android loopback to host PC
      case TargetPlatform.iOS:
        return '127.0.0.1'; // Standard iOS simulator loopback
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      default:
        return 'localhost';
    }
  }

  // Active host notifier allows real-time switching from Settings on any device
  static final ValueNotifier<String> serverHostNotifier = ValueNotifier<String>(defaultHost);

  static String get serverHost => serverHostNotifier.value;
  static set serverHost(String host) {
    serverHostNotifier.value = host.trim().isEmpty ? defaultHost : host.trim();
  }

  static String get baseUrl => 'http://${serverHostNotifier.value}:8080/api/v1';

  // Google Maps Platform API Key
  static const String googleMapsApiKey = 'AIzaSyBQ8fT204M9HYh3DcMJ99l0QP3wMAvFiuI';

  static String get healthEndpoint => '$baseUrl/ai/health';
  static String get textGenEndpoint => '$baseUrl/ai/generate-text';
  static String get textToImageEndpoint => '$baseUrl/ai/text-to-image';
  static String get imageToTextEndpoint => '$baseUrl/ai/image-to-text';
  static String get ocrEndpoint => '$baseUrl/ai/ocr';
  static String get imageUnderstandingEndpoint => '$baseUrl/ai/image-understanding';
  static String get historyEndpoint => '$baseUrl/ai/history';

  // Training endpoints
  static String get trainEndpoint => '$baseUrl/ai/train';
  static String trainStatusEndpoint(String jobId) => '$baseUrl/ai/train/status/$jobId';
  static String get trainJobsEndpoint => '$baseUrl/ai/train/jobs';
  static String get inferTrainedEndpoint => '$baseUrl/ai/infer-trained';

  // Conversation endpoints
  static String get conversationsEndpoint => '$baseUrl/conversations';
  static String conversationMessagesEndpoint(String uuid) => '$baseUrl/conversations/$uuid/messages';

  // File upload endpoints
  static String get uploadEndpoint => '$baseUrl/files/upload';
}
