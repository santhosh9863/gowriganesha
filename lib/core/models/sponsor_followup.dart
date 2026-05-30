import 'package:cloud_firestore/cloud_firestore.dart';

class SponsorFollowup {
  final String id;
  final String festivalId;
  final String sponsorId;
  final String sponsorName;
  final Timestamp followUpDate;
  final int? amount;
  final String note;
  final String status;
  final Timestamp createdAt;
  final Timestamp? completedAt;

  const SponsorFollowup({
    required this.id,
    required this.festivalId,
    this.sponsorId = '',
    required this.sponsorName,
    required this.followUpDate,
    this.amount,
    required this.note,
    this.status = 'active',
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'festivalId': festivalId,
      'sponsorId': sponsorId,
      'sponsorName': sponsorName,
      'followUpDate': followUpDate,
      'amount': amount,
      'note': note,
      'status': status,
      'createdAt': createdAt,
      'completedAt': completedAt,
    };
  }

  factory SponsorFollowup.fromMap(String id, Map<String, dynamic> map) {
    return SponsorFollowup(
      id: id,
      festivalId: map['festivalId'] as String? ?? '',
      sponsorId: map['sponsorId'] as String? ?? '',
      sponsorName: map['sponsorName'] as String? ?? '',
      followUpDate: (map['followUpDate'] as Timestamp?) ?? Timestamp.now(),
      amount: map['amount'] as int?,
      note: map['note'] as String? ?? '',
      status: map['status'] as String? ?? 'active',
      createdAt: (map['createdAt'] as Timestamp?) ?? Timestamp.now(),
      completedAt: map['completedAt'] as Timestamp?,
    );
  }

  SponsorFollowup copyWith({
    String? id,
    String? festivalId,
    String? sponsorId,
    String? sponsorName,
    Timestamp? followUpDate,
    int? amount,
    String? note,
    String? status,
    Timestamp? createdAt,
    Timestamp? completedAt,
    bool clearAmount = false,
    bool clearCompletedAt = false,
  }) {
    return SponsorFollowup(
      id: id ?? this.id,
      festivalId: festivalId ?? this.festivalId,
      sponsorId: sponsorId ?? this.sponsorId,
      sponsorName: sponsorName ?? this.sponsorName,
      followUpDate: followUpDate ?? this.followUpDate,
      amount: clearAmount ? null : (amount ?? this.amount),
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }
}
