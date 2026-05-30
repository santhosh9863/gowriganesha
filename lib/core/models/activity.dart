import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String festivalId;
  final String type;
  final String title;
  final String description;
  final Timestamp createdAt;

  const Activity({
    required this.id,
    required this.festivalId,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'festivalId': festivalId,
      'type': type,
      'title': title,
      'description': description,
      'createdAt': createdAt,
    };
  }

  factory Activity.fromMap(String id, Map<String, dynamic> map) {
    return Activity(
      id: id,
      festivalId: map['festivalId'] as String? ?? '',
      type: map['type'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }
}
