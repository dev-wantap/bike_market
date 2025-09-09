import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/dummy_data.dart';
import '../../common/product_card.dart';
import '../product_detail/product_detail_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 판매상품'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '판매중'),
            Tab(text: '판매완료'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductList(selling: true),
          _buildProductList(selling: false),
        ],
      ),
    );
  }

  Widget _buildProductList({required bool selling}) {
    // For demo, use first 3 products as selling, next 2 as sold
    final products = selling 
        ? DummyData.products.take(3).toList()
        : DummyData.products.skip(3).take(2).toList();

    if (products.isEmpty) {
      return _buildEmptyState(selling);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
          child: ProductCard(
            product: product,
            type: ProductCardType.list,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(productId: product.id),
                ),
              );
            },
            onFavorite: () {
              // Handle favorite
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool selling) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
          Icon(
            selling ? Icons.store_outlined : Icons.check_circle_outline,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text(
            selling ? '판매중인 상품이 없습니다' : '판매완료된 상품이 없습니다',
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            selling 
                ? '새로운 상품을 등록해보세요'
                : '판매된 상품이 여기에 표시됩니다',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textLight,
            ),
          ),
          if (selling) ...[
            const SizedBox(height: AppDimensions.spacingXLarge),
            ElevatedButton(
              onPressed: () {
                // Navigate to add product screen
                Navigator.of(context).pop();
                DefaultTabController.of(context)?.animateTo(2); // Add tab
              },
              child: const Text('상품 등록하기'),
            ),
          ],
          ],
        ),
      ),
    );
  }
}