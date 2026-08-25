import 'package:flutter/foundation.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';

/// Abstract class for local authentication data source
/// Handles caching and retrieval of authentication data
abstract class IAuthLocalDataSource {
  /// Cache authentication data locally
  Future<void> cacheAuthData(AuthModel authModel);

  /// Get cached authentication data
  /// Returns null if no data is cached
  Future<AuthModel?> getCachedAuthData();

  /// Clear all cached authentication data
  Future<void> clearCachedAuthData();

  /// Get cached user data
  /// Returns null if no user is cached
  Future<UserModel?> getCachedUser();

  /// Check if user is authenticated (has valid cached auth data)
  Future<bool> isAuthenticated();

  /// Get cached token
  /// Returns null if no token is cached
  Future<String?> getCachedToken();

  /// Update cached user profile (keeps token intact)
  Future<void> updateCachedUser(UserModel user);

  /// Check if a valid token exists
  Future<bool> hasValidToken();
}

/// Implementation of IAuthLocalDataSource using GetStorage
/// Provides offline-first authentication using local storage
class AuthLocalDatasourceImpl implements IAuthLocalDataSource {
  // Storage keys
  static const String _authDataKey = 'AUTH_DATA';
  static const String _tokenKey = TOKEN;
  static const String _userDataKey = USER_DATA;
  static const String _isAuthenticatedKey = IS_AUTHENTICATED;

  @override
  Future<void> cacheAuthData(AuthModel authModel) async {
    try {
      // Cache the complete auth model
      final authJson = authModel.toJson();
      await CommonVariables.userData.write(_authDataKey, authJson);

      // Also cache individual items for backward compatibility
      await CommonVariables.settings.write(_tokenKey, authModel.token);
      await CommonVariables.userData.write(
        _userDataKey,
        (authModel.user as UserModel).toJson(),
      );
      await CommonVariables.userData.write(
        _isAuthenticatedKey,
        authModel.isAuthenticated,
      );

      // Cache user IDs
      final user = authModel.user;
      if (user.personalDetails != null) {
        await CommonVariables.settings.write(
          APPLICANT_ID,
          user.personalDetails!.applicantId.toString(),
        );
        await CommonVariables.settings.write(
          USER_ID,
          user.personalDetails!.userId.toString(),
        );
      }

      debugPrint('✅ Auth data cached successfully');
    } catch (e) {
      debugPrint('❌ Error caching auth data: $e');
      rethrow;
    }
  }

  @override
  Future<AuthModel?> getCachedAuthData() async {
    try {
      final authData = await CommonVariables.userData.read(_authDataKey);

      if (authData == null) {
        debugPrint('⚠️ No cached auth data found');
        return null;
      }

      final authModel = AuthModel.fromJson(authData as Map<String, dynamic>);
      debugPrint('✅ Cached auth data retrieved successfully');
      return authModel;
    } catch (e) {
      debugPrint('❌ Error retrieving cached auth data: $e');
      // If there's an error, try to get data from old format
      return _tryGetAuthDataFromLegacyFormat();
    }
  }

  /// Try to construct AuthModel from legacy storage format
  Future<AuthModel?> _tryGetAuthDataFromLegacyFormat() async {
    try {
      final token = await CommonVariables.settings.read(_tokenKey);
      final userData = await CommonVariables.userData.read(_userDataKey);
      final isAuthenticated =
          await CommonVariables.userData.read(_isAuthenticatedKey);

      if (token == null || userData == null) {
        return null;
      }

      final user = UserModel.fromJson(userData as Map<String, dynamic>);
      final authModel = AuthModel(
        user: user,
        token: token as String,
        isAuthenticated: isAuthenticated as bool? ?? true,
        lastSyncedAt: null,
      );

      // Cache in new format for next time
      await cacheAuthData(authModel);

      debugPrint('✅ Migrated auth data from legacy format');
      return authModel;
    } catch (e) {
      debugPrint('❌ Error migrating legacy auth data: $e');
      return null;
    }
  }

  @override
  Future<void> clearCachedAuthData() async {
    try {
      // Clear new format
      await CommonVariables.userData.remove(_authDataKey);

      // Clear legacy format for backward compatibility
      await CommonVariables.userData.remove(_userDataKey);
      await CommonVariables.userData.remove(_isAuthenticatedKey);
      await CommonVariables.settings.remove(_tokenKey);
      await CommonVariables.settings.remove(APPLICANT_ID);
      await CommonVariables.settings.remove(USER_ID);

      debugPrint('✅ Auth data cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing auth data: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final authData = await getCachedAuthData();
      if (authData == null) return null;

      return authData.user as UserModel;
    } catch (e) {
      debugPrint('❌ Error getting cached user: $e');
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final authData = await getCachedAuthData();
      return authData?.isValid ?? false;
    } catch (e) {
      debugPrint('❌ Error checking authentication: $e');
      return false;
    }
  }

  @override
  Future<String?> getCachedToken() async {
    try {
      final authData = await getCachedAuthData();
      return authData?.token;
    } catch (e) {
      debugPrint('❌ Error getting cached token: $e');
      return null;
    }
  }

  @override
  Future<void> updateCachedUser(UserModel user) async {
    try {
      // Get existing auth data
      final authData = await getCachedAuthData();

      if (authData == null) {
        debugPrint('⚠️ No cached auth data to update');
        return;
      }

      // Update with new user data while keeping token
      final updatedAuth = authData.copyWith(
        user: user,
        lastSyncedAt: DateTime.now(),
      );

      // Cache updated data
      await cacheAuthData(updatedAuth);
      debugPrint('✅ Cached user updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating cached user: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasValidToken() async {
    try {
      final token = await CommonVariables.settings.read(_tokenKey);
      return token != null && (token as String).isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking token validity: $e');
      return false;
    }
  }
}
