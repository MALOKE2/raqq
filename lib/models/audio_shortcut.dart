class AudioShortcut {
  final int? id;
  final String title;
  final String url;

  AudioShortcut({
    this.id,
    required this.title,
    required this.url,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
    };
  }

  factory AudioShortcut.fromMap(Map<String, Object?> map) {
    return AudioShortcut(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      url: map['url'] as String? ?? '',
    );
  }
}
