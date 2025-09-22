import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/dummy_data.dart';
import '../../../data/models/product.dart';
import '../../../data/services/product_service.dart';
import '../../../data/services/favorite_service.dart';
import '../../common/custom_app_bar.dart';
import '../../common/product_card.dart';
import '../../common/category_item.dart';
import '../search/search_screen.dart';
import '../product_detail/product_detail_screen.dart';
import '../category_products/category_products_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onRefresh;

  const HomeScreen({super.key, this.onRefresh});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// GlobalKey를 위한 타입 정의
typedef HomeScreenState = _HomeScreenState;

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _popularProducts = [];
  List<Product> _recentProducts = [];
  bool _isLoadingPopular = true;
  bool _isLoadingRecent = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void refreshData() {
    log('HomeScreen.refreshData called');
    _handleRefresh();
  }

  Future<void> _fetchData() async {
    try {
      final popularFuture = ProductService.getPopularProducts();
      final recentFuture = ProductService.getRecentProducts();

      final popular = await popularFuture;
      final recent = await recentFuture;

      // 찜 상태 업데이트
      final updatedPopular = await _updateFavoriteStatus(popular);
      final updatedRecent = await _updateFavoriteStatus(recent);

      if (mounted) {
        setState(() {
          _popularProducts = updatedPopular;
          _recentProducts = updatedRecent;
          _isLoadingPopular = false;
          _isLoadingRecent = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _popularProducts = DummyData.popularProducts;
          _recentProducts = DummyData.recentProducts;
          _isLoadingPopular = false;
          _isLoadingRecent = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    // 최소 지연시간을 보장하여 애니메이션이 자연스럽게 보이도록 함
    final futures = [
      _fetchDataWithoutLoading(),
      Future.delayed(const Duration(milliseconds: 500)), // 최소 500ms 지연
    ];

    await Future.wait(futures);
  }

  Future<void> _fetchDataWithoutLoading() async {
    try {
      final popularFuture = ProductService.getPopularProducts();
      final recentFuture = ProductService.getRecentProducts();

      final popular = await popularFuture;
      final recent = await recentFuture;

      // 찜 상태 업데이트
      final updatedPopular = await _updateFavoriteStatus(popular);
      final updatedRecent = await _updateFavoriteStatus(recent);

      if (mounted) {
        setState(() {
          _popularProducts = updatedPopular;
          _recentProducts = updatedRecent;
          _isLoadingPopular = false;
          _isLoadingRecent = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _popularProducts = DummyData.popularProducts;
          _recentProducts = DummyData.recentProducts;
          _isLoadingPopular = false;
          _isLoadingRecent = false;
        });
      }
    }
  }

  Future<List<Product>> _updateFavoriteStatus(List<Product> products) async {
    final updatedProducts = <Product>[];
    for (final product in products) {
      final isFavorite = await FavoriteService.isFavorite(product.id);
      updatedProducts.add(product.copyWith(isFavorite: isFavorite));
    }
    return updatedProducts;
  }

  Future<void> _toggleFavorite(Product product) async {
    try {
      if (product.isFavorite) {
        await FavoriteService.removeFavorite(product.id);
      } else {
        await FavoriteService.addFavorite(product.id);
      }

      // 상태 업데이트
      setState(() {
        // 인기 상품 목록에서 해당 상품 찾아서 업데이트
        final popularIndex = _popularProducts.indexWhere((p) => p.id == product.id);
        if (popularIndex != -1) {
          _popularProducts[popularIndex] = _popularProducts[popularIndex].copyWith(
            isFavorite: !product.isFavorite,
          );
        }

        // 최신 상품 목록에서 해당 상품 찾아서 업데이트
        final recentIndex = _recentProducts.indexWhere((p) => p.id == product.id);
        if (recentIndex != -1) {
          _recentProducts[recentIndex] = _recentProducts[recentIndex].copyWith(
            isFavorite: !product.isFavorite,
          );
        }
      });
    } catch (e) {
      log('Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(product.isFavorite ? '찜 해제에 실패했습니다.' : '찜하기에 실패했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.home(
        onSearchTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const SearchScreen()));
        },
        onNotificationTap: () {
          // Handle notification tap
        },
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBannerCarousel(),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildCategorySection(),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildPopularSection(context),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildRecentSection(context),
              const SizedBox(height: AppDimensions.spacingLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    final banners = [
      _BannerItem(
        title: '새로운 자전거를 찾고 계신가요?',
        subtitle: '다양한 브랜드의 중고 자전거를 만나보세요',
        color: AppColors.primary,
      ),
      _BannerItem(
        title: '안전한 거래를 위한 채팅',
        subtitle: '판매자와 직접 소통하며 거래하세요',
        color: AppColors.secondary,
      ),
      _BannerItem(
        title: '내 자전거도 판매해보세요',
        subtitle: '간편하게 등록하고 빠르게 판매하세요',
        color: AppColors.warning,
      ),
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false,
      ),
      items: banners.map((banner) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: banner.color,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  style: AppTextStyles.headline3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                Text(
                  banner.subtitle,
                  style: AppTextStyles.body2.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
          ),
          child: Text('카테고리', style: AppTextStyles.headline3),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // 5열로 변경
            childAspectRatio: 0.8, // 비율 조정
            crossAxisSpacing: AppDimensions.spacingSmall,
            mainAxisSpacing: AppDimensions.spacingMedium,
          ),
          itemCount: DummyData.categories.length,
          itemBuilder: (context, index) {
            final category = DummyData.categories[index];
            return CategoryItem(
              category: category,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryProductsScreen(category: category),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPopularSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('인기 상품', style: AppTextStyles.headline3),
              TextButton(
                onPressed: () {
                  // Handle see more
                },
                child: Text(
                  '더보기',
                  style: AppTextStyles.body2.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        SizedBox(
          height: AppDimensions.productCardHeight + 20,
          child: _isLoadingPopular
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: _popularProducts.length,
                  itemBuilder: (context, index) {
                    final product = _popularProducts[index];
                    return Container(
                      margin: const EdgeInsets.only(
                        right: AppDimensions.marginMedium,
                      ),
                      child: ProductCard(
                        product: product,
                        type: ProductCardType.grid,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                productId: product.id,
                                onProductDeleted: _handleRefresh,
                              ),
                            ),
                          );
                        },
                        onFavorite: () => _toggleFavorite(product),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('최근 등록된 상품', style: AppTextStyles.headline3),
              TextButton(
                onPressed: () {
                  // Handle see more
                },
                child: Text(
                  '더보기',
                  style: AppTextStyles.body2.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        _isLoadingRecent
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentProducts.length,
                itemBuilder: (context, index) {
                  final product = _recentProducts[index];
                  return ProductCard(
                    product: product,
                    type: ProductCardType.list,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            productId: product.id,
                            onProductDeleted: _handleRefresh,
                          ),
                        ),
                      );
                    },
                    onFavorite: () => _toggleFavorite(product),
                  );
                },
              ),
      ],
    );
  }
}

class _BannerItem {
  final String title;
  final String subtitle;
  final Color color;

  _BannerItem({
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
