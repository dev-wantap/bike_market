import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../data/services/profile_service.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/chat_notification_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../../navigation/main_navigation.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final ProfileService _profileService = ProfileService();
  bool _isInitializing = true;
  bool _isFadingOut = false;
  Widget? _nextScreen;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 최소 스플래시 표시 시간과 실제 로딩을 병렬로 처리
    final minimumSplashTime = Future.delayed(const Duration(seconds: 1));
    final loadingTask = _performInitialization();

    // 둘 다 완료될 때까지 대기
    await Future.wait([minimumSplashTime, loadingTask]);

    // 페이드아웃 시작
    if (mounted) {
      setState(() {
        _isFadingOut = true;
      });
    }
  }

  Future<void> _performInitialization() async {
    final currentSession = supabase.auth.currentSession;
    if (currentSession?.user != null) {
      // 로그인 상태면 프로필 확인
      await _ensureUserProfile(currentSession!.user);

      // Provider들 초기화
      await _initializeProviders();

      // 다음 화면을 홈으로 설정
      _nextScreen = const MainNavigation();
    } else {
      // 로그인되지 않은 경우 로그인 화면으로
      _nextScreen = const LoginScreen();
    }
  }

  Future<void> _initializeProviders() async {
    if (mounted) {
      final favoriteProvider = context.read<FavoriteProvider>();
      final chatNotificationProvider = context.read<ChatNotificationProvider>();

      // Provider들이 아직 초기화되지 않았다면 초기화
      if (favoriteProvider.favoriteCount == 0) {
        await favoriteProvider.loadFavorites();
      }

      await chatNotificationProvider.initialize();
    }
  }

  Future<void> _ensureUserProfile(User user) async {
    try {
      final existingProfile = await _profileService.getCurrentUserProfile();

      if (existingProfile == null) {
        // 프로필이 없으면 생성
        final nickname =
            user.userMetadata?['full_name'] as String? ??
            user.email?.split('@').first ??
            'User';

        await _profileService.createProfile(
          userId: user.id,
          nickname: nickname,
          avatarUrl: user.userMetadata?['avatar_url'] as String?,
        );
        log('Profile created for user: ${user.email}');
      } else {
        log('Profile exists for user: ${user.email}');
      }
    } catch (e) {
      log('Error ensuring user profile: $e');
    }
  }

  void _onAuthStateChange(AuthState authState) async {
    log(
      'Auth state changed: ${authState.event}, Session: ${authState.session?.user.email}',
    );

    if (authState.event == AuthChangeEvent.signedIn &&
        authState.session?.user != null) {
      // 로그인 성공시 프로필 확인 및 생성
      await _ensureUserProfile(authState.session!.user);

      // Provider들 초기화
      if (mounted) {
        final favoriteProvider = context.read<FavoriteProvider>();
        final chatNotificationProvider = context
            .read<ChatNotificationProvider>();

        await favoriteProvider.loadFavorites();
        await chatNotificationProvider.initialize();
      }
    } else if (authState.event == AuthChangeEvent.signedOut) {
      // 로그아웃시 Provider들 정리
      if (mounted) {
        final favoriteProvider = context.read<FavoriteProvider>();
        final chatNotificationProvider = context
            .read<ChatNotificationProvider>();

        favoriteProvider.clear();
        chatNotificationProvider.clear();

        setState(() {
          // 로그아웃 상태로 UI 업데이트 트리거
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 초기화 중이면 스플래시 화면 표시
    if (_isInitializing) {
      return SplashScreen(
        nextScreen: _nextScreen,
        autoNavigate: false,
        shouldStartFadeOut: _isFadingOut,
        onFadeOutComplete: () {
          // 페이드아웃 완료 후 초기화 완료로 설정
          if (mounted) {
            setState(() {
              _isInitializing = false;
            });
          }
        },
      );
    }

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 로딩 상태 처리
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(autoNavigate: false);
        }

        // 현재 세션 상태 확인 (실시간)
        final currentSession = supabase.auth.currentSession;

        // Auth state 변경 처리
        if (snapshot.hasData) {
          _onAuthStateChange(snapshot.data!);
        }

        log('Current session in build: ${currentSession?.user.email}');

        if (currentSession != null) {
          return const MainNavigation();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
