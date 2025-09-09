import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'models/product.dart';
import 'models/category.dart';
import 'models/chat.dart';

class DummyData {
  DummyData._();

  // Sellers
  static const List<Seller> sellers = [
    Seller(
      id: 'seller1',
      nickname: '자전거매니아',
      profileImage: '',
      location: '서울 강남구',
      otherProducts: [], // Will be populated separately
    ),
    Seller(
      id: 'seller2',
      nickname: '바이크러버',
      profileImage: '',
      location: '부산 해운대구',
      otherProducts: [],
    ),
    Seller(
      id: 'seller3',
      nickname: '페달킹',
      profileImage: '',
      location: '대구 중구',
      otherProducts: [],
    ),
    Seller(
      id: 'seller4',
      nickname: '라이더95',
      profileImage: '',
      location: '인천 연수구',
      otherProducts: [],
    ),
    Seller(
      id: 'seller5',
      nickname: '사이클링',
      profileImage: '',
      location: '광주 서구',
      otherProducts: [],
    ),
  ];

  // Categories
  static const List<Category> categories = [
    Category(
      id: 'mtb',
      name: 'MTB',
      icon: Icons.terrain,
      color: AppColors.primary,
    ),
    Category(
      id: 'road',
      name: '로드싸이클',
      icon: Icons.directions_bike,
      color: AppColors.secondary,
    ),
    Category(
      id: 'tt',
      name: 'TT&철인',
      icon: Icons.speed,
      color: AppColors.warning,
    ),
    Category(
      id: 'gravel',
      name: '그래블',
      icon: Icons.landscape,
      color: AppColors.error,
    ),
    Category(
      id: 'minivelo',
      name: '미니벨로',
      icon: Icons.unfold_less,
      color: AppColors.info,
    ),
    Category(
      id: 'fixie',
      name: '픽시',
      icon: Icons.radio_button_unchecked,
      color: Colors.purple,
    ),
    Category(
      id: 'electric',
      name: '전기자전거',
      icon: Icons.electric_bike,
      color: Colors.teal,
    ),
    Category(
      id: 'kids',
      name: '키즈&주니어',
      icon: Icons.child_friendly,
      color: Colors.pink,
    ),
    Category(
      id: 'special',
      name: '특수자전거',
      icon: Icons.settings,
      color: Colors.brown,
    ),
    Category(
      id: 'city',
      name: '생활 자전거',
      icon: Icons.pedal_bike,
      color: Colors.orange,
    ),
  ];

