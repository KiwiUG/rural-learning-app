class PlayerProfile {
  int xp;
  int level;

  PlayerProfile({this.xp = 0, this.level = 1});

  int get xpForNextLevel => level * 100;

  void addXP(int amount) {
    xp += amount;
    while (xp >= xpForNextLevel) {
      xp -= xpForNextLevel;
      level++;
    }
  }

  Map<String, dynamic> toJson() => {
        "xp": xp,
        "level": level,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      xp: json["xp"] ?? 0,
      level: json["level"] ?? 1,
    );
  }
}
