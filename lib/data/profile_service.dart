import 'package:hive/hive.dart';
import 'player_profile.dart';

class ProfileService {
  static final _box = Hive.box('playerBox');

  static PlayerProfile loadProfile() {
    final saved = _box.get('profile');
    if (saved != null) {
      return PlayerProfile.fromJson(Map<String, dynamic>.from(saved));
    } else {
      final profile = PlayerProfile();
      saveProfile(profile);
      return profile;
    }
  }

  static void saveProfile(PlayerProfile profile) {
    _box.put('profile', profile.toJson());
  }

  static void addXP(int amount) {
    final profile = loadProfile();
    profile.addXP(amount);
    saveProfile(profile);
  }
}
