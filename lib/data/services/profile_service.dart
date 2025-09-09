import 'dart:developer';

import '../models/profile.dart';
import '../../main.dart';

class ProfileService {
  static const String tableName = 'profiles';

  /// 현재 사용자의 프로필 가져오기
  Future<Profile?> getCurrentUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final response = await supabase
          .from(tableName)
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return null;

      return Profile.fromJson(response);
    } catch (e) {
      log('Error fetching user profile: $e');
      return null;
    }
  }

  /// 특정 사용자 프로필 가져오기
  Future<Profile?> getProfileById(String userId) async {
    try {
      final response = await supabase
          .from(tableName)
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return Profile.fromJson(response);
    } catch (e) {
      log('Error fetching profile by id: $e');
      return null;
    }
  }

  /// 프로필 생성 또는 업데이트
  Future<Profile?> upsertProfile({
    required String userId,
    String? nickname,
    String? avatarUrl,
    String? location,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final data = {
        'id': userId,
        'nickname': nickname,
        'avatar_url': avatarUrl,
        'location': location,
        'updated_at': now,
      };

      final response = await supabase
          .from(tableName)
          .upsert(data)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      log('Error upserting profile: $e');
      return null;
    }
  }

  /// 닉네임 업데이트
  Future<bool> updateNickname(String nickname) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return false;

      await supabase
          .from(tableName)
          .update({
            'nickname': nickname,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      return true;
    } catch (e) {
      log('Error updating nickname: $e');
      return false;
    }
  }

  /// 프로필 전체 업데이트
  Future<bool> updateProfile({
    String? nickname,
    String? avatarUrl,
    String? location,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return false;

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (nickname != null) updateData['nickname'] = nickname;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (location != null) updateData['location'] = location;

      await supabase
          .from(tableName)
          .update(updateData)
          .eq('id', user.id);

      return true;
    } catch (e) {
      log('Error updating profile: $e');
      return false;
    }
  }

  /// 위치 정보 업데이트
  Future<bool> updateLocation(String? location) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return false;

      await supabase
          .from(tableName)
          .update({
            'location': location,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      return true;
    } catch (e) {
      log('Error updating location: $e');
      return false;
    }
  }

  /// 프로필 생성 (새 사용자 가입시)
  Future<Profile?> createProfile({
    required String userId,
    String? nickname,
    String? avatarUrl,
    String? location,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final data = {
        'id': userId,
        'nickname': nickname ?? 'User',
        'avatar_url': avatarUrl,
        'location': location,
        'created_at': now,
        'updated_at': now,
      };

      final response = await supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      log('Error creating profile: $e');
      return null;
    }
  }
}