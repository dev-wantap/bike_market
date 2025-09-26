import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final Widget? nextScreen;
  final bool autoNavigate;
  final VoidCallback? onFadeOutComplete;
  final bool shouldStartFadeOut;

  const SplashScreen({
    super.key,
    this.nextScreen,
    this.autoNavigate = true,
    this.onFadeOutComplete,
    this.shouldStartFadeOut = false,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 처음에는 완전히 보이는 상태로 시작 (페이드인 없음)
    _animationController.value = 1.0;

    // Navigate after 1 second if autoNavigate is enabled
    if (widget.autoNavigate) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _startFadeOutAndNavigate();
        }
      });
    }

    // 외부에서 페이드아웃을 요청한 경우
    if (widget.shouldStartFadeOut) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startFadeOut();
      });
    }
  }

  @override
  void didUpdateWidget(SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // shouldStartFadeOut이 변경되었다면
    if (widget.shouldStartFadeOut && !oldWidget.shouldStartFadeOut) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startFadeOut();
      });
    }
  }

  void _startFadeOutAndNavigate() {
    // 페이드아웃 애니메이션 시작
    _animationController.reverse().then((_) {
      if (mounted) {
        final nextScreen = widget.nextScreen ?? const OnboardingScreen();
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
            transitionDuration: Duration.zero,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return child;
            },
          ),
        );
      }
    });
  }

  void startFadeOut() {
    if (mounted) {
      // nextScreen이 있으면 페이드아웃과 동시에 화면 전환 시작
      if (widget.nextScreen != null && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen!,
            transitionDuration: const Duration(milliseconds: 500), // 페이드아웃과 동일한 시간
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }

      // 페이드아웃 애니메이션 시작
      _animationController.reverse().then((_) {
        widget.onFadeOutComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.pedal_bike,
                    size: AppDimensions.iconXLarge * 2,
                    color: Colors.white,
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  const Text(
                    'CycleLink',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  const Text(
                    '중고 자전거 거래의 새로운 경험',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
