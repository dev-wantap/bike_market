import 'package:flutter/material.dart';
import '../../../core/constants/dimensions.dart';
import '../../../data/dummy_data.dart';
import '../../../data/models/category.dart';
import '../../../data/models/product.dart';
import '../../../data/services/product_service.dart';
import '../../common/product_card.dart';
import '../product_detail/product_detail_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Category category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoryProducts();
  }

  Future<void> _fetchCategoryProducts() async {
    try {
      final products = await ProductService.getProductsByCategory(widget.category.id);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to dummy data
      final products = DummyData.getProductsByCategory(widget.category.id);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(
                  child: Text('이 카테고리에는 아직 상품이 없습니다.'),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: AppDimensions.spacingMedium,
                    mainAxisSpacing: AppDimensions.spacingMedium,
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
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
