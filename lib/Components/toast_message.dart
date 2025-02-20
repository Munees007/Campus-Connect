import 'package:flutter/material.dart';

enum ToastType { success, error, warning, info }

class ToastManager {
  static final ToastManager _instance = ToastManager._internal();

  factory ToastManager() {
    return _instance;
  }

  ToastManager._internal();

  OverlayEntry? _overlayEntry;

  void showToast({
    required BuildContext context,
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case ToastType.error:
        backgroundColor = Colors.red;
        icon = Icons.error_outline;
        break;
      case ToastType.warning:
        backgroundColor = Colors.orange;
        icon = Icons.warning_amber_outlined;
        break;
      case ToastType.info:
        backgroundColor = Colors.blue;
        icon = Icons.info_outline;
        break;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position == ToastPosition.top ? 50 : null,
        bottom: position == ToastPosition.bottom ? 50 : null,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-dismiss the toast
    Future.delayed(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }
}

enum ToastPosition { top, bottom }
