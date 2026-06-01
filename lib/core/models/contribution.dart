import 'package:cloud_firestore/cloud_firestore.dart';

enum ContributionType {
  contribution,
  correction,
}

class Contribution {
  final String id;
  final ContributionType type;
  final int amount;
  final String note;
  final String recordedBy;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const Contribution({
    required this.id,
    this.type = ContributionType.contribution,
    required this.amount,
    this.note = '',
    this.recordedBy = 'system',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
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
      type: ContributionType.values.firstWhere(
        (e) => e.name == map['type'] as String?,
        orElse: () => ContributionType.contribution,
      ),
      amount: map['amount'] as int? ?? 0,
      note: map['note'] as String? ?? '',
      recordedBy: map['recordedBy'] as String? ?? 'system',
      createdAt: (map['createdAt'] as Timestamp?) ?? Timestamp.now(),
      updatedAt: (map['updatedAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }

  Contribution copyWith({
    String? id,
    ContributionType? type,
    int? amount,
    String? note,
    String? recordedBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Contribution(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      recordedBy: recordedBy ?? this.recordedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
