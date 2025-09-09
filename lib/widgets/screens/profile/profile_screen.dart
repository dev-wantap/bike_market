import 'dart:developer';

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/profile.dart';
import '../../../data/services/profile_service.dart';
import '../../../main.dart';
import 'my_products_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  Profile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _profileService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('프로필'),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildStatsSection(),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        children: [
          // 아바타와 기본 정보
          Row(
            children: [
              CircleAvatar(
                radius: AppDimensions.avatarLarge / 2,
                backgroundColor: AppColors.primary,
                backgroundImage: _userProfile?.avatarUrl != null 
                    ? NetworkImage(_userProfile!.avatarUrl!) 
                    : null,
                child: _userProfile?.avatarUrl == null
                    ? Text(
                        (_userProfile?.nickname?.isNotEmpty == true
                            ? _userProfile!.nickname!.substring(0, 1).toUpperCase()
                            : supabase.auth.currentUser?.userMetadata?['full_name']?.toString().substring(0, 1).toUpperCase()
                            ?? supabase.auth.currentUser?.email?.substring(0, 1).toUpperCase()
                            ?? 'U'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppDimensions.spacingLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _userProfile?.nickname ?? 
                            supabase.auth.currentUser?.userMetadata?['full_name'] as String? ??
                            supabase.auth.currentUser?.email?.split('@').first ??
                            'User',
                            style: AppTextStyles.headline2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          ),
                          child: const Text(
                            '인증',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingSmall),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppDimensions.spacingXSmall),
                        Expanded(
                          child: Text(
                            _userProfile?.location ?? '위치 미설정',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXSmall),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: AppDimensions.spacingXSmall),
                        Text(
                          '가입일: ${_formatJoinDate(_userProfile?.createdAt)}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          // 프로필 편집 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showEditProfileDialog(context);
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('프로필 편집'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.marginMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('판매상품', '5'),
          _buildStatDivider(),
          _buildStatItem('구매상품', '12'),
          _buildStatDivider(),
          _buildStatItem('찜한상품', '8'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline2.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXSmall),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.divider,
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.store,
            title: '내 판매상품',
            subtitle: '판매 중인 상품과 판매 완료된 상품을 확인하세요',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyProductsScreen(),
                ),
              );
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            context,
            icon: Icons.favorite,
            title: '찜한 상품',
            subtitle: '관심 있는 상품들을 모아보세요',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            context,
            icon: Icons.history,
            title: '거래 내역',
            subtitle: '구매한 상품들의 거래 내역을 확인하세요',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('거래 내역 기능')),
              );
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: '고객센터',
            subtitle: '문의사항이나 도움이 필요하시면 연락주세요',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('고객센터 기능')),
              );
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: '앱 정보',
            subtitle: 'BikeMarket v1.0.0',
            onTap: () {
              _showAppInfoDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingSmall,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: AppDimensions.iconMedium,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.subtitle1,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textLight,
      ),
      onTap: onTap,
    );
  }

  Widget _buildMenuDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.divider,
      indent: AppDimensions.paddingLarge,
      endIndent: AppDimensions.paddingLarge,
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nicknameController = TextEditingController(
      text: _userProfile?.nickname ?? '',
    );
    final locationController = TextEditingController(
      text: _userProfile?.location ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 편집'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nicknameController,
              maxLength: 20,
              decoration: const InputDecoration(
                labelText: '닉네임',
                hintText: '3-20자, 한글/영문/숫자만 가능',
                helperText: '특수문자는 사용할 수 없습니다',
                counterText: '', // 글자수 카운터 숨김
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: '위치',
                hintText: '예: 서울 강남구',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => _updateProfile(
              context,
              nicknameController.text,
              locationController.text,
            ),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(
    BuildContext context,
    String nickname,
    String location,
  ) async {
    final trimmedNickname = nickname.trim();
    
    // 닉네임 유효성 검사
    if (trimmedNickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해주세요')),
      );
      return;
    }
    
    if (trimmedNickname.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임은 최소 3자 이상이어야 합니다')),
      );
      return;
    }
    
    if (trimmedNickname.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임은 최대 20자까지 가능합니다')),
      );
      return;
    }
    
    // 특수문자 및 이모지 체크 (기본적인 한글, 영문, 숫자, 공백만 허용)
    final nicknameRegex = RegExp(r'^[가-힣a-zA-Z0-9\s]+$');
    if (!nicknameRegex.hasMatch(trimmedNickname)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임은 한글, 영문, 숫자만 사용할 수 있습니다')),
      );
      return;
    }

    try {
      // ProfileService의 통합 업데이트 메서드 사용
      final success = await _profileService.updateProfile(
        nickname: trimmedNickname,
        location: location.trim().isEmpty ? null : location.trim(),
      );
      
      if (!success) {
        throw Exception('프로필 업데이트에 실패했습니다');
      }
      
      // 프로필 다시 로드
      await _loadUserProfile();
      
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 수정되었습니다')),
        );
      }
    } catch (e) {
      log('Error updating profile: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 수정 실패: $e')),
        );
      }
    }
  }

  String _formatJoinDate(DateTime? createdAt) {
    if (createdAt == null) return '날짜 정보 없음';
    
    final year = createdAt.year;
    final month = createdAt.month;
    
    return '$year년 ${month}월';
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.pedal_bike,
              color: AppColors.primary,
              size: AppDimensions.iconLarge,
            ),
            const SizedBox(width: AppDimensions.spacingSmall),
            const Text('BikeMarket'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('버전: 1.0.0'),
            SizedBox(height: AppDimensions.spacingSmall),
            Text('중고 자전거 거래 플랫폼'),
            SizedBox(height: AppDimensions.spacingSmall),
            Text('© 2024 BikeMarket. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}