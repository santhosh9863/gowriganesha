import 'package:cloud_firestore/cloud_firestore.dart';

class Contribution {
  final String id;
  final int amount;
  final String note;
  final String recordedBy;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const Contribution({
    required this.id,
    required this.amount,
    this.note = '',
    this.recordedBy = 'system',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'note': note,
      'recordedBy': recordedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Contribution.fromMap(String id, Map<String, dynamic> map) {
    return Contribution(
      id: id,
      amount: map['amount'] as int? ?? 0,
      note: map['note'] as String? ?? '',
      recordedBy: map['recordedBy'] as String? ?? 'system',
      createdAt: (map['createdAt'] as Timestamp?) ?? Timestamp.now(),
      updatedAt: (map['updatedAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }

  Contribution copyWith({
    String? id,
    int? amount,
    String? note,
    String? recordedBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Contribution(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      recordedBy: recordedBy ?? this.recordedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
