import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/hive_service.dart';
import '../../shared/models/user_profile.dart';

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null) {
    _loadProfile();
  }

  void _loadProfile() {
    final box = HiveService.getBox<UserProfile>(HiveService.profileBoxName);
    if (box.isNotEmpty) {
      state = box.getAt(0);
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final box = HiveService.getBox<UserProfile>(HiveService.profileBoxName);
    if (box.isEmpty) {
      await box.add(profile);
    } else {
      await box.putAt(0, profile);
    }
    state = profile;
  }
}
