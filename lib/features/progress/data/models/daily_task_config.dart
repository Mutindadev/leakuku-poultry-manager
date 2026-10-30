const builtInDailyTaskTitles = <String, String>{
  'feed_birds': 'Feed birds',
  'refresh_water': 'Refresh water',
  'observe_bird_activity': 'Observe bird activity',
  'check_litter': 'Check litter',
  'record_mortality': 'Record mortality',
  'check_brooder_temperature': 'Check brooder temperature',
  'weigh_sample_birds': 'Weigh sample birds',
  'administer_scheduled_vaccine': 'Administer scheduled vaccine',
};

String builtInTaskConfigId(String taskId) => 'builtin_$taskId';

class DailyTaskConfig {
  const DailyTaskConfig({
    required this.id,
    required this.userId,
    required this.title,
    required this.isCustom,
    required this.isEnabled,
    required this.updatedAt,
    this.description,
    this.flockId,
  });

  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? flockId;
  final bool isCustom;
  final bool isEnabled;
  final DateTime updatedAt;

  bool appliesTo(String targetFlockId) =>
      flockId == null || flockId == targetFlockId;

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'flockId': flockId,
        'isCustom': isCustom,
        'isEnabled': isEnabled,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory DailyTaskConfig.fromMap(Map<String, dynamic> map) {
    final updatedAt = map['updatedAt'];
    return DailyTaskConfig(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      flockId: map['flockId'] as String?,
      isCustom: map['isCustom'] as bool,
      isEnabled: map['isEnabled'] as bool,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt as int),
    );
  }
}
