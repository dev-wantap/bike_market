import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/product.dart';
import '../../../data/services/favorite_service.dart';
import '../../common/product_card.dart';
import '../product_detail/product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteProducts();
  }

  Future<void> _fetchFavoriteProducts() async {
    try {
      final products = await FavoriteService.getFavoriteProducts();
      if (mounted) {
        setState(() {
          _favoriteProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching favorite products: $e');
      if (mounted) {
        setState(() {
          _favoriteProducts = [];
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
          title: const Text('찜한 상품'),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('찜한 상품'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _favoriteProducts.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Row(
                    children: [
                      Text(
                        '찜한 상품 ${_favoriteProducts.length}개',
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
                    itemCount: _favoriteProducts.length,
                    itemBuilder: (context, index) {
                      final product = _favoriteProducts[index];
                      return ProductCard(
                        product: product,
                        type: ProductCardType.grid,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                productId: product.id,
                                onProductDeleted: _fetchFavoriteProducts,
                              ),
                            ),
                          );
                        },
                        onFavorite: () {
                          _showRemoveFavoriteDialog(context, product);
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
            Icon(Icons.favorite_border, size: 80, color: AppColors.textLight),
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
      ),
    );
  }

  void _showRemoveFavoriteDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('찜 해제'),
        content: Text('${product.title}을(를) 찜 목록에서 제거하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _removeFavorite(product);
            },
            child: const Text('제거'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFavorite(Product product) async {
    try {
      await FavoriteService.removeFavorite(product.id);
      setState(() {
        _favoriteProducts.removeWhere((p) => p.id == product.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('찜 목록에서 제거되었습니다')),
        );
      }
    } catch (e) {
      log('Error removing favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('찜 해제에 실패했습니다'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
            onPressed: () async {
              Navigator.pop(context);
              await _removeAllFavorites();
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeAllFavorites() async {
    try {
      await FavoriteService.removeAllFavorites();
      setState(() {
        _favoriteProducts.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 찜 상품이 삭제되었습니다')),
        );
      }
    } catch (e) {
      log('Error removing all favorites: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('전체 삭제에 실패했습니다'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
