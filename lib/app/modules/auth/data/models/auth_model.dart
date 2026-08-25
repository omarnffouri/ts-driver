import 'package:ts_driver/app/modules/auth/domain/entities/auth_entity.dart';
import 'user_model.dart';

/// Auth model that contains user data and authentication token
/// This is cached locally for offline-first authentication
class AuthModel extends AuthEntity {
  const AuthModel({
    required super.user,
    required super.token,
    super.isAuthenticated,
    super.lastSyncedAt,
  });

  /// Create AuthModel from JSON
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      isAuthenticated: json['isAuthenticated'] as bool? ?? true,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
    );
  }

  /// Convert AuthModel to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'user': (user as UserModel).toJson(),
      'token': token,
      'isAuthenticated': isAuthenticated,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  AuthModel copyWith({
    UserModel? user,
    String? token,
    bool? isAuthenticated,
    DateTime? lastSyncedAt,
  }) {
    return AuthModel(
      user: user ?? this.user as UserModel,
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  /// Create AuthModel from login/register response
  factory AuthModel.fromUserModel(UserModel userModel) {
    return AuthModel(
      user: userModel,
      token: userModel.token ?? '',
      isAuthenticated: true,
      lastSyncedAt: DateTime.now(),
    );
  }
}
