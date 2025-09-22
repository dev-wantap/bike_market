import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../data/services/favorite_service.dart';
import '../data/models/product.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<String> _favoriteProductIds = {};
  final Map<String, Product> _favoriteProducts = {};
  bool _isLoading = false;

  // Getters
  Set<String> get favoriteProductIds => _favoriteProductIds;
  List<Product> get favoriteProducts => _favoriteProducts.values.toList();
  bool get isLoading => _isLoading;
  int get favoriteCount => _favoriteProductIds.length;

  /// 특정 상품이 찜된 상태인지 확인
  bool isFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  /// 초기 찜 목록 로드
  Future<void> loadFavorites() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final products = await FavoriteService.getFavoriteProducts();

      _favoriteProductIds.clear();
      _favoriteProducts.clear();

      for (final product in products) {
        _favoriteProductIds.add(product.id);
        _favoriteProducts[product.id] = product;
      }

      log('Loaded ${_favoriteProductIds.length} favorite products');
    } catch (e) {
      log('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 찜하기 추가
  Future<bool> addFavorite(String productId, {Product? product}) async {
    try {
      await FavoriteService.addFavorite(productId);

      _favoriteProductIds.add(productId);
      if (product != null) {
        _favoriteProducts[productId] = product.copyWith(isFavorite: true);
      }

      notifyListeners();
      log('Added favorite: $productId');
      return true;
    } catch (e) {
      log('Error adding favorite: $e');
      return false;
    }
  }

  /// 찜하기 해제
  Future<bool> removeFavorite(String productId) async {
    try {
      await FavoriteService.removeFavorite(productId);

      _favoriteProductIds.remove(productId);
      _favoriteProducts.remove(productId);

      notifyListeners();
      log('Removed favorite: $productId');
      return true;
    } catch (e) {
      log('Error removing favorite: $e');
      return false;
    }
  }

  /// 찜하기 토글 (추가/제거)
  Future<bool> toggleFavorite(String productId, {Product? product}) async {
    if (isFavorite(productId)) {
      return await removeFavorite(productId);
    } else {
      return await addFavorite(productId, product: product);
    }
  }

  /// 모든 찜 목록 삭제
  Future<bool> removeAllFavorites() async {
    try {
      await FavoriteService.removeAllFavorites();

      _favoriteProductIds.clear();
      _favoriteProducts.clear();

      notifyListeners();
      log('Removed all favorites');
      return true;
    } catch (e) {
      log('Error removing all favorites: $e');
      return false;
    }
  }

  /// 특정 상품의 찜 상태를 서버에서 확인하고 동기화
  Future<void> syncFavoriteStatus(String productId) async {
    try {
      final isFav = await FavoriteService.isFavorite(productId);

      if (isFav && !_favoriteProductIds.contains(productId)) {
        _favoriteProductIds.add(productId);
        notifyListeners();
      } else if (!isFav && _favoriteProductIds.contains(productId)) {
        _favoriteProductIds.remove(productId);
        _favoriteProducts.remove(productId);
        notifyListeners();
      }
    } catch (e) {
      log('Error syncing favorite status: $e');
    }
  }

  /// Provider 상태 초기화 (로그아웃 시 사용)
  void clear() {
    _favoriteProductIds.clear();
    _favoriteProducts.clear();
    _isLoading = false;
    notifyListeners();
  }
}
