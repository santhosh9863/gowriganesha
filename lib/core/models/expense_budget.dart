import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseBudget {
  final String id;
  final String name;
  final int plannedAmount;
  final int displayOrder;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  const ExpenseBudget({
    required this.id,
    required this.name,
    required this.plannedAmount,
    required this.displayOrder,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'plannedAmount': plannedAmount,
      'displayOrder': displayOrder,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  factory ExpenseBudget.fromMap(String id, Map<String, dynamic> map) {
    return ExpenseBudget(
      id: id,
      name: map['name'] as String? ?? '',
      plannedAmount: map['plannedAmount'] as int? ?? 0,
      displayOrder: map['displayOrder'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?) ?? Timestamp.now(),
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  ExpenseBudget copyWith({
    String? id,
    String? name,
    int? plannedAmount,
    int? displayOrder,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool clearUpdatedAt = false,
  }) {
    return ExpenseBudget(
      id: id ?? this.id,
      name: name ?? this.name,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
    );
  }
}
