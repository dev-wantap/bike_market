import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/dummy_data.dart';
import '../../common/product_card.dart';
import '../product_detail/product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteProducts = DummyData.favoriteProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('찜한 상품'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: favoriteProducts.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Row(
                    children: [
                      Text(
                        '찜한 상품 ${favoriteProducts.length}개',
                        style: AppTextStyles.subtitle1,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          _showDeleteAllDialog(context);
                        },
                        child: const Text('전체 삭제'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: AppDimensions.spacingMedium,
                      mainAxisSpacing: AppDimensions.spacingMedium,
                    ),
                    itemCount: favoriteProducts.length,
                    itemBuilder: (context, index) {
                      final product = favoriteProducts[index];
                      return ProductCard(
                        product: product,
                        type: ProductCardType.grid,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                productId: product.id,
                              ),
                            ),
                          );
                        },
                        onFavorite: () {
                          _showRemoveFavoriteDialog(context, product.title);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text(
            '찜한 상품이 없습니다',
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            '마음에 드는 상품을 찜해보세요',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textLight,
            ),
          ),
          ],
        ),
      ),
    );
  }

  void _showRemoveFavoriteDialog(BuildContext context, String productTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('찜 해제'),
        content: Text('$productTitle을(를) 찜 목록에서 제거하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('찜 목록에서 제거되었습니다')),
              );
            },
            child: const Text('제거'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('찜한 상품을 모두 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('모든 찜 상품이 삭제되었습니다')),
              );
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}