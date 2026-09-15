class TrainingJobModel {
  final String jobId;
  final String modelName;
  final String modelType;
  final String status;
  final int currentEpoch;
  final int totalEpochs;
  final double? currentLoss;
  final double? accuracy;
  final List<double> lossHistory;
  final String? checkpointPath;

  TrainingJobModel({
    required this.jobId,
    required this.modelName,
    required this.modelType,
    required this.status,
    required this.currentEpoch,
    required this.totalEpochs,
    this.currentLoss,
    this.accuracy,
    required this.lossHistory,
    this.checkpointPath,
  });

  factory TrainingJobModel.fromJson(Map<String, dynamic> json) {
    final historyList = (json['lossHistory'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [];

    return TrainingJobModel(
      jobId: json['jobId'] ?? '',
      modelName: json['modelName'] ?? 'Unnamed',
      modelType: json['modelType'] ?? 'neural_network',
      status: json['status'] ?? 'QUEUED',
      currentEpoch: json['currentEpoch'] ?? 0,
      totalEpochs: json['totalEpochs'] ?? 20,
      currentLoss: json['currentLoss']?.toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      lossHistory: historyList,
      checkpointPath: json['checkpointPath'],
    );
  }

  bool get isCompleted => status == 'COMPLETED';
  bool get isTraining => status == 'TRAINING';
}
