import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/conversation.dart';

class ConversationService {
  final http.Client _client = http.Client();

  Future<List<ConversationModel>> getConversations() async {
    final response = await _client
        .get(Uri.parse(ApiConstants.conversationsEndpoint))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => ConversationModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<ConversationModel> createConversation(String title) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.conversationsEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );
    if (response.statusCode == 200) {
      return ConversationModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create conversation');
  }

  Future<void> deleteConversation(String uuid) async {
    await _client.delete(Uri.parse('${ApiConstants.conversationsEndpoint}/$uuid'));
  }
}
