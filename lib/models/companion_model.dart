import 'dart:convert';

enum CompanionRole {
  buddy, // Casual friend
  mentor, // Wise guide
  coach, // Energetic motivator
  sibling, // Caring family member
  therapist, // Professional support
}

class CompanionModel {
  final String id;
  final String userId;
  final String name;
  final CompanionRole role;
  final List<String> personalityTraits;
  final String avatarStyle;
  final Map<String, dynamic> voiceSettings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanionModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.role,
    required this.personalityTraits,
    this.avatarStyle = 'default',
    this.voiceSettings = const {},
    this.isActive = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Default factory for new users
  factory CompanionModel.defaultFox(String userId) {
    return CompanionModel(
      id: 'default', // Or generate UUID
      userId: userId,
      name: 'SINO',
      role: CompanionRole.buddy,
      personalityTraits: ['Warm', 'Encouraging', 'Playful'],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'role': role.name,
      'personality_traits': personalityTraits,
      'avatar_style': avatarStyle,
      'voice_settings': voiceSettings,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CompanionModel.fromMap(Map<String, dynamic> map) {
    return CompanionModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      role: _parseRole(map['role']),
      personalityTraits: List<String>.from(map['personality_traits'] ?? []),
      avatarStyle: map['avatar_style'] ?? 'default',
      voiceSettings: Map<String, dynamic>.from(map['voice_settings'] ?? {}),
      isActive: map['is_active'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory CompanionModel.fromJson(String source) =>
      CompanionModel.fromMap(json.decode(source));

  static CompanionRole _parseRole(String? roleStr) {
    return CompanionRole.values.firstWhere(
      (e) => e.name == roleStr,
      orElse: () => CompanionRole.buddy,
    );
  }

  CompanionModel copyWith({
    String? id,
    String? userId,
    String? name,
    CompanionRole? role,
    List<String>? personalityTraits,
    String? avatarStyle,
    Map<String, dynamic>? voiceSettings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      avatarStyle: avatarStyle ?? this.avatarStyle,
      voiceSettings: voiceSettings ?? this.voiceSettings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
