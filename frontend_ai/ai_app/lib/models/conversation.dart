class ConversationModel {
  final int id;
  final String uuid;
  final String title;
  final DateTime createdAt;

  ConversationModel({
    required this.id,
    required this.uuid,
    required this.title,
    required this.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? 0,
      uuid: json['conversationUuid'] ?? '',
      title: json['title'] ?? 'Untitled Conversation',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
