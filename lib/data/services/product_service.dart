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
      log('Retrieved image URLs: ${localImageUrls.length} images');

      // 각 URL을 상세히 로깅
      for (int i = 0; i < localImageUrls.length; i++) {
        log('Image URL [$i]: ${localImageUrls[i]}');
      }

      // 2. DB에서 상품 레코드 삭제
      await _supabase
          .from('products')
          .delete()
          .eq('id', intId)
          .eq('seller_id', user.id);

      log('Product record deleted from DB: $productId');

      // 3. 로컬에 저장된 이미지 URL을 사용하여 스토리지에서 직접 삭제
      if (localImageUrls.isNotEmpty) {
        log('Processing storage deletion for ${localImageUrls.length} images');

        final filePaths = <String>[];

        for (int i = 0; i < localImageUrls.length; i++) {
          final url = localImageUrls[i];
          log('Processing URL [$i]: $url');

          try {
            // URL에서 파일 경로 추출
            final uri = Uri.parse(url);
            log(
              'Parsed URI - scheme: ${uri.scheme}, host: ${uri.host}, path: ${uri.path}',
            );

            final path = uri.path;

            // product-images/ 이후의 경로만 추출
            if (path.contains('product-images/')) {
              final extractedPath = path.substring(
                path.indexOf('product-images/') + 'product-images/'.length,
              );
              filePaths.add(extractedPath);
              log('Extracted file path [$i]: $extractedPath');
            } else {
              log('Warning: URL does not contain product-images/ path: $url');
            }
          } catch (e) {
            log('Error parsing URL [$i]: $url, Error: $e');
          }
        }

        log('Final file paths to delete: ${filePaths.length} files');
        for (int i = 0; i < filePaths.length; i++) {
          log('File path [$i]: ${filePaths[i]}');
        }

        if (filePaths.isNotEmpty) {
          try {
            // 삭제 전 파일 존재 여부 확인
            log('Checking file existence before deletion...');
            for (final filePath in filePaths) {
              try {
                final fileInfo = await _supabase.storage
                    .from('product-images')
                    .info(filePath);
                log(
                  'File exists before deletion: $filePath, info: ${fileInfo.toString()}',
                );
              } catch (e) {
                log(
                  'File does not exist or error checking: $filePath, error: $e',
                );
              }
            }

            // Edge Function을 통한 파일 삭제
            log('Attempting to delete files via Edge Function...');
            log('Files to delete: $filePaths');

            try {
              final response = await _supabase.functions.invoke(
                'delete-storage-file',
                body: {'filePaths': filePaths},
              );

              log('Edge Function response status: ${response.status}');
              log('Edge Function response data: ${response.data}');

              if (response.status == 200 && response.data != null) {
                final responseData = response.data as Map<String, dynamic>;
                if (responseData['success'] == true) {
                  log('SUCCESS: Files deleted via Edge Function');
                  log('Deleted files: ${responseData['deletedFiles']}');
                } else {
                  log('Edge Function reported failure: ${responseData['error']}');
                }
              } else {
                log('Edge Function call failed with status: ${response.status}');
                if (response.data != null) {
                  log('Error details: ${response.data}');
                }
              }
            } catch (e) {
              log('Error calling Edge Function: $e');
            }

            // 삭제 후 파일 존재 여부 재확인
            log('Checking file existence after deletion...');
            bool allDeleted = true;
            for (final filePath in filePaths) {
              try {
                final fileInfo = await _supabase.storage
                    .from('product-images')
                    .info(filePath);
                log(
                  'WARNING: File still exists after deletion: $filePath, info: ${fileInfo.toString()}',
                );
                allDeleted = false;
              } catch (e) {
                log('Confirmed: File deleted successfully: $filePath');
              }
            }

            if (allDeleted) {
              log(
                'Successfully deleted ${filePaths.length} images from storage',
              );
            } else {
              log('ERROR: Some files were not deleted from storage');

              // 개별 파일 삭제 시도
              log('Attempting individual file deletion...');
              for (final filePath in filePaths) {
                try {
                  final individualResponse = await _supabase.storage
                      .from('product-images')
                      .remove([filePath]);
                  log(
                    'Individual delete response for $filePath: $individualResponse',
                  );

                  // 개별 삭제 후 확인
                  try {
                    await _supabase.storage
                        .from('product-images')
                        .info(filePath);
                    log('Individual deletion failed for: $filePath');
                  } catch (e) {
                    log('Individual deletion successful for: $filePath');
                  }
                } catch (e) {
                  log('Individual deletion error for $filePath: $e');
                }
              }
            }
          } catch (storageError) {
            log('Storage deletion failed: $storageError');
            log('Storage error type: ${storageError.runtimeType}');

            // Storage 버킷 확인
            try {
              final buckets = await _supabase.storage.listBuckets();
              log('Available buckets: ${buckets.map((b) => b.name).toList()}');
            } catch (e) {
              log('Could not list buckets: $e');
            }

            // 파일 존재 여부 확인
            try {
              final files = await _supabase.storage
                  .from('product-images')
                  .list();
              log('Files in product-images bucket: ${files.length}');
              for (final file in files.take(5)) {
                log('Sample file: ${file.name}');
              }
            } catch (e) {
              log('Could not list files in bucket: $e');
            }

            throw storageError;
          }
        } else {
          log('No valid file paths extracted from URLs');
        }
      } else {
        log('No images to delete from storage');
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
            final cleanupResponse = await _supabase.storage
                .from('product-images')
                .remove(filePaths);
            log('Cleanup response: $cleanupResponse');
            log('Cleanup: deleted ${filePaths.length} remaining images');
          }
        } catch (cleanupError) {
          log('Cleanup failed: $cleanupError');
          log('Cleanup error type: ${cleanupError.runtimeType}');
        }
      }

      // 사용자에게는 포괄적인 에러 메시지를 전달
      throw Exception('상품 삭제 중 오류가 발생했습니다.');
    }
  }
}
