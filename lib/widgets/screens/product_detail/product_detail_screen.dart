import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/product.dart';
import '../../../data/services/product_service.dart';
import '../../common/custom_app_bar.dart';
import '../../common/product_card.dart';
import '../chat/chat_room_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _isDescriptionExpanded = false;
  Product? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final product = await ProductService.getProductDetails(widget.productId);
      setState(() {
        _product = product;
        _isFavorite = product.isFavorite;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.detail(
        onBackPressed: () => Navigator.of(context).pop(),
        onSharePressed: () {
          // Handle share
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('공유 기능')),
          );
        },
        onMorePressed: () {
          _showMoreMenu(context);
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: AppColors.error),
                      const SizedBox(height: AppDimensions.spacingMedium),
                      Text(_error!, style: AppTextStyles.body2),
                      const SizedBox(height: AppDimensions.spacingMedium),
                      ElevatedButton(
                        onPressed: _fetchProductDetails,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : _product == null
                  ? const Center(child: Text('상품을 찾을 수 없습니다'))
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildImageSlider(),
                                const SizedBox(height: AppDimensions.spacingMedium),
                                _buildProductInfo(),
                                const SizedBox(height: AppDimensions.spacingLarge),
                                _buildSellerInfo(),
                                const SizedBox(height: AppDimensions.spacingLarge),
                                _buildOtherProducts(),
                                const SizedBox(height: AppDimensions.spacingXXLarge),
                              ],
                            ),
                          ),
                        ),
                        _buildBottomActions(),
                      ],
                    ),
    );
  }

  Widget _buildImageSlider() {
    // For demo, we'll show placeholder images
    final imageCount = _product!.images.isNotEmpty ? _product!.images.length : 3;
    
    return Container(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            controller: _imagePageController,
            itemCount: imageCount,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              // Check if product has images and show actual images
              if (_product!.images.isNotEmpty && index < _product!.images.length) {
                return CachedNetworkImage(
                  imageUrl: _product!.images[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.border,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.border,
                    child: const Icon(
                      Icons.pedal_bike,
                      color: AppColors.primary,
                      size: 80,
                    ),
                  ),
                );
              } else {
                // Fallback to placeholder icon
                return Container(
                  width: double.infinity,
                  color: AppColors.border,
                  child: const Icon(
                    Icons.pedal_bike,
                    color: AppColors.primary,
                    size: 80,
                  ),
                );
              }
            },
          ),
          // Page indicators
          Positioned(
            bottom: AppDimensions.paddingMedium,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imageCount,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.marginXSmall,
                  ),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white54,
                  ),
                ),
              ),
            ),
          ),
          // Image counter
          Positioned(
            top: AppDimensions.paddingMedium,
            right: AppDimensions.paddingMedium,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
                vertical: AppDimensions.paddingXSmall,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: Text(
                '${_currentImageIndex + 1} / $imageCount',
                style: AppTextStyles.caption.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _product!.title,
            style: AppTextStyles.headline2,
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            _formatPrice(_product!.price),
            style: AppTextStyles.price.copyWith(fontSize: 24),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          _buildProductTags(),
          const SizedBox(height: AppDimensions.spacingMedium),
          _buildDescription(),
          const SizedBox(height: AppDimensions.spacingMedium),
          _buildProductDetails(),
        ],
      ),
    );
  }

  Widget _buildProductTags() {
    return Wrap(
      spacing: AppDimensions.spacingSmall,
      runSpacing: AppDimensions.spacingSmall,
      children: [
        _buildTag('카테고리: ${_getCategoryName(_product!.category)}'),
        _buildTag('등록: ${_formatTimeAgo(_product!.createdAt)}'),
        _buildTag('위치: ${_product!.location}'),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: AppDimensions.paddingXSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상품 설명',
          style: AppTextStyles.subtitle1,
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _isDescriptionExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            _product!.description,
            style: AppTextStyles.body2,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            _product!.description,
            style: AppTextStyles.body2,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        GestureDetector(
          onTap: () {
            setState(() {
              _isDescriptionExpanded = !_isDescriptionExpanded;
            });
          },
          child: Text(
            _isDescriptionExpanded ? '접기' : '더보기',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          _buildDetailRow('상품 상태', '상태 양호'),
          _buildDetailRow('거래 방식', '직거래, 택배거래'),
          _buildDetailRow('배송비', '별도'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.marginMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppDimensions.avatarMedium / 2,
                backgroundColor: AppColors.primary,
                child: Text(
                  _product!.seller.nickname[0],
                  style: AppTextStyles.subtitle1.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _product!.seller.nickname,
                      style: AppTextStyles.subtitle1,
                    ),
                    const SizedBox(height: AppDimensions.spacingXSmall),
                    Text(
                      _product!.seller.location,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  // Handle view other products
                },
                child: const Text('다른 판매상품 보기'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtherProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
          ),
          child: Text(
            '이 판매자의 다른 상품',
            style: AppTextStyles.headline3,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        SizedBox(
          height: AppDimensions.productCardHeight + 20,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: 3, // Show 3 other products
            itemBuilder: (context, index) {
              // For demo, we'll use the same product with modified titles
              final otherProduct = _product!.copyWith(
                id: 'other_${index}',
                title: '${_product!.seller.nickname}의 다른 자전거 ${index + 1}',
              );
              
              return Container(
                margin: const EdgeInsets.only(
                  right: AppDimensions.marginMedium,
                ),
                child: ProductCard(
                  product: otherProduct,
                  type: ProductCardType.grid,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          productId: otherProduct.id,
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
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingMedium,
        right: AppDimensions.paddingMedium,
        top: AppDimensions.paddingMedium,
        bottom: AppDimensions.paddingMedium + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? AppColors.error : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMedium),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(
                      product: _product!,
                      otherUser: _product!.seller,
                    ),
                  ),
                );
              },
              child: const Text('채팅하기'),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('신고하기'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('신고가 접수되었습니다')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('이 판매자 차단'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('판매자를 차단했습니다')),
                );
              },
            ),
          ],
        ),
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