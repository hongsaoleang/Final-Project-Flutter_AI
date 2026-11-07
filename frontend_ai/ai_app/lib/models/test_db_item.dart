class TestDbItem {
  final int? id;
  final String username;
  final String major;

  TestDbItem({
    this.id,
    required this.username,
    required this.major,
  });

  factory TestDbItem.fromJson(Map<String, dynamic> json) {
    return TestDbItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      username: json['username'] ?? '',
      major: json['major'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'major': major,
    };
  }
}