  // Products
  static final List<Product> products = [
    Product(
      id: 'product1',
      title: 'Giant TCR Advanced Pro 로드바이크',
      price: 1200000,
      description: '2022년 모델 Giant TCR Advanced Pro입니다. 카본 프레임으로 매우 가볍고 빠릅니다. 주행거리 약 3000km, 관리 상태 양호합니다.',
      images: ['bike1.jpg', 'bike1_2.jpg'],
      category: 'road',
      location: '서울 강남구',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isFavorite: false,
      seller: sellers[0],
    ),
    Product(
      id: 'product2',
      title: 'Trek Fuel EX 9.8 MTB',
      price: 890000,
      description: 'Trek Fuel EX 9.8 MTB입니다. 산악 라이딩에 최적화된 풀 서스펜션 바이크입니다. 상태 매우 좋습니다.',
      images: ['mtb1.jpg'],
      category: 'mtb',
      location: '부산 해운대구',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      isFavorite: true,
      seller: sellers[1],
    ),
    Product(
      id: 'product3',
      title: '알톤 스포츠 하이브리드 자전거',
      price: 350000,
      description: '알톤 스포츠 하이브리드 자전거입니다. 출퇴근용으로 사용했습니다. 기어 21단, 상태 양호합니다.',
      images: ['hybrid1.jpg'],
      category: 'hybrid',
      location: '대구 중구',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isFavorite: false,
      seller: sellers[2],
    ),
    Product(
      id: 'product4',
      title: 'Brompton 접이식 자전거',
      price: 2100000,
      description: 'Brompton 3단 접이식 자전거입니다. 영국 정품, 휴대성이 뛰어납니다. 거의 새 제품 수준입니다.',
      images: ['folding1.jpg', 'folding1_2.jpg'],
      category: 'folding',
      location: '인천 연수구',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      isFavorite: true,
      seller: sellers[3],
    ),
    Product(
      id: 'product5',
      title: '삼천리 레스포 전기자전거',
      price: 1450000,
      description: '삼천리 레스포 전기자전거입니다. 48V 리튬 배터리, 1회 충전으로 60km 주행 가능합니다.',
      images: ['electric1.jpg'],
      category: 'electric',
      location: '광주 서구',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isFavorite: false,
      seller: sellers[4],
    ),
    Product(
      id: 'product6',
      title: 'Specialized Rockhopper MTB',
      price: 650000,
      description: 'Specialized Rockhopper 29인치 MTB입니다. 하드테일 산악자전거, 상태 좋습니다.',
      images: ['mtb2.jpg'],
      category: 'mtb',
      location: '서울 강남구',
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      isFavorite: false,
      seller: sellers[0],
    ),
    Product(
      id: 'product7',
      title: '레드라인 BMX',
      price: 280000,
      description: '레드라인 BMX 자전거입니다. 스트릿, 파크 라이딩용으로 좋습니다.',
      images: ['bmx1.jpg'],
      category: 'bmx',
      location: '부산 해운대구',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      isFavorite: false,
      seller: sellers[1],
    ),
    Product(
      id: 'product8',
      title: '삼천리 시티바이크 (바구니 포함)',
      price: 180000,
      description: '삼천리 시티바이크입니다. 앞바구니 포함, 생활용으로 사용했습니다. 상태 양호합니다.',
      images: ['city1.jpg'],
      category: 'city',
      location: '대구 중구',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      isFavorite: true,
      seller: sellers[2],
    ),
    Product(
      id: 'product9',
      title: 'Canyon Aeroad CF SL 로드바이크',
      price: 1890000,
      description: 'Canyon Aeroad CF SL 로드바이크입니다. 에어로 카본 프레임, 울테그라 그룹셋 장착.',
      images: ['road2.jpg', 'road2_2.jpg'],
      category: 'road',
      location: '인천 연수구',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      isFavorite: false,
      seller: sellers[3],
    ),
    Product(
      id: 'product10',
      title: '아이언맨 어린이 자전거 (16인치)',
      price: 120000,
      description: '아이언맨 어린이 자전거 16인치입니다. 5-7세 아이들에게 적합합니다. 보조바퀴 포함.',
      images: ['kids1.jpg'],
      category: 'kids',
      location: '광주 서구',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      isFavorite: false,
      seller: sellers[4],
    ),
    Product(
      id: 'product11',
      title: 'Trek Domane SL 5 로드바이크',
      price: 1350000,
      description: 'Trek Domane SL 5 엔듀어런스 로드바이크입니다. 장거리 라이딩에 최적화되어 있습니다.',
      images: ['road3.jpg'],
      category: 'road',
      location: '서울 강남구',
      createdAt: DateTime.now().subtract(const Duration(hours: 20)),
      isFavorite: true,
      seller: sellers[0],
    ),
    Product(
      id: 'product12',
      title: '자이언트 하이브리드 Escape 3',
      price: 420000,
      description: '자이언트 Escape 3 하이브리드 자전거입니다. 출퇴근, 레저용으로 좋습니다.',
      images: ['hybrid2.jpg'],
      category: 'hybrid',
      location: '부산 해운대구',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
      isFavorite: false,
      seller: sellers[1],
    ),
    Product(
      id: 'product13',
      title: 'Dahon 접이식 자전거',
      price: 580000,
      description: 'Dahon 20인치 접이식 자전거입니다. 7단 기어, 가벼워서 휴대하기 편합니다.',
      images: ['folding2.jpg'],
      category: 'folding',
      location: '대구 중구',
      createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      isFavorite: false,
      seller: sellers[2],
    ),
    Product(
      id: 'product14',
      title: '코나 전기 MTB',
      price: 1750000,
      description: '코나 전기 MTB입니다. 산악 전용 전기자전거로 파워풀한 성능을 자랑합니다.',
      images: ['electric2.jpg'],
      category: 'electric',
      location: '인천 연수구',
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      isFavorite: false,
      seller: sellers[3],
    ),
    Product(
      id: 'product15',
      title: 'Mongoose Legion BMX',
      price: 320000,
      description: 'Mongoose Legion BMX입니다. 20인치 BMX, 스턴트, 스트릿 라이딩용입니다.',
      images: ['bmx2.jpg'],
      category: 'bmx',
      location: '광주 서구',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isFavorite: true,
      seller: sellers[4],
    ),
  ];

