/// 로그인 세션·회원 권한·기기 저장 JSON 모델.
const Object _keep = Object(); // copyWith에서 null과 "값 유지"를 구분한다.

/// 로그인 세션과 기능 권한. UI는 이 모델만 읽으면 된다.
/// 회원 로그인 또는 비회원 둘러보기.
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

/// 화면에 보여줄 회원. 비밀번호 해시는 넣지 않는다.
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

/// 현재 이용 방식. 입양 정보만 비회원도 열 수 있다.
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

/// 기기에 두는 계정. 비밀번호는 salt+SHA-256만 저장한다.
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

/// 온보딩 여부, 계정 목록, 현재 세션을 한 번에 저장하는 스냅샷.
class AuthSnapshot {
  const AuthSnapshot({
    this.onboardingDone = false,
    this.accounts = const [],
    this.sessionMode,
    this.sessionUserId,
    this.accessToken,
  });

  final bool onboardingDone;
  final List<StoredAccount> accounts;
  final AuthMode? sessionMode;
  final String? sessionUserId;
  /// FastAPI 토큰. 없으면 기기 계정만 쓴다.
  final String? accessToken;

  AuthSnapshot copyWith({
    bool? onboardingDone,
    List<StoredAccount>? accounts,
    Object? sessionMode = _keep,
    Object? sessionUserId = _keep,
    Object? accessToken = _keep,
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
      accessToken: accessToken == _keep
          ? this.accessToken
          : accessToken as String?,
    );
  }

  Map<String, Object?> toJson() => {
    'onboardingDone': onboardingDone,
    'accounts': accounts.map((account) => account.toJson()).toList(),
    'sessionMode': sessionMode?.name,
    'sessionUserId': sessionUserId,
    'accessToken': accessToken,
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
      accessToken: json['accessToken'] as String?,
    );
  }
}
