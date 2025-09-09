import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../data/dummy_data.dart';
import '../widgets/screens/home/home_screen.dart';
import '../widgets/screens/search/search_screen.dart';
import '../widgets/screens/add/add_product_screen.dart';
import '../widgets/screens/chat/chat_list_screen.dart';
import '../widgets/screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int _refreshTrigger = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _updateScreens();
  }

  void _updateScreens() {
    _screens = [
      HomeScreen(key: ValueKey(_refreshTrigger), onRefresh: _refreshHomeScreen),
      const SearchScreen(),
      AddProductScreen(onProductAdded: _onProductAdded),
      const ChatListScreen(),
      const ProfileScreen(),
    ];
  }

  void _refreshHomeScreen() {
    // HomeScreen을 재생성하여 새로고침 효과
    setState(() {
      _refreshTrigger++;
      _updateScreens();
    });
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
            label: '등록',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.chat),
                // Badge for unread messages
                if (DummyData.totalUnreadCount > 0)
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
                          '${DummyData.totalUnreadCount}',
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
            ),
            label: '채팅',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}