  // Popular products (first 6 products)
  static List<Product> get popularProducts => products.take(6).toList();

  // Recent products (last 8 products)
  static List<Product> get recentProducts => products.skip(7).toList();

  // Favorite products
  static List<Product> get favoriteProducts =>
      products.where((product) => product.isFavorite).toList();

  // Products by category
  static List<Product> getProductsByCategory(String categoryId) {
    return products.where((product) => product.category == categoryId).toList();
  }

  // Chat rooms with dummy messages
  static List<ChatRoom> get chatRooms => [
        ChatRoom(
          id: 'chat1',
          product: products[1], // Trek MTB
          otherUser: sellers[1],
          unreadCount: 2,
          messages: [
            Message(
              id: 'msg1',
              content: '안녕하세요, 자전거 상태가 어떤가요?',
              isMe: true,
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              type: MessageType.text,
            ),
            Message(
              id: 'msg2',
              content: '안녕하세요! 상태 정말 좋습니다. 거의 새 자전거처럼 관리했어요.',
              isMe: false,
              timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
              type: MessageType.text,
            ),
            Message(
              id: 'msg3',
              content: '혹시 실제로 볼 수 있을까요?',
              isMe: true,
              timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
              type: MessageType.text,
            ),
            Message(
              id: 'msg4',
              content: '네, 언제든지 가능합니다. 해운대쪽에서 보실 수 있어요.',
              isMe: false,
              timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
              type: MessageType.text,
            ),
          ],
        ),
        ChatRoom(
          id: 'chat2',
          product: products[3], // Brompton 접이식
          otherUser: sellers[3],
          unreadCount: 0,
          messages: [
            Message(
              id: 'msg5',
              content: '접이식 자전거 구매 희망합니다.',
              isMe: true,
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              type: MessageType.text,
            ),
            Message(
              id: 'msg6',
              content: '네, 감사합니다. 직접 보고 결정하세요.',
              isMe: false,
              timestamp: DateTime.now().subtract(const Duration(hours: 20)),
              type: MessageType.text,
            ),
          ],
        ),
        ChatRoom(
          id: 'chat3',
          product: products[7], // 시티바이크
          otherUser: sellers[2],
          unreadCount: 1,
          messages: [
            Message(
              id: 'msg7',
              content: '가격 협상 가능한가요?',
              isMe: true,
              timestamp: DateTime.now().subtract(const Duration(hours: 3)),
              type: MessageType.text,
            ),
            Message(
              id: 'msg8',
              content: '조금은 가능합니다. 얼마 정도 생각하고 계신가요?',
              isMe: false,
              timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
              type: MessageType.text,
            ),
          ],
        ),
      ];

  // Get total unread message count
  static int get totalUnreadCount =>
      chatRooms.fold(0, (total, chatRoom) => total + chatRoom.unreadCount);
}