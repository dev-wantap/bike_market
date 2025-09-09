import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  static final _supabase = Supabase.instance.client;

  static Future<List<Product>> getRecentProducts({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('products')
          .select(
            '*, profiles!products_seller_id_fkey(nickname, profile_image_url, location)',
          )
          .eq('status', 'selling')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      log('Error fetching recent products: $e');
      return [];
    }
  }

  static Future<List<Product>> getPopularProducts({int limit = 6}) async {
    try {
      final response = await _supabase
          .from('products')
          .select(
            '*, profiles!products_seller_id_fkey(nickname, profile_image_url, location)',
          )
          .eq('status', 'selling')
          .order('view_count', ascending: false)
          .limit(limit);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      log('Error fetching popular products: $e');
      return [];
    }
  }

  static Future<Product> getProductDetails(String productId) async {
    try {
      // productId가 숫자인지 확인
      final id = int.tryParse(productId);
      if (id == null) {
        throw Exception('유효하지 않은 상품 ID입니다.');
      }

      final response = await _supabase
          .from('products')
          .select('*, profiles!products_seller_id_fkey(*)')
          .eq('id', id)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      log('Error fetching product details: $e');
      throw Exception('상품 정보를 불러올 수 없습니다.');
    }
  }

  static Future<List<Product>> getProductsByCategory(
    String category, {
    int limit = 20,
  }) async {
    try {
      final response = await _supabase
          .from('products')
          .select(
            '*, profiles!products_seller_id_fkey(nickname, profile_image_url, location)',
          )
          .eq('status', 'selling')
          .eq('category', category)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      log('Error fetching products by category: $e');
      return [];
    }
  }

  static Future<List<Product>> searchProducts(
    String query, {
    int limit = 20,
  }) async {
    try {
      final response = await _supabase
          .from('products')
          .select(
            '*, profiles!products_seller_id_fkey(nickname, profile_image_url, location)',
          )
          .eq('status', 'selling')
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      log('Error searching products: $e');
      return [];
    }
  }

  static Future<List<Product>> getProductsByCurrentUser({
    String? status,
    int limit = 50,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      var query = _supabase
          .from('products')
          .select(
            '*, profiles!products_seller_id_fkey(nickname, profile_image_url, location)',
          )
          .eq('seller_id', user.id);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      log('Error fetching user products: $e');
      return [];
    }
  }

  static Future<void> updateProduct(Product product) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      await _supabase
          .from('products')
          .update({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'category': product.category,
            'location': product.location,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', product.id)
          .eq('seller_id', user.id);

      log('Product updated successfully: ${product.id}');
    } catch (e) {
      log('Error updating product: $e');
      throw Exception('상품 정보를 수정할 수 없습니다.');
    }
  }

  static Future<void> deleteProduct(String productId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // productId가 숫자인지 확인
      final id = int.tryParse(productId);
      if (id == null) {
        throw Exception('유효하지 않은 상품 ID입니다.');
      }

      await _supabase
          .from('products')
          .delete()
          .eq('id', id)
          .eq('seller_id', user.id);

      log('Product deleted successfully: $productId');
    } catch (e) {
      log('Error deleting product: $e');
      throw Exception('상품을 삭제할 수 없습니다.');
    }
  }
}
