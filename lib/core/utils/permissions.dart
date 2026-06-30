import 'package:ganesha_2026/core/models/user_role.dart';

bool isAdmin(UserRole role) => role == UserRole.admin;
bool isVolunteer(UserRole role) => role == UserRole.volunteer;

bool canDelete(UserRole role) => role == UserRole.admin;
bool canExport(UserRole role) => role == UserRole.admin;
bool canClearFeed(UserRole role) => role == UserRole.admin;
bool canChangeBudget(UserRole role) => role == UserRole.admin;
bool canAccessSettings(UserRole role) => role == UserRole.admin;
bool canLockFestival(UserRole role) => role == UserRole.admin;
bool canEditRecords(UserRole role) => role == UserRole.admin;
bool canManageExpenses(UserRole role) => role == UserRole.admin;
