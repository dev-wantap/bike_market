import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  const ProductCard({
    super.key,
    required this.product,
    this.type = ProductCardType.grid,
    this.onTap,
    this.onFavorite,
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
      child: Hero(
        tag: 'product_${type.toString()}_${product.id}', // 1. Fix Hero tag
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: AppDimensions.productCardWidth,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                        Expanded( // 2. Fix Overflow by wrapping title in Expanded
                          child: Text(
                            product.title,
                            style: AppTextStyles.subtitle2,
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusMedium),
                bottomLeft: Radius.circular(AppDimensions.radiusMedium),
              ),
              child: SizedBox(
                width: 120,
                height: 100,
                child: _buildImageContent(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        GestureDetector(
                          onTap: onFavorite,
                          child: Icon(
                            product.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: product.isFavorite
                                ? AppColors.error
                                : AppColors.textSecondary,
                            size: AppDimensions.iconSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingSmall),
                    Text(
                      _formatPrice(product.price),
                      style: AppTextStyles.price,
                    ),
                    const SizedBox(height: AppDimensions.spacingXSmall),
                    Text(
                      product.location,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacingXSmall),
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
            child: GestureDetector(
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
                child: Icon(
                  product.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: product.isFavorite
                      ? AppColors.error
                      : AppColors.textSecondary,
                  size: AppDimensions.iconSmall,
                ),
              ),
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

    // For now, we'll use placeholder images
    // In a real app, this would use CachedNetworkImage
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.border,
      child: const Icon(
        Icons.pedal_bike,
        color: AppColors.primary,
        size: AppDimensions.iconLarge,
      ),
    );
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
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