 class PlayerProfile {
  int xp;
  int level;

  PlayerProfile({this.xp = 0, this.level = 1});

  /// Calculate XP needed for next level
  int get xpForNextLevel => level * 100; // simple formula (100 XP per level)

  /// Add XP and handle level up
  void addXP(int amount) {
    xp += amount;
    while (xp >= xpForNextLevel) {
      xp -= xpForNextLevel;
      level++;
    }
  }

  Map<String, dynamic> toJson() => {"xp": xp, "level": level};

  factory PlayerProfile.fromJson(Map<String, dynamic> json) =>
      PlayerProfile(xp: json["xp"], level: json["level"]);
}
