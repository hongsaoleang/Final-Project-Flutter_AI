import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController(text: ApiConstants.baseUrl);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Backend & Infrastructure Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryLight)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Spring Boot REST API URL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.backgroundDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check, color: Colors.greenAccent),
                    onPressed: () {
                      setState(() {
                        ApiConstants.baseUrl = _urlController.text.trim();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('API URL set to: ${ApiConstants.baseUrl}')),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Connected Database: PostgreSQL 16 (myai_db, user: user)', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const Text('Python AI Engine: FastAPI (localhost:8000, PyTorch 2.14)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('About MyAI Multimodal Platform', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryLight)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderDark),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MyAI v0.2.0 (From Scratch Learning Project)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('Modular architecture combining Flutter Frontend, Java Spring Boot Backend, and Python/PyTorch Deep Learning engine.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
