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
            'image_urls': product.images, // 이미지 URL 업데이트 추가
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

  static Future<List<Product>> getProductsBySeller(
    String sellerId, {
    int limit = 20,
  }) async {
    try {
      final response = await _supabase
          .from('products')
          .select(
            '*, profiles!products_seller_id_fkey(nickname, profile_image_url, location)',
          )
          .eq('status', 'selling')
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      log('Error fetching products by seller: $e');
      return [];
    }
  }

  static Future<List<Product>> getOtherProductsBySeller(
    String sellerId,
    String currentProductId, {
    int limit = 4,
  }) async {
    try {
      final currentId = int.tryParse(currentProductId);
      if (currentId == null) {
        throw Exception('유효하지 않은 상품 ID입니다.');
      }

      final response = await _supabase
          .from('products')
          .select(
            '*, profiles!products_seller_id_fkey(nickname, profile_image_url, location)',
          )
          .eq('status', 'selling')
          .eq('seller_id', sellerId)
          .neq('id', currentId) // 현재 상품 제외
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      log('Error fetching other products by seller: $e');
      return [];
    }
  }

  static Future<void> deleteProduct(String productId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final intId = int.tryParse(productId);
    if (intId == null) throw Exception('유효하지 않은 상품 ID입니다.');

    // 1. 먼저 사진 URL 리스트를 로컬 변수에 저장
    List<String> localImageUrls = [];

    try {
      log('Starting product deletion process for ID: $productId');

      // 상품 정보 조회하여 이미지 URL 목록 확보
      final productData = await _supabase
          .from('products')
          .select('image_urls')
          .eq('id', intId)
          .eq('seller_id', user.id) // 본인 소유 상품만
          .single();

      // 이미지 URL 리스트를 로컬 변수에 복사하여 저장
      localImageUrls = List<String>.from(productData['image_urls'] ?? []);
      log('Retrieved ${localImageUrls.length} image URLs for deletion');

      // 2. DB에서 상품 레코드 삭제
      await _supabase
          .from('products')
          .delete()
          .eq('id', intId)
          .eq('seller_id', user.id);

      log('Product record deleted from DB: $productId');

      // 3. 로컬에 저장된 이미지 URL을 사용하여 스토리지에서 직접 삭제
      if (localImageUrls.isNotEmpty) {
        // URL에서 파일 경로 추출
        final filePaths = <String>[];
        for (final url in localImageUrls) {
          try {
            final uri = Uri.parse(url);
            final path = uri.path;
            if (path.contains('product-images/')) {
              final extractedPath = path.substring(
                path.indexOf('product-images/') + 'product-images/'.length,
              );
              filePaths.add(extractedPath);
            }
          } catch (e) {
            log('Error parsing URL: $url, Error: $e');
          }
        }

        if (filePaths.isNotEmpty) {
          try {
            // Edge Function을 통한 파일 삭제
            final response = await _supabase.functions.invoke(
              'delete-storage-file',
              body: {'filePaths': filePaths},
            );

            if (response.status == 200 && response.data != null) {
              final responseData = response.data as Map<String, dynamic>;
              if (responseData['success'] == true) {
                log(
                  'Successfully deleted ${filePaths.length} images from storage',
                );
              } else {
                log('Storage deletion failed: ${responseData['error']}');
              }
            } else {
              log('Edge Function call failed with status: ${response.status}');
            }
          } catch (e) {
            log('Error calling Edge Function: $e');
          }
        }
      }

      log('Product deletion completed successfully: $productId');
    } catch (e) {
      log('Product deletion process failed: $e');
      log('Error type: ${e.runtimeType}');

      // DB 삭제는 성공했지만 스토리지 삭제가 실패한 경우를 위한 추가 처리
      if (localImageUrls.isNotEmpty) {
        log('Attempting cleanup of remaining storage files...');
        try {
          final filePaths = localImageUrls
              .map((url) {
                try {
                  final uri = Uri.parse(url);
                  final path = uri.path;
                  if (path.contains('product-images/')) {
                    return path.substring(
                      path.indexOf('product-images/') +
                          'product-images/'.length,
                    );
                  }
                } catch (e) {
                  log('Cleanup URL parsing error: $e');
                }
                return null;
              })
              .where((path) => path != null)
              .cast<String>()
              .toList();

          if (filePaths.isNotEmpty) {
            log('Cleanup: attempting to delete ${filePaths.length} files');
            final cleanupResponse = await _supabase.functions.invoke(
              'delete-storage-file',
              body: {'filePaths': filePaths},
            );

            if (cleanupResponse.status == 200) {
              log('Cleanup: successfully deleted remaining images');
            } else {
              log('Cleanup failed with status: ${cleanupResponse.status}');
            }
          }
        } catch (cleanupError) {
          log('Cleanup failed: $cleanupError');
        }
      }

      // 사용자에게는 포괄적인 에러 메시지를 전달
      throw Exception('상품 삭제 중 오류가 발생했습니다.');
    }
  }

  static Future<void> deleteImages(List<String> imageUrls) async {
    if (imageUrls.isEmpty) return;

    try {
      // URL에서 파일 경로 추출
      final filePaths = <String>[];
      for (final url in imageUrls) {
        try {
          final uri = Uri.parse(url);
          final path = uri.path;
          if (path.contains('product-images/')) {
            final extractedPath = path.substring(
              path.indexOf('product-images/') + 'product-images/'.length,
            );
            filePaths.add(extractedPath);
          }
        } catch (e) {
          log('Error parsing URL for deletion: $url, Error: $e');
        }
      }

      if (filePaths.isNotEmpty) {
        log('Attempting to delete ${filePaths.length} images from storage.');
        final response = await _supabase.functions.invoke(
          'delete-storage-file',
          body: {'filePaths': filePaths},
        );

        if (response.status == 200 && response.data != null) {
          final responseData = response.data as Map<String, dynamic>;
          if (responseData['success'] == true) {
            log(
              'Successfully deleted ${filePaths.length} images from storage',
            );
          } else {
            // 일부 또는 전체 삭제 실패 시에도 에러를 던지지 않고 로그만 남김
            log('Storage deletion failed: ${responseData['error']}');
          }
        } else {
          log('Edge Function call failed with status: ${response.status}');
        }
      }
    } catch (e) {
      log('Error during image deletion: $e');
      // 에러를 던져서 상위 호출자가 처리하도록 할 수도 있음
      // throw Exception('이미지 삭제 중 오류가 발생했습니다.');
    }
  }
}
