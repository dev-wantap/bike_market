import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/product.dart';
import '../../../data/services/product_service.dart';
import '../../common/product_card.dart';
import '../product_detail/product_detail_screen.dart';

class SellerProductsScreen extends StatefulWidget {
  final Seller seller;

  const SellerProductsScreen({
    super.key,
    required this.seller,
  });

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSellerProducts();
  }

  Future<void> _fetchSellerProducts() async {
    try {
      final products = await ProductService.getProductsBySeller(
        widget.seller.id,
        limit: 50,
      );

      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.seller.nickname}의 상품'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? _buildEmptyState()
              : _buildProductList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            '등록된 상품이 없습니다',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            '${widget.seller.nickname}님이 등록한 상품이 없습니다.',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 판매자 정보 헤더
        Container(
          margin: const EdgeInsets.all(AppDimensions.marginMedium),
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
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
            children: [
              CircleAvatar(
                radius: AppDimensions.avatarMedium / 2,
                backgroundColor: AppColors.primary,
                child: Text(
                  widget.seller.nickname.isNotEmpty ? widget.seller.nickname[0] : '?',
                  style: AppTextStyles.subtitle1.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.seller.nickname,
                      style: AppTextStyles.subtitle1,
                    ),
                    const SizedBox(height: AppDimensions.spacingXSmall),
                    Text(
                      widget.seller.location,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                  vertical: AppDimensions.paddingXSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                ),
                child: Text(
                  '${_products.length}개 상품',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 상품 그리드
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.spacingMedium,
              mainAxisSpacing: AppDimensions.spacingMedium,
              childAspectRatio: 0.75,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return ProductCard(
                product: product,
                type: ProductCardType.grid,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        productId: product.id,
                        onProductDeleted: () {
                          // 상품이 삭제되면 목록에서 제거
                          setState(() {
                            _products.removeWhere((p) => p.id == product.id);
                          });
                        },
                      ),
                    ),
                  );
                },
                onFavorite: () {
                  // Handle favorite toggle
                },
              );
            },
          ),
        ),
      ],
    );
  }
}