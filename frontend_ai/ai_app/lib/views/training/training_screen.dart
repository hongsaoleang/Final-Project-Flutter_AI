import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/training_service.dart';
import 'widgets/loss_sparkline.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final TrainingService _trainingService = TrainingService();
  String _selectedModelType = 'neural_network';
  int _epochs = 20;
  double _learningRate = 0.05;

  bool _isTraining = false;
  String? _activeJobId;
  int _currentEpoch = 0;
  double? _currentLoss;
  double? _accuracy;
  List<double> _lossHistory = [];
  String _statusText = 'Ready to train model';
  Timer? _pollingTimer;

  final TextEditingController _promptController = TextEditingController(text: 'Neural networks learn');
  String _inferenceResult = '';
  bool _isInferenceRunning = false;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _startTraining() async {
    setState(() {
      _isTraining = true;
      _currentEpoch = 0;
      _lossHistory.clear();
      _currentLoss = null;
      _accuracy = null;
      _statusText = 'Initializing training run on Python AI engine...';
      _inferenceResult = '';
    });

    try {
      final job = await _trainingService.startTraining(
        modelType: _selectedModelType,
        epochs: _epochs,
        learningRate: _learningRate,
      );
      _activeJobId = job.jobId;
      _pollStatus();
    } catch (e) {
      setState(() {
        _isTraining = false;
        _statusText = 'Error starting training: $e';
      });
    }
  }

  void _pollStatus() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) async {
      if (_activeJobId == null) {
        timer.cancel();
        return;
      }
      try {
        final job = await _trainingService.getStatus(_activeJobId!);
        setState(() {
          _currentEpoch = job.currentEpoch;
          _currentLoss = job.currentLoss;
          _accuracy = job.accuracy;
          _lossHistory = job.lossHistory;
          _statusText = 'Status: ${job.status} (Epoch ${job.currentEpoch} / $_epochs)';
        });

        if (job.isCompleted || job.status == 'FAILED') {
          timer.cancel();
          setState(() {
            _isTraining = false;
            _statusText = job.isCompleted
                ? 'Training COMPLETED! Checkpoint saved to PostgreSQL.'
                : 'Training failed.';
          });
        }
      } catch (_) {}
    });
  }

  Future<void> _testTrainedModel() async {
    setState(() {
      _isInferenceRunning = true;
      _inferenceResult = '';
    });

    try {
      final res = await _trainingService.inferTrained(
        modelType: _selectedModelType,
        prompt: _selectedModelType == 'tiny_llm' ? _promptController.text : null,
        features: _selectedModelType == 'neural_network' ? [1.5, 0.8, -0.2, 0.4] : null,
      );
      setState(() {
        _inferenceResult = '${res['output']}\n(Model: ${res['model_used']})';
      });
    } catch (e) {
      setState(() {
        _inferenceResult = 'Inference failed: $e';
      });
    } finally {
      setState(() => _isInferenceRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.hub, color: AppTheme.primaryLight, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Training & Fine-Tuning Studio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Train PyTorch & NumPy neural architectures from scratch and persist to PostgreSQL.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Hyperparameters Section
          const Text('1. Architecture & Hyperparameters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryLight)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Model Architecture:', style: TextStyle(fontSize: 13)),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _selectedModelType,
                      dropdownColor: AppTheme.cardDark,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'neural_network', child: Text('Neural Network (MLP Classifier)')),
                        DropdownMenuItem(value: 'tiny_llm', child: Text('Tiny Language Model (Transformer)')),
                      ],
                      onChanged: _isTraining ? null : (val) {
                        if (val != null) setState(() => _selectedModelType = val);
                      },
                    ),
                  ],
                ),
                const Divider(color: AppTheme.borderDark),
                Row(
                  children: [
                    Text('Training Epochs: $_epochs', style: const TextStyle(fontSize: 13)),
                    Expanded(
                      child: Slider(
                        value: _epochs.toDouble(),
                        min: 5,
                        max: 50,
                        divisions: 9,
                        activeColor: AppTheme.primaryColor,
                        onChanged: _isTraining ? null : (val) => setState(() => _epochs = val.toInt()),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Learning Rate: $_learningRate', style: const TextStyle(fontSize: 13)),
                    Expanded(
                      child: Slider(
                        value: _learningRate,
                        min: 0.01,
                        max: 0.1,
                        divisions: 9,
                        activeColor: AppTheme.primaryColor,
                        onChanged: _isTraining ? null : (val) => setState(() => _learningRate = double.parse(val.toStringAsFixed(2))),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isTraining
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.play_arrow, color: Colors.white),
                    label: Text(_isTraining ? 'Training in Progress...' : 'Start Model Training', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: _isTraining ? null : _startTraining,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Live Metrics Card
          const Text('2. Live Training Metrics', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryLight)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_statusText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _epochs > 0 ? (_currentEpoch / _epochs) : 0,
                  backgroundColor: AppTheme.borderDark,
                  color: AppTheme.primaryColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetric('Epoch', '$_currentEpoch / $_epochs'),
                    _buildMetric('Loss', _currentLoss != null ? _currentLoss!.toStringAsFixed(4) : '--'),
                    _buildMetric('Accuracy', _accuracy != null ? '$_accuracy%' : '--'),
                  ],
                ),
                const SizedBox(height: 16),
                LossSparkline(lossHistory: _lossHistory),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Test Trained Model Section
          const Text('3. Test Trained Model Inference', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryLight)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedModelType == 'tiny_llm') ...[
                  TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      labelText: 'Prompt for Trained Transformer',
                      filled: true,
                      fillColor: AppTheme.backgroundDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ] else ...[
                  const Text('Test Feature Vector: [1.5, 0.8, -0.2, 0.4]', style: TextStyle(fontSize: 13, color: Colors.white70)),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryLight,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isInferenceRunning
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.flash_on),
                    label: Text(_isInferenceRunning ? 'Evaluating...' : 'Run Inference on Trained Weights'),
                    onPressed: _isInferenceRunning ? null : _testTrainedModel,
                  ),
                ),
                if (_inferenceResult.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Text(_inferenceResult, style: const TextStyle(fontSize: 13, color: Colors.greenAccent)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}
