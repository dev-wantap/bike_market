import 'package:flutter/material.dart';
import '../constants/colors.dart';

class FeedbackHelper {
  FeedbackHelper._();

  /// 성공 SnackBar 표시
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 에러 SnackBar 표시
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 정보 SnackBar 표시
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 경고 SnackBar 표시
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 찜하기 관련 피드백
  static void showFavoriteAdded(BuildContext context) {
    showSuccess(context, '찜 목록에 추가되었습니다');
  }

  static void showFavoriteRemoved(BuildContext context) {
    showInfo(context, '찜 목록에서 제거되었습니다');
  }

  static void showFavoriteError(BuildContext context, String operation) {
    showError(context, '$operation에 실패했습니다. 다시 시도해주세요.');
  }

  /// 일반적인 작업 피드백
  static void showOperationSuccess(BuildContext context, String operation) {
    showSuccess(context, '$operation이 완료되었습니다');
  }

  static void showOperationError(BuildContext context, String operation, [String? details]) {
    final message = details != null
        ? '$operation에 실패했습니다: $details'
        : '$operation에 실패했습니다. 다시 시도해주세요.';
    showError(context, message);
  }

  /// 네트워크 에러 피드백
  static void showNetworkError(BuildContext context) {
    showError(context, '네트워크 연결을 확인해주세요');
  }

  /// 로그인 필요 피드백
  static void showLoginRequired(BuildContext context) {
    showWarning(context, '로그인이 필요한 기능입니다');
  }
}