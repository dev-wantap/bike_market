import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/product.dart';

class AddProductScreen extends StatefulWidget {
  final VoidCallback? onProductAdded;
  
  const AddProductScreen({super.key, this.onProductAdded});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  
  String _selectedCategory = '';
  String _selectedCondition = '좋음';
  bool _isNegotiable = false;
  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  
  final List<String> _categories = [
    '로드바이크', '산악자전거', '하이브리드', '접이식자전거', '전기자전거', 
    '미니벨로', '픽시', '커스텀', '부품', '기타'
  ];
  
  final List<String> _conditions = ['새상품', '좋음', '보통', '나쁨'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최대 5장까지 선택할 수 있습니다.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxHeight: 1920,
        maxWidth: 1920,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<String> _uploadImage(File imageFile) async {
    final imageExtension = imageFile.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$imageExtension';
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final filePath = '$userId/$fileName';

    int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        await Supabase.instance.client.storage
            .from('product-images')
            .upload(filePath, imageFile);
        
        return Supabase.instance.client.storage
            .from('product-images')
            .getPublicUrl(filePath);
            
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('이미지 업로드 실패 (${maxRetries}회 시도): ${e.toString()}');
        }
        
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
    
    throw Exception('이미지 업로드 실패');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('상품 등록'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _submitProduct,
            child: _isUploading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '완료',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildImageSection(),
              const SizedBox(height: AppDimensions.spacingMedium),
              _buildFormSection(),
              const SizedBox(height: AppDimensions.spacingXLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '상품 사진',
                  style: AppTextStyles.subtitle1,
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmall,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: const Text(
                    '필수',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              '상품 사진을 등록해주세요 (최대 5장)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: AppDimensions.marginSmall),
                    child: _buildImageSlot(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlot(int index) {
    final hasImage = index < _selectedImages.length;
    
    return GestureDetector(
      onTap: hasImage ? () => _removeImage(index) : _pickImage,
      child: Container(
        decoration: BoxDecoration(
          color: hasImage ? AppColors.surface : AppColors.background,
          border: Border.all(
            color: hasImage ? Colors.transparent : AppColors.divider,
            style: hasImage ? BorderStyle.none : BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: hasImage
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    child: Image.file(
                      _selectedImages[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    index == 0 ? Icons.camera_alt : Icons.add,
                    color: AppColors.textLight,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    index == 0 ? '대표' : '${index + 1}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textLight,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _titleController,
              label: '제목',
              hint: '상품명을 입력해주세요',
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildCategorySelector(),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildConditionSelector(),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildTextField(
              controller: _priceController,
              label: '가격',
              hint: '가격을 입력해주세요',
              required: true,
              keyboardType: TextInputType.number,
              suffix: '원',
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _ThousandsSeparatorInputFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '가격을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            _buildNegotiableSwitch(),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildTextField(
              controller: _descriptionController,
              label: '상품 설명',
              hint: '상품에 대한 자세한 설명을 작성해주세요',
              required: true,
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '상품 설명을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildTextField(
              controller: _locationController,
              label: '거래 희망 지역',
              hint: '거래를 희망하는 지역을 입력해주세요',
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '거래 희망 지역을 입력해주세요';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
    TextInputType? keyboardType,
    String? suffix,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.subtitle2,
            ),
            if (required) ...[
              const SizedBox(width: AppDimensions.spacingXSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  '필수',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '카테고리',
              style: AppTextStyles.subtitle2,
            ),
            const SizedBox(width: AppDimensions.spacingXSmall),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                '필수',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        Wrap(
          spacing: AppDimensions.spacingSmall,
          runSpacing: AppDimensions.spacingSmall,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                ),
                child: Text(
                  category,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConditionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상품 상태',
          style: AppTextStyles.subtitle2,
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        Row(
          children: _conditions.map((condition) {
            final isSelected = _selectedCondition == condition;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCondition = condition;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: AppDimensions.marginXSmall),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingMedium,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Text(
                    condition,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNegotiableSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '가격 제안 받기',
          style: AppTextStyles.subtitle2,
        ),
        Switch(
          value: _isNegotiable,
          onChanged: (value) {
            setState(() {
              _isNegotiable = value;
            });
          },
          activeTrackColor: AppColors.primary,
          activeThumbColor: Colors.white,
        ),
      ],
    );
  }


  Future<void> _submitProduct() async {
    log('=== _submitProduct 시작 ===');
    
    if (!_formKey.currentState!.validate()) {
      log('폼 검증 실패');
      return;
    }

    if (_selectedImages.isEmpty) {
      log('이미지 없음');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('상품 사진을 최소 1장 등록해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (_selectedCategory.isEmpty) {
      log('카테고리 선택 안함');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('카테고리를 선택해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    log('로딩 시작: _isUploading = true');
    setState(() {
      _isUploading = true;
    });

    try {
      // 이미지들을 병렬로 업로드
      log('이미지 업로드 시작: ${_selectedImages.length}개');
      final imageUrls = <String>[];
      for (int i = 0; i < _selectedImages.length; i++) {
        try {
          log('이미지 ${i + 1} 업로드 중...');
          final url = await _uploadImage(_selectedImages[i]);
          imageUrls.add(url);
          log('이미지 ${i + 1} 업로드 완료: $url');
        } catch (e) {
          log('이미지 ${i + 1} 업로드 실패: $e');
          throw Exception('이미지 ${i + 1} 업로드 실패: ${e.toString()}');
        }
      }

      // 카테고리 매핑
      final categoryMap = {
        '로드바이크': 'road',
        '산악자전거': 'mtb', 
        '하이브리드': 'hybrid',
        '접이식자전거': 'folding',
        '전기자전거': 'electric',
        '미니벨로': 'city',
        '픽시': 'road',
        '커스텀': 'road',
        '부품': 'road',
        '기타': 'road',
      };

      // 상품 데이터 생성
      final product = Product(
        id: '', // 서버에서 자동 생성
        title: _titleController.text.trim(),
        price: int.parse(_priceController.text.replaceAll(',', '')),
        description: _descriptionController.text.trim(),
        images: imageUrls,
        category: categoryMap[_selectedCategory] ?? 'road',
        location: _locationController.text.trim(),
        createdAt: DateTime.now(),
        isFavorite: false,
        seller: Seller(
          id: Supabase.instance.client.auth.currentUser!.id,
          nickname: '',
          profileImage: '',
          location: _locationController.text.trim(),
          otherProducts: [],
        ),
      );

      // ProductService를 사용하여 상품 등록
      log('상품 DB 저장 시작');
      await _insertProduct(product);
      log('상품 DB 저장 완료');

      if (mounted) {
        log('상품 등록 성공 - 화면 이동');
        
        // 상품 등록 성공 알림
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('상품이 등록되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // 폼 초기화
        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _locationController.clear();
        setState(() {
          _selectedImages.clear();
          _selectedCategory = '';
          _isNegotiable = false;
        });
        
        // 홈으로 이동
        widget.onProductAdded?.call();
      }
    } catch (e) {
      log('상품 등록 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('상품 등록 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      log('로딩 종료: _isUploading = false');
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _insertProduct(Product product) async {
    final supabase = Supabase.instance.client;
    
    await supabase.from('products').insert({
      'seller_id': product.seller.id,
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'image_urls': product.images,
      'category': product.category,
      'location': product.location,
      'status': 'selling',
      'view_count': 0,
    });
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.isEmpty) {
      return const TextEditingValue();
    }

    // Format with commas
    String formatted = _addCommas(digits);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addCommas(String value) {
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return value.replaceAllMapped(regex, (Match match) => '${match[1]},');
  }
}