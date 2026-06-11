import 'dart:async';
import 'package:flutter/material.dart';

class DynamicIsland {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;
  static GlobalKey<_DynamicIslandWidgetState>? _widgetKey;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 3),
    bool isAudio = false,
  }) {
    // Cancel any active dismiss timer
    _dismissTimer?.cancel();
    _dismissTimer = null;

    // Immediately remove the current entry if it exists to avoid queue locks
    if (_currentEntry != null) {
      try {
        _currentEntry!.remove();
      } catch (_) {}
      _currentEntry = null;
    }

    // Create a new key for this specific instance to prevent duplicate key collisions
    final key = GlobalKey<_DynamicIslandWidgetState>();
    _widgetKey = key;

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => DynamicIslandWidget(
        key: key,
        title: title,
        message: message,
        icon: icon,
        color: color,
        duration: duration,
        isAudio: isAudio,
        onDismissComplete: () {
          _dismissTimer?.cancel();
          _dismissTimer = null;
          if (_currentEntry != null) {
            try {
              _currentEntry!.remove();
            } catch (_) {}
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    // Auto dismiss after the specified duration
    _dismissTimer = Timer(duration, () {
      if (key.currentState != null && key.currentState!.mounted) {
        key.currentState!.dismiss();
      } else {
        _dismissTimer?.cancel();
        _dismissTimer = null;
        if (_currentEntry == entry) {
          try {
            entry.remove();
          } catch (_) {}
          _currentEntry = null;
        }
      }
    });
  }

  static void dismiss({VoidCallback? thenShow}) {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    
    if (_currentEntry != null) {
      final key = _widgetKey;
      if (key != null && key.currentState != null && key.currentState!.mounted) {
        key.currentState!.dismiss(onComplete: () {
          if (thenShow != null) thenShow();
        });
      } else {
        try {
          _currentEntry!.remove();
        } catch (_) {}
        _currentEntry = null;
        if (thenShow != null) thenShow();
      }
    } else {
      if (thenShow != null) thenShow();
    }
  }
}

class DynamicIslandWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Duration duration;
  final bool isAudio;
  final VoidCallback onDismissComplete;

  const DynamicIslandWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.duration,
    required this.isAudio,
    required this.onDismissComplete,
  });

  @override
  State<DynamicIslandWidget> createState() => _DynamicIslandWidgetState();
}

class _DynamicIslandWidgetState extends State<DynamicIslandWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _borderRadiusAnimation;
  late Animation<double> _scaleAnimation;

  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    // Bouncy spring curve for expansion
    final Animation<double> curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );

    _widthAnimation = Tween<double>(begin: 80.0, end: 340.0).animate(curve);
    _heightAnimation = Tween<double>(begin: 30.0, end: 76.0).animate(curve);
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
        reverseCurve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _borderRadiusAnimation = Tween<double>(begin: 15.0, end: 28.0).animate(curve);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(curve);

    _controller.forward();
  }

  void dismiss({VoidCallback? onComplete}) {
    if (!mounted || _isDismissing) return;
    setState(() {
      _isDismissing = true;
    });
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismissComplete();
        if (onComplete != null) onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Material(
            color: Colors.transparent,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return GestureDetector(
                  onTap: () => dismiss(),
                  onVerticalDragUpdate: (details) {
                    if (details.primaryDelta! < -5) {
                      dismiss();
                    }
                  },
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: _widthAnimation.value,
                      height: _heightAnimation.value,
                      decoration: BoxDecoration(
                        color: const Color(0xFF090A11).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(_borderRadiusAnimation.value),
                        border: Border.all(
                          color: widget.color.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _controller.value < 0.4
                          ? const SizedBox.shrink()
                          : Opacity(
                              opacity: _opacityAnimation.value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                              child: Row(
                                children: [
                                  // Left Avatar/Icon
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: widget.color.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: widget.color.withValues(alpha: 0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      widget.icon,
                                      color: widget.color,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  
                                  // Center Text Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.title.toUpperCase(),
                                          style: TextStyle(
                                            color: widget.color,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(height: 3.0),
                                        Text(
                                          widget.message,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Right Dynamic Action / Indicator
                                  const SizedBox(width: 8.0),
                                  if (widget.isAudio)
                                    MiniAudioWaveform(color: widget.color)
                                  else
                                    PulsingDot(color: widget.color),
                                ],
                              ),
                            ),
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MiniAudioWaveform extends StatefulWidget {
  final Color color;
  const MiniAudioWaveform({super.key, required this.color});

  @override
  State<MiniAudioWaveform> createState() => _MiniAudioWaveformState();
}

class _MiniAudioWaveformState extends State<MiniAudioWaveform> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _baseHeights = [8.0, 18.0, 13.0, 7.0];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(4, (index) {
            final double heightFactor = 0.25 + 0.75 * (index % 2 == 0 ? _controller.value : 1.0 - _controller.value);
            return Container(
              width: 2.0,
              height: _baseHeights[index] * heightFactor,
              margin: const EdgeInsets.symmetric(horizontal: 1.2),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }),
        );
      },
    );
  }
}

class PulsingDot extends StatefulWidget {
  final Color color;
  const PulsingDot({super.key, required this.color});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 7.0,
          height: 7.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.6 * _controller.value),
                blurRadius: 8.0 * _controller.value,
                spreadRadius: 2.5 * _controller.value,
              )
            ],
          ),
        );
      },
    );
  }
}
