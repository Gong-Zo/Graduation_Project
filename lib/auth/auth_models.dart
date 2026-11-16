const Object _keep = Object();

/// 로그인 세션과 기능 권한. UI는 이 모델만 읽으면 된다.
enum AuthMode { signedIn, guest }

enum AppFeature {
  /// 자가점검. 회원만.
  selfCheck,

  /// 7일 체험. 회원만.
  sevenDayTrial,

  /// 맞춤형 준비 지원. 회원만.
  personalizedSupport,

  /// 입양 관련 정보. 비회원도 가능.
  adoptionInfo,

  /// 마이페이지. 회원만.
  myPage,
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String email;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'email': email,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AuthUser.fromJson(Map<String, Object?> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class AuthSession {
  const AuthSession._({required this.mode, this.user});

  factory AuthSession.signedIn(AuthUser user) {
    return AuthSession._(mode: AuthMode.signedIn, user: user);
  }

  factory AuthSession.guest() {
    return const AuthSession._(mode: AuthMode.guest);
  }

  final AuthMode mode;
  final AuthUser? user;

  bool get isGuest => mode == AuthMode.guest;
  bool get isSignedIn => mode == AuthMode.signedIn && user != null;

  bool canAccess(AppFeature feature) {
    if (feature == AppFeature.adoptionInfo) return true;
    return isSignedIn;
  }
}

class StoredAccount {
  const StoredAccount({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String passwordHash;
  final String salt;
  final DateTime createdAt;

  AuthUser toUser() =>
      AuthUser(id: id, email: email, createdAt: createdAt);

  Map<String, Object?> toJson() => {
    'id': id,
    'email': email,
    'passwordHash': passwordHash,
    'salt': salt,
    'createdAt': createdAt.toIso8601String(),
  };

  factory StoredAccount.fromJson(Map<String, Object?> json) {
    return StoredAccount(
      id: json['id'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      salt: json['salt'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class AuthSnapshot {
  const AuthSnapshot({
    this.onboardingDone = false,
    this.accounts = const [],
    this.sessionMode,
    this.sessionUserId,
  });

  final bool onboardingDone;
  final List<StoredAccount> accounts;
  final AuthMode? sessionMode;
  final String? sessionUserId;

  AuthSnapshot copyWith({
    bool? onboardingDone,
    List<StoredAccount>? accounts,
    Object? sessionMode = _keep,
    Object? sessionUserId = _keep,
  }) {
    return AuthSnapshot(
      onboardingDone: onboardingDone ?? this.onboardingDone,
      accounts: accounts ?? this.accounts,
      sessionMode: sessionMode == _keep
          ? this.sessionMode
          : sessionMode as AuthMode?,
      sessionUserId: sessionUserId == _keep
          ? this.sessionUserId
          : sessionUserId as String?,
    );
  }

  Map<String, Object?> toJson() => {
    'onboardingDone': onboardingDone,
    'accounts': accounts.map((account) => account.toJson()).toList(),
    'sessionMode': sessionMode?.name,
    'sessionUserId': sessionUserId,
  };

  factory AuthSnapshot.fromJson(Map<String, Object?> json) {
    final accounts = (json['accounts'] as List<dynamic>? ?? [])
        .map((item) => StoredAccount.fromJson(Map<String, Object?>.from(item as Map)))
        .toList();
    final modeName = json['sessionMode'] as String?;
    return AuthSnapshot(
      onboardingDone: json['onboardingDone'] as bool? ?? false,
      accounts: accounts,
      sessionMode: modeName == null
          ? null
          : AuthMode.values.firstWhere((mode) => mode.name == modeName),
      sessionUserId: json['sessionUserId'] as String?,
    );
  }
}
