import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Rotates through intelligent status messages while the AI is computing.
/// Uses a smooth cross-fade animation. No random delays, strictly sequential.
class RotatingStatusText extends StatefulWidget {
  const RotatingStatusText({super.key});

  @override
  State<RotatingStatusText> createState() => _RotatingStatusTextState();
}

class _RotatingStatusTextState extends State<RotatingStatusText> {
  static const _messages = [
    'Analyzing video performance…',
    'Evaluating retention patterns…',
    'Computing percentile rank…',
    'Building strategic insight…',
    'Refining recommendations…',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        _messages[_currentIndex],
        key: ValueKey<int>(_currentIndex),
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
