import 'dart:developer';

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';
import '../../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _chatNotifications = true;
  bool _marketingNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNotificationSection(),
            _buildDivider(),
            _buildAccountSection(context),
            _buildDivider(),
            _buildAppSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.marginMedium),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Text(
              '알림 설정',
              style: AppTextStyles.subtitle1,
            ),
          ),
          _buildSwitchTile(
            title: '푸시 알림',
            subtitle: '새로운 메시지와 업데이트를 받습니다',
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          _buildMenuDivider(),
          _buildSwitchTile(
            title: '채팅 알림',
            subtitle: '새로운 채팅 메시지 알림을 받습니다',
            value: _chatNotifications,
            onChanged: (value) {
              setState(() {
                _chatNotifications = value;
              });
            },
          ),
          _buildMenuDivider(),
          _buildSwitchTile(
            title: '마케팅 알림',
            subtitle: '이벤트 및 프로모션 정보를 받습니다',
            value: _marketingNotifications,
            onChanged: (value) {
              setState(() {
                _marketingNotifications = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Text(
              '계정',
              style: AppTextStyles.subtitle1,
            ),
          ),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: '개인정보 수정',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('개인정보 수정 기능')),
              );
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: '비밀번호 변경',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('비밀번호 변경 기능')),
              );
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.security,
            title: '개인정보 처리방침',
            onTap: () {
              _showPrivacyPolicy(context);
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.description,
            title: '이용약관',
            onTap: () {
              _showTermsOfService(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.marginMedium),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Text(
              '앱 정보',
              style: AppTextStyles.subtitle1,
            ),
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: '앱 버전',
            subtitle: '1.0.0',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('최신 버전입니다')),
              );
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.star_outline,
            title: '앱 평가하기',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('앱 평가 기능')),
              );
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.share,
            title: '앱 공유하기',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('앱 공유 기능')),
              );
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: '로그아웃',
            textColor: AppColors.error,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingSmall,
      ),
      title: Text(
        title,
        style: AppTextStyles.subtitle2,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
        activeThumbColor: Colors.white,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingSmall,
      ),
      leading: Icon(
        icon,
        color: textColor ?? AppColors.textSecondary,
        size: AppDimensions.iconMedium,
      ),
      title: Text(
        title,
        style: AppTextStyles.subtitle2.copyWith(
          color: textColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: Icon(
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

  Widget _buildDivider() {
    return const SizedBox(height: AppDimensions.spacingMedium);
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보 처리방침'),
        content: const SingleChildScrollView(
          child: Text(
            'CycleLink는 사용자의 개인정보를 소중히 여기며, 개인정보보호법을 준수합니다.\n\n'
            '1. 수집하는 개인정보 항목\n'
            '- 회원가입 시: 이메일, 닉네임, 위치정보\n'
            '- 서비스 이용 시: 거래내역, 채팅내용\n\n'
            '2. 개인정보의 이용목적\n'
            '- 서비스 제공 및 운영\n'
            '- 고객 상담 및 불만 처리\n\n'
            '3. 개인정보의 보유 및 이용기간\n'
            '- 회원탈퇴 시까지\n'
            '- 관련 법령에 따른 보존의무기간',
          ),
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

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이용약관'),
        content: const SingleChildScrollView(
          child: Text(
            'BikeMarket 서비스 이용약관\n\n'
            '제1조 (목적)\n'
            '이 약관은 BikeMarket이 제공하는 중고 자전거 거래 서비스의 이용조건 및 절차에 관한 사항을 규정함을 목적으로 합니다.\n\n'
            '제2조 (정의)\n'
            '1. "서비스"란 BikeMarket이 제공하는 중고 자전거 거래 플랫폼을 의미합니다.\n'
            '2. "회원"이란 이 약관에 따라 이용계약을 체결한 자를 의미합니다.\n\n'
            '제3조 (약관의 효력과 변경)\n'
            '1. 이 약관은 서비스를 이용하고자 하는 모든 회원에 대하여 그 효력을 발생합니다.\n'
            '2. 회사는 필요시 이 약관을 변경할 수 있으며, 변경된 약관은 공지 후 효력을 발생합니다.',
          ),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // 바로 로그인 화면으로 이동
              Navigator.of(context).popUntil((route) => route.isFirst);
              // 백그라운드에서 로그아웃 처리
              _handleLogout(context);
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      log('Starting logout process...');
      await supabase.auth.signOut();
      log('Logout successful');
      
      // 스낵바는 표시하지 않음 (이미 로그인 화면으로 이동했기 때문)
    } catch (e) {
      log('Logout error: $e');
      // 에러 발생시에만 스낵바 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 실패: $e')),
        );
      }
    }
  }
}