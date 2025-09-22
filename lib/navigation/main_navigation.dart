import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../providers/chat_notification_provider.dart';
import '../widgets/screens/home/home_screen.dart';
import '../widgets/screens/reservation/reservation_list_screen.dart';
import '../widgets/screens/add/add_product_screen.dart';
import '../widgets/screens/chat/chat_list_screen.dart';
import '../widgets/screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();

  // 외부에서 접근 가능한 static 메소드
  static void refreshHome(BuildContext context) {
    log('MainNavigation.refreshHome called');
    final mainNavigation = context
        .findAncestorStateOfType<_MainNavigationState>();
    if (mainNavigation != null) {
      log('MainNavigation state found, calling _refreshHomeScreen');
      mainNavigation._refreshHomeScreen();
    } else {
      log('MainNavigation state not found');
    }
  }
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  @override
  void initState() {
    super.initState();
    _updateScreens();
  }

  void _updateScreens() {
    _screens = [
      HomeScreen(key: _homeKey, onRefresh: _refreshHomeScreen),
      const ReservationListScreen(),
      AddProductScreen(onProductAdded: _onProductAdded),
      const ChatListScreen(),
      const ProfileScreen(),
    ];
  }

  void _refreshHomeScreen() {
    log('_refreshHomeScreen called');
    // 직접 HomeScreen의 새로고침 메서드 호출
    if (_homeKey.currentState != null) {
      log('HomeScreen state found, calling refreshData');
      _homeKey.currentState!.refreshData();
    } else {
      log('HomeScreen state is null');
    }
  }

  void _onProductAdded() {
    // 상품 등록 완료 시 홈으로 이동 후 데이터 새로고침
    setState(() {
      _currentIndex = 0;
    });
    // 약간의 지연 후 데이터 새로고침
    Future.delayed(const Duration(milliseconds: 100), () {
      _refreshHomeScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // 홈 탭으로 전환할 때마다 데이터 새로고침
          if (index == 0) {
            _refreshHomeScreen();
          }

          // 채팅 탭으로 전환할 때 글로벌 배지 제거
          if (index == 3) {
            context.read<ChatNotificationProvider>().markAllAsRead();
          }
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '예약',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            label: '등록',
          ),
          BottomNavigationBarItem(
            icon: Consumer<ChatNotificationProvider>(
              builder: (context, chatNotificationProvider, child) {
                final unreadCount = chatNotificationProvider.totalUnreadCount;
                final hasGlobalUnread =
                    chatNotificationProvider.hasGlobalUnread;

                return Stack(
                  children: [
                    const Icon(Icons.chat),
                    // Badge for unread messages - 글로벌 배지는 hasGlobalUnread로, 개수는 totalUnreadCount로 표시
                    if (hasGlobalUnread && unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: '채팅',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}
