import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/models/user.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/core/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return UserService(firestore: firestore);
});

final allUsersStreamProvider = StreamProvider<List<AppUser>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.watchUsers();
});

class UsersStats {
  final int total;
  final int online;
  final int admins;
  final int volunteers;
  final int joinedToday;

  const UsersStats({
    this.total = 0,
    this.online = 0,
    this.admins = 0,
    this.volunteers = 0,
    this.joinedToday = 0,
  });
}

final usersStatsProvider = Provider<UsersStats>((ref) {
  final usersAsync = ref.watch(allUsersStreamProvider);
  final users = usersAsync.valueOrNull ?? [];
  if (users.isEmpty) return const UsersStats();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  int total = 0;
  int online = 0;
  int admins = 0;
  int volunteers = 0;
  int joinedToday = 0;

  for (final user in users) {
    total++;
    if (user.isOnline) online++;
    if (user.role == UserRole.admin) admins++;
    if (user.role == UserRole.volunteer) volunteers++;
    final regDate = user.registeredAt.toDate();
    final regDay = DateTime(regDate.year, regDate.month, regDate.day);
    if (regDay == today) joinedToday++;
  }

  return UsersStats(
    total: total,
    online: online,
    admins: admins,
    volunteers: volunteers,
    joinedToday: joinedToday,
  );
});

enum UsersSort { newest, oldest, nameAZ, onlineFirst }

final usersSortProvider = StateProvider<UsersSort>((ref) => UsersSort.newest);

final usersSearchProvider = StateProvider<String>((ref) => '');

final filteredSortedUsersProvider = Provider<List<AppUser>>((ref) {
  final usersAsync = ref.watch(allUsersStreamProvider);
  final users = usersAsync.valueOrNull ?? [];
  final query = ref.watch(usersSearchProvider);
  final sort = ref.watch(usersSortProvider);

  var filtered = users;
  if (query.isNotEmpty) {
    final lower = query.toLowerCase();
    filtered = users.where((u) => u.name.toLowerCase().contains(lower)).toList();
  }

  return _sortUsers(filtered, sort);
});

List<AppUser> _sortUsers(List<AppUser> users, UsersSort sort) {
  final sorted = List<AppUser>.from(users);
  switch (sort) {
    case UsersSort.newest:
      sorted.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
    case UsersSort.oldest:
      sorted.sort((a, b) => a.registeredAt.compareTo(b.registeredAt));
    case UsersSort.nameAZ:
      sorted.sort((a, b) => a.name.compareTo(b.name));
    case UsersSort.onlineFirst:
      sorted.sort((a, b) {
        if (a.isOnline && !b.isOnline) return -1;
        if (!a.isOnline && b.isOnline) return 1;
        return b.registeredAt.compareTo(a.registeredAt);
      });
  }
  return sorted;
}
