class PlayerProfile {
  int xp;
  int level;
  // ✅ ADD THESE TWO NEW FIELDS
  int currentStreak;
  DateTime? lastPlayedDate;

  PlayerProfile({
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0, // Default streak is 0
    this.lastPlayedDate,
  });

  int get xpForNextLevel => level * 100;

  // ✅ UPDATE fromJson FACTORY
  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      currentStreak: json['currentStreak'] ?? 0,
      // Handle the date, which might not exist on old profiles
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'])
          : null,
    );
  }

  // ✅ UPDATE toJson METHOD
  Map<String, dynamic> toJson() {
    return {
      'xp': xp,
      'level': level,
      'currentStreak': currentStreak,
      // Store date as a string, which is JSON-safe
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
    };
  }
}