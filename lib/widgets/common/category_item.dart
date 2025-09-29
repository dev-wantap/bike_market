import 'package:flutter/material.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/text_styles.dart';
import '../../data/models/category.dart';

class CategoryItem extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryItem({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 사용 가능한 너비에서 아이콘 컨테이너 크기 계산
          final availableWidth = constraints.maxWidth;
          final iconContainerSize = availableWidth * 0.8; // 너비의 85%를 아이콘 컨테이너로 사용
          final iconSize = iconContainerSize * 0.55; // 컨테이너 크기의 55%를 아이콘 크기로 사용

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: category.color.withAlpha(26),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: iconSize,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              Flexible(
                child: Text(
                  category.name,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
