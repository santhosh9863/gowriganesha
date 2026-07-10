import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/models/user_role.dart';

class AppUser {
  final String id;
  final String festivalId;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final String? firebaseUid;
  final Timestamp registeredAt;
  final Timestamp lastActive;
  final bool isOnline;
  final String? device;
  final int loginCount;
  final String? createdBy;

  const AppUser({
    required this.id,
    required this.festivalId,
    required this.name,
    this.email = '',
    this.phone,
    this.photoUrl,
    required this.role,
    this.firebaseUid,
    required this.registeredAt,
    required this.lastActive,
    this.isOnline = false,
    this.device,
    this.loginCount = 0,
    this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'festivalId': festivalId,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'role': role.name,
      if (firebaseUid != null) 'firebaseUid': firebaseUid,
      'registeredAt': registeredAt,
      'lastActive': lastActive,
      'isOnline': isOnline,
      if (device != null) 'device': device,
      'loginCount': loginCount,
      if (createdBy != null) 'createdBy': createdBy,
    };
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      festivalId: map['festivalId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      photoUrl: map['photoUrl'] as String?,
      role: UserRole.values.firstWhere(
        (r) => r.name == (map['role'] as String? ?? 'volunteer'),
        orElse: () => UserRole.volunteer,
      ),
      firebaseUid: map['firebaseUid'] as String?,
      registeredAt: (map['registeredAt'] as Timestamp?) ?? Timestamp.now(),
      lastActive: (map['lastActive'] as Timestamp?) ?? Timestamp.now(),
      isOnline: map['isOnline'] as bool? ?? false,
      device: map['device'] as String?,
      loginCount: map['loginCount'] as int? ?? 0,
      createdBy: map['createdBy'] as String?,
    );
  }

  AppUser copyWith({
    String? id,
    String? festivalId,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    UserRole? role,
    String? firebaseUid,
    Timestamp? registeredAt,
    Timestamp? lastActive,
    bool? isOnline,
    String? device,
    int? loginCount,
    String? createdBy,
    bool clearPhone = false,
    bool clearPhotoUrl = false,
    bool clearFirebaseUid = false,
    bool clearDevice = false,
    bool clearCreatedBy = false,
  }) {
    return AppUser(
      id: id ?? this.id,
      festivalId: festivalId ?? this.festivalId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: clearPhone ? null : phone ?? this.phone,
      photoUrl: clearPhotoUrl ? null : photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      firebaseUid: clearFirebaseUid ? null : firebaseUid ?? this.firebaseUid,
      registeredAt: registeredAt ?? this.registeredAt,
      lastActive: lastActive ?? this.lastActive,
      isOnline: isOnline ?? this.isOnline,
      device: clearDevice ? null : device ?? this.device,
      loginCount: loginCount ?? this.loginCount,
      createdBy: clearCreatedBy ? null : createdBy ?? this.createdBy,
    );
  }
}
