import 'package:hive/hive.dart';

part 'player_profile.g.dart';

@HiveType(typeId: 0)
class PlayerProfile extends HiveObject {
  @HiveField(0)
  int level;

  @HiveField(1)
  int xp;

  @HiveField(2)
  int xpForNextLevel;

  // ✅ New fields for streak
  @HiveField(3)
  int currentStreak; 

  @HiveField(4)
  int longestStreak;

  @HiveField(5)
  DateTime lastPlayed;

  PlayerProfile({
    this.level = 1,
    this.xp = 0,
    this.xpForNextLevel = 100,
    this.currentStreak = 0,
    this.longestStreak = 0,
    DateTime? lastPlayed,
  }) : lastPlayed = lastPlayed ?? DateTime.now();

  void addXP(int amount) {
    xp += amount;
    while (xp >= xpForNextLevel) {
      xp -= xpForNextLevel;
      level++;
      xpForNextLevel = (xpForNextLevel * 1.2).toInt();
    }
    save(); // persist to Hive
  }

  // ✅ New function to update streaks
  void updateStreak() {
    final today = DateTime.now();
    final last = lastPlayed;

    if (today.difference(last).inDays == 1) {
      currentStreak++;
    } else if (today.difference(last).inDays > 1) {
      currentStreak = 1; // reset if missed
    } else if (today.day != last.day) {
      currentStreak = 1; // first play today
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    lastPlayed = today;
    save();
  }

  Map<String, dynamic> toJson() => {
        "level": level,
        "xp": xp,
        "xpForNextLevel": xpForNextLevel,
        "currentStreak": currentStreak,
        "longestStreak": longestStreak,
        "lastPlayed": lastPlayed.toIso8601String(),
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
  return PlayerProfile(
    level: json['level'] is int ? json['level'] : 1,
    xp: json['xp'] is int ? json['xp'] : 0,
    xpForNextLevel: json['xpForNextLevel'] is int ? json['xpForNextLevel'] : 100,
    currentStreak: json['currentStreak'] is int ? json['currentStreak'] : 0,
    longestStreak: json['longestStreak'] is int ? json['longestStreak'] : 0,
    lastPlayed: json['lastPlayed'] != null
        ? DateTime.tryParse(json['lastPlayed']) ?? DateTime.now()
        : DateTime.now(),
  );
}
}
