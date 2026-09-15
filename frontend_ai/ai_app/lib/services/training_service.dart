import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/training_job.dart';

class TrainingService {
  final http.Client _client = http.Client();

  Future<TrainingJobModel> startTraining({
    required String modelType,
    required int epochs,
    required double learningRate,
    String? dataset,
  }) async {
    final Map<String, dynamic> payload = {
      'modelName': 'MyAI-$modelType',
      'modelType': modelType,
      'epochs': epochs,
      'learningRate': learningRate,
    };
    if (dataset != null) {
      payload['dataset'] = dataset;
    }

    final response = await _client.post(
      Uri.parse(ApiConstants.trainEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return TrainingJobModel.fromJson(data);
    }
    throw Exception('Failed to start training: ${response.statusCode}');
  }

  Future<TrainingJobModel> getStatus(String jobId) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.trainStatusEndpoint(jobId)),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return TrainingJobModel.fromJson(data);
    }
    throw Exception('Failed to fetch job status: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> inferTrained({
    required String modelType,
    String? prompt,
    List<double>? features,
  }) async {
    final Map<String, dynamic> payload = {
      'model_type': modelType,
    };
    if (prompt != null) {
      payload['prompt'] = prompt;
    }
    if (features != null) {
      payload['input_features'] = {'features': features};
    }

    final response = await _client.post(
      Uri.parse(ApiConstants.inferTrainedEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Inference failed: ${response.statusCode}');
  }
}
