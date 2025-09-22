import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/text_styles.dart';
import '../../data/models/product.dart';

enum ProductCardType { grid, list }

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductCardType type;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavoriteLoading;
  final Widget? trailing;

  const ProductCard({
    super.key,
    required this.product,
    this.type = ProductCardType.grid,
    this.onTap,
    this.onFavorite,
    this.isFavoriteLoading = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return type == ProductCardType.grid
        ? _buildGridCard(context)
        : _buildListCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: AppDimensions.productCardWidth,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
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
              _buildImage(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        // 2. Fix Overflow by wrapping title in Expanded
                        child: Text(
                          product.title,
                          style: AppTextStyles.subtitle2.copyWith(
                            height: 1.2, // 이 부분 추가
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXSmall),
                      Text(
                        _formatPrice(product.price),
                        style: AppTextStyles.priceSmall,
                      ),
                      const SizedBox(height: AppDimensions.spacingXSmall),
                      Text(
                        product.location,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.marginMedium,
          vertical: AppDimensions.marginSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusMedium),
                  bottomLeft: Radius.circular(AppDimensions.radiusMedium),
                ),
                child: SizedBox(
                  width: 120,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: _buildImageContent(),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // 상단: 제목 + 찜 버튼
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              style: AppTextStyles.subtitle1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (trailing != null)
                            trailing!
                          else
                            Consumer<FavoriteProvider>(
                              builder: (context, favoriteProvider, child) {
                                final isFavorite = favoriteProvider.isFavorite(product.id);
                                return GestureDetector(
                                  onTap: onFavorite,
                                  child: isFavoriteLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorite
                                              ? AppColors.error
                                              : AppColors.textSecondary,
                                          size: AppDimensions.iconSmall,
                                        ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 중단: 가격
                      Text(
                        _formatPrice(product.price),
                        style: AppTextStyles.price,
                      ),
                      const SizedBox(height: 4),
                      // 위치 정보
                      Text(
                        product.location,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // 하단: 등록 시간
                      Text(
                        _formatTimeAgo(product.createdAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: AppDimensions.productImageHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusMedium),
          topRight: Radius.circular(AppDimensions.radiusMedium),
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusMedium),
              topRight: Radius.circular(AppDimensions.radiusMedium),
            ),
            child: _buildImageContent(),
          ),
          Positioned(
            top: AppDimensions.paddingSmall,
            right: AppDimensions.paddingSmall,
            child: Consumer<FavoriteProvider>(
              builder: (context, favoriteProvider, child) {
                final isFavorite = favoriteProvider.isFavorite(product.id);
                return GestureDetector(
                  onTap: onFavorite,
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingXSmall),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isFavoriteLoading
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? AppColors.error
                              : AppColors.textSecondary,
                          size: AppDimensions.iconSmall,
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (product.images.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.border,
        child: const Icon(
          Icons.image,
          color: AppColors.textLight,
          size: AppDimensions.iconLarge,
        ),
      );
    }

    // 실제 네트워크 이미지 로드
    return CachedNetworkImage(
      imageUrl: product.images.first,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.border,
        child: const Icon(
          Icons.pedal_bike,
          color: AppColors.primary,
          size: AppDimensions.iconLarge,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.border,
        child: const Icon(
          Icons.broken_image,
          color: AppColors.error,
          size: AppDimensions.iconLarge,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
