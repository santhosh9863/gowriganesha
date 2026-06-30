import 'package:cloud_firestore/cloud_firestore.dart';

class Festival {
  final String id;
  final String name;
  final int year;
  final String location;
  final DateTime? festivalDate;
  final String? upiId;
  final String? accountName;
  final String? qrImageUrl;

  const Festival({
    required this.id,
    required this.name,
    required this.year,
    required this.location,
    this.festivalDate,
    this.upiId,
    this.accountName,
    this.qrImageUrl,
  });

  String get upiDeepLink {
    if (upiId == null || upiId!.isEmpty) return '';
    final params = StringBuffer('upi://pay?pa=${Uri.encodeComponent(upiId!)}');
    if (accountName != null && accountName!.isNotEmpty) {
      params.write('&pn=${Uri.encodeComponent(accountName!)}');
    }
    return params.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'year': year,
      'location': location,
      if (festivalDate != null) 'festivalDate': Timestamp.fromDate(festivalDate!),
      'upiId': upiId,
      'accountName': accountName,
      'qrImageUrl': qrImageUrl,
    };
  }

  factory Festival.fromMap(String id, Map<String, dynamic> map) {
    final yearValue = map['year'];
    final parsedYear = switch (yearValue) {
      int v => v,
      String v => int.tryParse(v) ?? 2026,
      _ => 2026,
    };
    final rawDate = map['festivalDate'];
    final parsedDate = switch (rawDate) {
      Timestamp t => t.toDate(),
      String s => DateTime.tryParse(s),
      _ => null,
    };
    return Festival(
      id: id,
      name: map['name'] as String? ?? '',
      year: parsedYear,
      location: map['location'] as String? ?? '',
      festivalDate: parsedDate,
      upiId: map['upiId'] as String?,
      accountName: map['accountName'] as String?,
      qrImageUrl: map['qrImageUrl'] as String?,
    );
  }

  Festival copyWith({
    String? id,
    String? name,
    int? year,
    String? location,
    DateTime? festivalDate,
    bool clearFestivalDate = false,
    String? upiId,
    bool clearUpiId = false,
    String? accountName,
    bool clearAccountName = false,
    String? qrImageUrl,
    bool clearQrImageUrl = false,
  }) {
    return Festival(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      location: location ?? this.location,
      festivalDate: clearFestivalDate ? null : (festivalDate ?? this.festivalDate),
      upiId: clearUpiId ? null : (upiId ?? this.upiId),
      accountName: clearAccountName ? null : (accountName ?? this.accountName),
      qrImageUrl: clearQrImageUrl ? null : (qrImageUrl ?? this.qrImageUrl),
    );
  }
}
