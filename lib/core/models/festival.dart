class Festival {
  final String id;
  final String name;
  final int year;
  final String location;

  const Festival({
    required this.id,
    required this.name,
    required this.year,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'year': year,
      'location': location,
    };
  }

  factory Festival.fromMap(String id, Map<String, dynamic> map) {
    final yearValue = map['year'];
    final parsedYear = switch (yearValue) {
      int v => v,
      String v => int.tryParse(v) ?? 2026,
      _ => 2026,
    };
    return Festival(
      id: id,
      name: map['name'] as String? ?? '',
      year: parsedYear,
      location: map['location'] as String? ?? '',
    );
  }

  Festival copyWith({
    String? id,
    String? name,
    int? year,
    String? location,
  }) {
    return Festival(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      location: location ?? this.location,
    );
  }
}
