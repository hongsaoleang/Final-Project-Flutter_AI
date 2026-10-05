class ApiConstants {
  // Default base URL for local development (change to device IP if testing on physical mobile)
  static String baseUrl = 'http://localhost:8080/api/v1';

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
