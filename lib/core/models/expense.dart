import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String festivalId;
  final int amount;
  final String note;
  final Timestamp date;
  final Timestamp createdAt;

  const Expense({
    required this.id,
    required this.festivalId,
    required this.amount,
    required this.note,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'festivalId': festivalId,
      'amount': amount,
      'note': note,
      'date': date,
      'createdAt': createdAt,
    };
  }

  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    return Expense(
      id: id,
      festivalId: map['festivalId'] as String? ?? '',
      amount: map['amount'] as int? ?? 0,
      note: map['note'] as String? ?? '',
      date: (map['date'] as Timestamp?) ?? Timestamp.now(),
      createdAt: (map['createdAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }

  Expense copyWith({
    String? id,
    String? festivalId,
    int? amount,
    String? note,
    Timestamp? date,
    Timestamp? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      festivalId: festivalId ?? this.festivalId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
