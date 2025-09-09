import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/dummy_data.dart';
import '../../../data/models/product.dart';
import '../../../data/services/product_service.dart';
import '../../common/product_card.dart';
import '../product_detail/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Product> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  List<Product> _recentProducts = [];
  bool _isLoadingRecent = true;

  final List<String> _popularSearches = [
    '로드바이크',
    'MTB',
    '전기자전거',
    '접이식',
    '하이브리드',
    '시티바이크',
    'BMX',
    '자이언트',
    '트렉',
    'Specialized',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentProducts();
  }

  Future<void> _loadRecentProducts() async {
    try {
      final recent = await ProductService.getRecentProducts();
      setState(() {
        _recentProducts = recent;
        _isLoadingRecent = false;
      });
    } catch (e) {
      setState(() {
        _recentProducts = DummyData.popularProducts; // fallback
        _isLoadingRecent = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: _buildSearchBar(),
        automaticallyImplyLeading: false,
        actions: [
          if (_hasSearched)
            IconButton(
              onPressed: _showFilterModal,
              icon: const Icon(Icons.tune),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: '찾고 있는 자전거를 검색해보세요',
          hintStyle: AppTextStyles.body2.copyWith(
            color: AppColors.textLight,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          fillColor: AppColors.background,
          filled: true,
        ),
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          setState(() {});
        },
        onSubmitted: (value) {
          _performSearch(value);
        },
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasSearched) {
      return _buildInitialState();
    }

    if (_isSearching) {
      return _buildLoadingState();
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState();
    }

    return _buildSearchResults();
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '인기 검색어',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Wrap(
            spacing: AppDimensions.spacingSmall,
            runSpacing: AppDimensions.spacingSmall,
            children: _popularSearches.map((search) {
              return _buildSearchTag(search);
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.spacingXLarge),
          Text(
            '최근 본 상품',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          SizedBox(
            height: AppDimensions.productCardHeight + 20,
            child: _isLoadingRecent
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recentProducts.length,
                    itemBuilder: (context, index) {
                      final product = _recentProducts[index];
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
                          ),
                        ),
                      );
                    },
                    onFavorite: () {
                      // Handle favorite toggle
                    },
                  ),
                );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTag(String text) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        _performSearch(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          text,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppDimensions.spacingMedium),
          Text('검색 중...'),
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
            Icons.search_off,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text(
            '검색 결과가 없습니다',
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            '다른 검색어로 시도해보세요',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXLarge),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasSearched = false;
                _searchController.clear();
                _searchResults.clear();
              });
            },
            child: const Text('새로운 검색'),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '검색결과 ${_searchResults.length}개',
                style: AppTextStyles.subtitle1,
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // Handle sort
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('정렬'),
                        Icon(Icons.arrow_drop_down, size: 16),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _showFilterModal,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('필터'),
                        Icon(Icons.tune, size: 16),
                      ],
                    ),
                  ),
                ],
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
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
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
                  // Handle favorite toggle
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final results = await ProductService.searchProducts(query);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      // Fallback to dummy data on error
      final results = DummyData.products.where((product) {
        return product.title.toLowerCase().contains(query.toLowerCase()) ||
               product.description.toLowerCase().contains(query.toLowerCase()) ||
               _getCategoryName(product.category).toLowerCase().contains(query.toLowerCase());
      }).toList();

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    }

    _searchFocusNode.unfocus();
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _hasSearched = false;
      _searchResults.clear();
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '필터',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text(
              '카테고리',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Wrap(
              spacing: AppDimensions.spacingSmall,
              runSpacing: AppDimensions.spacingSmall,
              children: DummyData.categories.map((category) {
                return _buildFilterTag(category.name, false);
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text(
              '가격대',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Wrap(
              spacing: AppDimensions.spacingSmall,
              runSpacing: AppDimensions.spacingSmall,
              children: [
                _buildFilterTag('10만원 이하', false),
                _buildFilterTag('10-50만원', false),
                _buildFilterTag('50-100만원', false),
                _buildFilterTag('100만원 이상', false),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXLarge),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('초기화'),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('적용'),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTag(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.body2.copyWith(
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case 'road': return '로드바이크';
      case 'mtb': return 'MTB';
      case 'hybrid': return '하이브리드';
      case 'folding': return '접이식';
      case 'electric': return '전기자전거';
      case 'bmx': return 'BMX';
      case 'city': return '시티바이크';
      case 'kids': return '어린이용';
      default: return '기타';
    }
  }
}