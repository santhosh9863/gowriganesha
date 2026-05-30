import 'package:cloud_firestore/cloud_firestore.dart';

class Target {
  final String id;
  final String festivalId;
  final String name;
  final String building;
  final String area;
  final int expectedAmount;
  final int givenAmount;
  final String? notes;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const Target({
    required this.id,
    required this.festivalId,
    required this.name,
    this.building = '',
    this.area = '',
    required this.expectedAmount,
    required this.givenAmount,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'festivalId': festivalId,
      'name': name,
      'building': building,
      'area': area,
      'expectedAmount': expectedAmount,
      'givenAmount': givenAmount,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Target.fromMap(String id, Map<String, dynamic> map) {
    return Target(
      id: id,
      festivalId: map['festivalId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      building: map['building'] as String? ?? '',
      area: map['area'] as String? ?? '',
      expectedAmount: map['expectedAmount'] as int? ?? 0,
      givenAmount: map['givenAmount'] as int? ?? 0,
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp?) ?? Timestamp.now(),
      updatedAt: (map['updatedAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }

  Target copyWith({
    String? id,
    String? festivalId,
    String? name,
    String? building,
    String? area,
    int? expectedAmount,
    int? givenAmount,
    String? notes,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Target(
      id: id ?? this.id,
      festivalId: festivalId ?? this.festivalId,
      name: name ?? this.name,
      building: building ?? this.building,
      area: area ?? this.area,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      givenAmount: givenAmount ?? this.givenAmount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
