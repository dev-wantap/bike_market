import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../data/models/product.dart';
import '../../../providers/favorite_provider.dart';
import '../../common/product_card.dart';
import '../../common/loading_button.dart';
import '../product_detail/product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isClearingAll = false;

  @override
  void initState() {
    super.initState();
    // FavoriteProvider에서 데이터를 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final favoriteProvider = context.read<FavoriteProvider>();
      if (favoriteProvider.favoriteProducts.isEmpty && !favoriteProvider.isLoading) {
        favoriteProvider.loadFavorites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        if (favoriteProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('찜한 상품'),
              backgroundColor: AppColors.surface,
              elevation: 0,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final favoriteProducts = favoriteProvider.favoriteProducts;

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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                          _toggleFavorite(context, product);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border,
              size: 80, color: AppColors.textLight),
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
            style: AppTextStyles.body2.copyWith(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context, Product product) async {
    final favoriteProvider = context.read<FavoriteProvider>();
    final success =
        await favoriteProvider.toggleFavorite(product.id, product: product);
    if (mounted) {
      if (success) {
        FeedbackHelper.showFavoriteRemoved(context);
      } else {
        FeedbackHelper.showFavoriteError(context, '찜 해제');
      }
    }
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('찜한 상품을 모두 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          LoadingButton(
            isLoading: _isClearingAll,
            onPressed: () async {
              await _removeAllFavorites(context);
              if (mounted) {
                Navigator.pop(dialogContext);
              }
            },
            text: '삭제',
          ),
        ],
      ),
    );
  }

  Future<void> _removeAllFavorites(BuildContext context) async {
    setState(() {
      _isClearingAll = true;
    });

    final favoriteProvider = context.read<FavoriteProvider>();
    final success = await favoriteProvider.removeAllFavorites();

    if (mounted) {
      if (success) {
        FeedbackHelper.showSuccess(context, '모든 찜 상품이 삭제되었습니다.');
      } else {
        FeedbackHelper.showError(context, '전체 삭제에 실패했습니다.');
      }
      setState(() {
        _isClearingAll = false;
      });
    }
  }
}
