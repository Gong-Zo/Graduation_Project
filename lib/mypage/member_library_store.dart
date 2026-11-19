/// 회원 마이페이지 데이터. 별칭·설정·저장 콘텐츠·관심 항목을 기기에 둔다.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/rescued_dog.dart';

export 'remote_member_library_store.dart';

class SavedContentItem {
  const SavedContentItem({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'description': description,
  };

  factory SavedContentItem.fromJson(Map<String, Object?> json) {
    return SavedContentItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class FavoriteShelter {
  const FavoriteShelter({
    required this.id,
    required this.name,
    required this.address,
  });

  final String id;
  final String name;
  final String address;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'address': address,
  };

  factory FavoriteShelter.fromJson(Map<String, Object?> json) {
    return FavoriteShelter(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }
}

class MemberLibrary {
  const MemberLibrary({
    this.displayName = '',
    this.notificationsEnabled = true,
    this.remindersEnabled = false,
    this.savedContent = const [],
    this.favoriteDogs = const [],
    this.favoriteShelters = const [],
  });

  final String displayName;
  final bool notificationsEnabled;
  final bool remindersEnabled;
  final List<SavedContentItem> savedContent;
  final List<RescuedDog> favoriteDogs;
  final List<FavoriteShelter> favoriteShelters;

  MemberLibrary copyWith({
    String? displayName,
    bool? notificationsEnabled,
    bool? remindersEnabled,
    List<SavedContentItem>? savedContent,
    List<RescuedDog>? favoriteDogs,
    List<FavoriteShelter>? favoriteShelters,
  }) {
    return MemberLibrary(
      displayName: displayName ?? this.displayName,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      savedContent: savedContent ?? this.savedContent,
      favoriteDogs: favoriteDogs ?? this.favoriteDogs,
      favoriteShelters: favoriteShelters ?? this.favoriteShelters,
    );
  }

  Map<String, Object?> toJson() => {
    'displayName': displayName,
    'notificationsEnabled': notificationsEnabled,
    'remindersEnabled': remindersEnabled,
    'savedContent': [for (final item in savedContent) item.toJson()],
    'favoriteDogs': [for (final dog in favoriteDogs) dog.toJson()],
    'favoriteShelters': [
      for (final shelter in favoriteShelters) shelter.toJson(),
    ],
  };

  factory MemberLibrary.fromJson(Map<String, Object?> json) {
    return MemberLibrary(
      displayName: json['displayName'] as String? ?? '',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      remindersEnabled: json['remindersEnabled'] as bool? ?? false,
      savedContent: [
        for (final item in json['savedContent'] as List<dynamic>? ?? [])
          if (item is Map)
            SavedContentItem.fromJson(Map<String, Object?>.from(item)),
      ],
      favoriteDogs: [
        for (final item in json['favoriteDogs'] as List<dynamic>? ?? [])
          if (item is Map) RescuedDog.fromJson(Map<String, Object?>.from(item)),
      ],
      favoriteShelters: [
        for (final item in json['favoriteShelters'] as List<dynamic>? ?? [])
          if (item is Map)
            FavoriteShelter.fromJson(Map<String, Object?>.from(item)),
      ],
    );
  }
}

abstract class MemberLibraryStore {
  Future<MemberLibrary> load(String userId);
  Future<void> save(String userId, MemberLibrary library);
}

class MemoryMemberLibraryStore implements MemberLibraryStore {
  MemoryMemberLibraryStore([Map<String, MemberLibrary>? data])
    : _data = data ?? {};

  final Map<String, MemberLibrary> _data;

  @override
  Future<MemberLibrary> load(String userId) async {
    return _data[userId] ?? const MemberLibrary();
  }

  @override
  Future<void> save(String userId, MemberLibrary library) async {
    _data[userId] = library;
  }
}

class LocalMemberLibraryStore implements MemberLibraryStore {
  LocalMemberLibraryStore({this.key = 'petbefore.member_library.v1'});

  final String key;
  static bool useDisk = true;
  static final Map<String, MemberLibrary> _memory = {};
  static bool _hydrated = false;

  @override
  Future<MemberLibrary> load(String userId) async {
    await _hydrate();
    return _memory[userId] ?? const MemberLibrary();
  }

  @override
  Future<void> save(String userId, MemberLibrary library) async {
    await _hydrate();
    _memory[userId] = library;
    if (!useDisk) return;
    try {
      await _persist();
    } catch (_) {}
  }

  Future<void> _hydrate() async {
    if (_hydrated) return;
    if (!useDisk) {
      _hydrated = true;
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            if (entry.value is Map) {
              _memory['${entry.key}'] = MemberLibrary.fromJson(
                Map<String, Object?>.from(entry.value as Map),
              );
            }
          }
        }
      }
    } catch (_) {}
    _hydrated = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      jsonEncode({
        for (final entry in _memory.entries) entry.key: entry.value.toJson(),
      }),
    );
  }
}

const educationContent = SavedContentItem(
  id: 'education',
  title: '맞춤 교육 콘텐츠',
  description: '산책·건강·생활 환경·행동 이해 안내',
);

const breedContent = SavedContentItem(
  id: 'breed',
  title: '양육 특성·견종 정보',
  description: '활동량·털 관리·건강 특성 안내',
);

const adoptionEducationContent = SavedContentItem(
  id: 'adoptionEducation',
  title: '입양 전 교육자료',
  description: '동의·돌봄 계획·비용·적응 안내',
);
