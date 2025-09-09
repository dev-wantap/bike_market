import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/text_styles.dart';

enum AppBarType { home, detail, simple }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarType type;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onMorePressed;

  const CustomAppBar({
    super.key,
    this.type = AppBarType.simple,
    this.title,
    this.leading,
    this.actions,
    this.onSearchTap,
    this.onNotificationTap,
    this.onBackPressed,
    this.onSharePressed,
    this.onMorePressed,
  });

  const CustomAppBar.home({
    super.key,
    this.onSearchTap,
    this.onNotificationTap,
  })  : type = AppBarType.home,
        title = null,
        leading = null,
        actions = null,
        onBackPressed = null,
        onSharePressed = null,
        onMorePressed = null;

  const CustomAppBar.detail({
    super.key,
    this.onBackPressed,
    this.onSharePressed,
    this.onMorePressed,
  })  : type = AppBarType.detail,
        title = null,
        leading = null,
        actions = null,
        onSearchTap = null,
        onNotificationTap = null;

  const CustomAppBar.simple({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  })  : type = AppBarType.simple,
        onSearchTap = null,
        onNotificationTap = null,
        onBackPressed = null,
        onSharePressed = null,
        onMorePressed = null;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AppBarType.home:
        return _buildHomeAppBar(context);
      case AppBarType.detail:
        return _buildDetailAppBar(context);
      case AppBarType.simple:
        return _buildSimpleAppBar(context);
    }
  }

  Widget _buildHomeAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Row(
        children: [
          const Icon(
            Icons.pedal_bike,
            color: AppColors.primary,
            size: AppDimensions.iconLarge,
          ),
          const SizedBox(width: AppDimensions.spacingSmall),
          Text(
            'CycleLink',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onSearchTap,
          icon: const Icon(
            Icons.search,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: onNotificationTap,
          icon: Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
      ],
    );
  }

  Widget _buildDetailAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onSharePressed,
          icon: const Icon(
            Icons.share,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: onMorePressed,
          icon: const Icon(
            Icons.more_vert,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: leading,
      title: title != null
          ? Text(
              title!,
              style: AppTextStyles.headline3,
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);
}