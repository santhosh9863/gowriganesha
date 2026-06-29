class NotificationPreferences {
  final bool pushEnabled;
  final Map<String, bool> channels;

  const NotificationPreferences({
    this.pushEnabled = true,
    this.channels = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'pushEnabled': pushEnabled,
      'channels': channels.map((k, v) => MapEntry(k, v)),
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    final rawChannels = map['channels'];
    final channelMap = <String, bool>{};
    if (rawChannels is Map) {
      for (final entry in rawChannels.entries) {
        if (entry.value is bool) {
          channelMap[entry.key.toString()] = entry.value as bool;
        }
      }
    }
    return NotificationPreferences(
      pushEnabled: map['pushEnabled'] as bool? ?? true,
      channels: channelMap,
    );
  }

  NotificationPreferences copyWith({
    bool? pushEnabled,
    Map<String, bool>? channels,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      channels: channels ?? this.channels,
    );
  }
}
