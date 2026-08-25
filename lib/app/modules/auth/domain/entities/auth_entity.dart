import 'package:equatable/equatable.dart';
import 'user_entity.dart';

/// Domain entity for authentication data
/// Contains user information and authentication state
class AuthEntity extends Equatable {
  final UserEntity user;
  final String token;
  final bool isAuthenticated;
  final DateTime? lastSyncedAt;

  const AuthEntity({
    required this.user,
    required this.token,
    this.isAuthenticated = true,
    this.lastSyncedAt,
  });

  @override
  List<Object?> get props => [user, token, isAuthenticated, lastSyncedAt];

  /// Check if the auth data needs to be synced
  /// Returns true if never synced or last sync was more than 1 hour ago
  bool needsSync() {
    if (lastSyncedAt == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastSyncedAt!);
    return difference.inHours >= 1;
  }

  /// Check if user is authenticated
  bool get isValid => token.isNotEmpty && isAuthenticated;
}
