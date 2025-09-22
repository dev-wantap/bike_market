import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class FavoriteService {
  static final _supabase = Supabase.instance.client;

  /// 찜하기 추가
  static Future<void> addFavorite(String productId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final intId = int.tryParse(productId);
      if (intId == null) throw Exception('유효하지 않은 상품 ID입니다.');

      await _supabase.from('favorites').insert({
        'user_id': user.id,
        'product_id': intId,
      });

      log('Product added to favorites: $productId');
    } catch (e) {
      log('Error adding favorite: $e');
      throw Exception('찜하기에 실패했습니다.');
    }
  }

  /// 찜하기 해제
  static Future<void> removeFavorite(String productId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final intId = int.tryParse(productId);
      if (intId == null) throw Exception('유효하지 않은 상품 ID입니다.');

      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('product_id', intId);

      log('Product removed from favorites: $productId');
    } catch (e) {
      log('Error removing favorite: $e');
      throw Exception('찜 해제에 실패했습니다.');
    }
  }

  /// 찜한 상품 목록 조회 (JOIN 쿼리)
  static Future<List<Product>> getFavoriteProducts() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await _supabase
          .from('favorites')
          .select('''
            product_id,
            products!inner(
              id, title, price, description, image_urls, category, location,
              status, view_count, created_at, updated_at,
              profiles!products_seller_id_fkey(
                id, nickname, profile_image_url, location
              )
            )
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).map((item) {
        final productData = item['products'] as Map<String, dynamic>;
        return Product.fromJson(productData).copyWith(isFavorite: true);
      }).toList();
    } catch (e) {
      log('Error fetching favorite products: $e');
      return [];
    }
  }

  /// 특정 상품의 찜 상태 확인
  static Future<bool> isFavorite(String productId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      final intId = int.tryParse(productId);
      if (intId == null) return false;

      final response = await _supabase
          .from('favorites')
          .select('user_id')
          .eq('user_id', user.id)
          .eq('product_id', intId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      log('Error checking favorite status: $e');
      return false;
    }
  }

  /// 모든 찜 목록 삭제
  static Future<void> removeAllFavorites() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      await _supabase.from('favorites').delete().eq('user_id', user.id);

      log('All favorites removed for user: ${user.id}');
    } catch (e) {
      log('Error removing all favorites: $e');
      throw Exception('전체 찜 삭제에 실패했습니다.');
    }
  }

  /// 찜한 상품 개수 조회
  static Future<int> getFavoriteCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 0;
      }

      final response = await _supabase
          .from('favorites')
          .select('user_id')
          .eq('user_id', user.id)
          .count();

      return response.count;
    } catch (e) {
      log('Error getting favorite count: $e');
      return 0;
    }
  }
}
