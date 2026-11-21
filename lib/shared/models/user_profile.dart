import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime lmp;

  @HiveField(2)
  DateTime? eddOverride;

  @HiveField(3)
  String? welcomeMessage;

  @HiveField(4)
  String? doctorName;

  @HiveField(5)
  String? doctorPhone;

  @HiveField(6)
  String? emergencyContactName;

  @HiveField(7)
  String? emergencyContactPhone;

  UserProfile({
    required this.name,
    required this.lmp,
    this.eddOverride,
    this.welcomeMessage,
    this.doctorName,
    this.doctorPhone,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });
}
