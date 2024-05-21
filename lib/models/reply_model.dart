// ignore_for_file: public_member_api_docs, sort_constructors_first

class Reply {
  final String id;
  final String text;
  final DateTime createdAt;
  final String commentId;
  final String username;
  final String profilePic;
  Reply({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.commentId,
    required this.username,
    required this.profilePic,
  });
  

  Reply copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? commentId,
    String? username,
    String? profilePic,
  }) {
    return Reply(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      commentId: commentId ?? this.commentId,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'commentId': commentId,
      'username': username,
      'profilePic': profilePic,
    };
  }

  factory Reply.fromMap(Map<String, dynamic> map) {
    return Reply(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      commentId: map['commentId'] ?? '',
      username: map['username'] ?? '',
      profilePic: map['profilePic'] ?? '',
    );
  }

  // String toJson() => json.encode(toMap());

  // factory Reply.fromJson(String source) => Reply.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Reply(id: $id, text: $text, createdAt: $createdAt, commentId: $commentId, username: $username, profilePic: $profilePic)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Reply &&
      other.id == id &&
      other.text == text &&
      other.createdAt == createdAt &&
      other.commentId == commentId &&
      other.username == username &&
      other.profilePic == profilePic;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      text.hashCode ^
      createdAt.hashCode ^
      commentId.hashCode ^
      username.hashCode ^
      profilePic.hashCode;
  }
}
