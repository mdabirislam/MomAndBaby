class PregnancyWeek {
  final int week;
  final String fruitComparison;
  final String babyDevelopment;
  final String approximateBabySize;
  final String approximateBabyWeight;
  final String motherBodyChanges;
  final String normalDiscomforts;
  final String dangerSigns;
  final String dietToEat;
  final String dietToAvoid;
  final String lifestyleTips;
  final String medicalReferences;
  final String lastReviewed;
  final String reviewStatus;

  PregnancyWeek({
    required this.week,
    required this.fruitComparison,
    required this.babyDevelopment,
    required this.approximateBabySize,
    required this.approximateBabyWeight,
    required this.motherBodyChanges,
    required this.normalDiscomforts,
    required this.dangerSigns,
    required this.dietToEat,
    required this.dietToAvoid,
    required this.lifestyleTips,
    required this.medicalReferences,
    required this.lastReviewed,
    required this.reviewStatus,
  });

  factory PregnancyWeek.fromJson(Map<String, dynamic> json) {
    return PregnancyWeek(
      week: json['week'],
      fruitComparison: json['fruit_comparison'],
      babyDevelopment: json['baby_development'],
      approximateBabySize: json['approximate_baby_size'],
      approximateBabyWeight: json['approximate_baby_weight'],
      motherBodyChanges: json['mother_body_changes'],
      normalDiscomforts: json['normal_discomforts'],
      dangerSigns: json['danger_signs'],
      dietToEat: json['diet_to_eat'],
      dietToAvoid: json['diet_to_avoid'],
      lifestyleTips: json['lifestyle_tips'],
      medicalReferences: json['medical_references'],
      lastReviewed: json['last_reviewed'],
      reviewStatus: json['review_status'],
    );
  }
}
