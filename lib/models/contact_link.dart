import 'package:flutter/material.dart';

class ContactLink {
  final int? id;
  final String label;
  final String url;
  final String icon; // اسم أيقونة من Icons (مثل: Icons.phone)

  ContactLink({
    this.id,
    required this.label,
    required this.url,
    required this.icon,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'label': label,
      'url': url,
      'icon': icon,
    };
  }

  factory ContactLink.fromMap(Map<String, Object?> map) {
    return ContactLink(
      id: map['id'] as int?,
      label: map['label'] as String? ?? '',
      url: map['url'] as String? ?? '',
      icon: map['icon'] as String? ?? 'Icons.link',
    );
  }

  /// يحول اسم الأيقونة النصية إلى IconData
  IconData toIconData() {
    switch (icon) {
      case 'Icons.phone':
        return Icons.phone;
      case 'Icons.chat':
        return Icons.chat;
      case 'Icons.facebook':
        return Icons.facebook;
      case 'Icons.camera_alt':
        return Icons.camera_alt;
      case 'Icons.sync':
        return Icons.sync;
      case 'Icons.video_collection':
        return Icons.video_collection;
      case 'Icons.language':
        return Icons.language;
      case 'Icons.email':
        return Icons.email;
      case 'Icons.youtube':
        return Icons.smart_display;
      case 'Icons.link':
      default:
        return Icons.link;
    }
  }
}
