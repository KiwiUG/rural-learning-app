import 'package:hive/hive.dart';
import 'package:rural_learning_app/data/player_profile.dart';

class ProfileService {
  static final _box = Hive.box('playerBox');

  static PlayerProfile getProfile() {
    final saved = _box.get('profile');
    if (saved != null) {
      return PlayerProfile.fromJson(Map<String, dynamic>.from(saved));
    }
    return PlayerProfile();
  }

  static void saveProfile(PlayerProfile profile) {
    _box.put('profile', profile.toJson());
  }

  // ✅ CREATE THIS NEW METHOD FOR STREAK & XP
  static void updateProgress({required int xpGained}) {
    final profile = getProfile();
    final now = DateTime.now();
    // Normalize dates to ignore time of day
    final today = DateTime(now.year, now.month, now.day);

    if (profile.lastPlayedDate == null) {
      // First time playing
      profile.currentStreak = 1;
    } else {
      final lastPlayed = profile.lastPlayedDate!;
      final lastPlayedDay = DateTime(lastPlayed.year, lastPlayed.month, lastPlayed.day);
      final difference = today.difference(lastPlayedDay).inDays;

      if (difference == 1) {
        // Played yesterday, continue the streak
        profile.currentStreak++;
      } else if (difference > 1) {
        // Missed a day, reset the streak
        profile.currentStreak = 1;
      }
      // If difference is 0, they already played today. Do nothing to the streak.
    }

    // Update XP and last played date
    profile.xp += xpGained;
    profile.lastPlayedDate = now;

    // Check for level up
    if (profile.xp >= profile.xpForNextLevel) {
      profile.xp -= profile.xpForNextLevel;
      profile.level++;
    }

    saveProfile(profile);
  }
}