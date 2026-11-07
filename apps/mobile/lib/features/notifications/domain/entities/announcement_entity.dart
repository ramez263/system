import 'package:equatable/equatable.dart';

class AnnouncementEntity extends Equatable {
  final int id;
  final String title;
  final String body;
  final String category;
  final String icon;
  final String? actionUrl;
  final String time;

  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.icon,
    this.actionUrl,
    required this.time,
  });

  factory AnnouncementEntity.fromJson(Map<String, dynamic> json) {
    return AnnouncementEntity(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      category: json['category'] as String? ?? 'updates',
      icon: json['icon'] as String? ?? 'notifications',
      actionUrl: json['action_url'] as String?,
      time: json['time'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title, body, category, icon, actionUrl, time];
}
