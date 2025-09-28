import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';

class CustomerServiceScreen extends StatelessWidget {
  const CustomerServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '고객센터',
          style: AppTextStyles.headline3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          _buildContactSection(context),
          SizedBox(height: AppDimensions.marginLarge),
          _buildFAQSection(),
          SizedBox(height: AppDimensions.marginLarge),
          _buildHelpCategoriesSection(),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Icon(
                    Icons.support_agent,
                    color: AppColors.primary,
                    size: AppDimensions.iconMedium,
                  ),
                ),
                SizedBox(width: AppDimensions.marginMedium),
                Text(
                  '연락처 정보',
                  style: AppTextStyles.headline3,
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginLarge),
            _buildContactItem(
              context,
              icon: Icons.email_outlined,
              title: '이메일 문의',
              subtitle: 'support@cyclelink.co.kr',
              onTap: () => _launchEmail('support@bikemarket.com'),
            ),
            Divider(height: AppDimensions.marginLarge * 2),
            _buildContactItem(
              context,
              icon: Icons.phone_outlined,
              title: '전화 문의',
              subtitle: '1588-0000',
              onTap: () => _launchPhone('1588-0000'),
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              '운영시간: 평일 09:00 - 18:00 (주말, 공휴일 휴무)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: AppDimensions.iconSmall),
            SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.subtitle1),
                  Text(
                    subtitle,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textLight,
              size: AppDimensions.iconSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: AppColors.primary,
                    size: AppDimensions.iconMedium,
                  ),
                ),
                SizedBox(width: AppDimensions.marginMedium),
                Text(
                  '자주 묻는 질문',
                  style: AppTextStyles.headline3,
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginLarge),
            _buildFAQItem(
              '계정을 어떻게 만드나요?',
              '앱 하단의 프로필 탭에서 "로그인/회원가입" 버튼을 눌러 계정을 만들 수 있습니다.',
            ),
            _buildFAQItem(
              '상품은 어떻게 등록하나요?',
              '홈 화면의 + 버튼을 눌러 상품 사진, 제목, 가격, 설명을 입력하여 등록할 수 있습니다.',
            ),
            _buildFAQItem(
              '판매자와 어떻게 연락하나요?',
              '상품 상세페이지에서 "채팅하기" 버튼을 눌러 판매자와 직접 대화할 수 있습니다.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: AppTextStyles.subtitle1,
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppDimensions.paddingMedium,
            right: AppDimensions.paddingMedium,
            bottom: AppDimensions.paddingMedium,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpCategoriesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Icon(
                    Icons.category_outlined,
                    color: AppColors.primary,
                    size: AppDimensions.iconMedium,
                  ),
                ),
                SizedBox(width: AppDimensions.marginMedium),
                Text(
                  '도움말 카테고리',
                  style: AppTextStyles.headline3,
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginLarge),
            _buildCategoryItem(
              icon: Icons.person_outline,
              title: '계정 관리',
              description: '회원가입, 로그인, 프로필 수정',
            ),
            _buildCategoryItem(
              icon: Icons.shopping_cart_outlined,
              title: '거래 관련',
              description: '상품 등록, 구매/판매, 결제',
            ),
            _buildCategoryItem(
              icon: Icons.settings_outlined,
              title: '기술 지원',
              description: '앱 사용법, 오류 해결',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: AppDimensions.iconSmall),
          SizedBox(width: AppDimensions.marginMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle1),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'BikeMarket 문의사항'},
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}