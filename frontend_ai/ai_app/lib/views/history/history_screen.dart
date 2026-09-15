import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _chatHistory = [];
  List<dynamic> _trainingJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final chatRes = await http.get(Uri.parse(ApiConstants.historyEndpoint));
      if (chatRes.statusCode == 200) {
        _chatHistory = jsonDecode(chatRes.body);
      }

      final trainRes = await http.get(Uri.parse(ApiConstants.trainJobsEndpoint));
      if (trainRes.statusCode == 200) {
        _trainingJobs = jsonDecode(trainRes.body);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: 'AI Interactions'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Training Runs'),
          ],
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInteractionList(),
                    _buildTrainingList(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildInteractionList() {
    if (_chatHistory.isEmpty) {
      return const Center(child: Text('No interaction history found in PostgreSQL database.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _chatHistory.length,
      itemBuilder: (context, idx) {
        final item = _chatHistory[idx];
        return Card(
          color: AppTheme.cardDark,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              child: const Icon(Icons.smart_toy, color: AppTheme.primaryLight, size: 20),
            ),
            title: Text(item['prompt'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text(
              item['response'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Chip(
              label: Text(item['type'] ?? '', style: const TextStyle(fontSize: 10)),
              backgroundColor: const Color(0xFF334155),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrainingList() {
    if (_trainingJobs.isEmpty) {
      return const Center(child: Text('No model training history recorded in PostgreSQL yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trainingJobs.length,
      itemBuilder: (context, idx) {
        final job = _trainingJobs[idx];
        return Card(
          color: AppTheme.cardDark,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withValues(alpha: 0.2),
              child: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
            ),
            title: Text(job['modelName'] ?? 'Unnamed', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(
              'Type: ${job['modelType']} • Epochs: ${job['currentEpoch']}/${job['epochs']} • Loss: ${job['finalLoss'] ?? '--'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Text(
              job['status'] ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: job['status'] == 'COMPLETED' ? Colors.greenAccent : Colors.amberAccent,
              ),
            ),
          ),
        );
      },
    );
  }
}
