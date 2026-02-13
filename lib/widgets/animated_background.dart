import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import '../constants/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final ScrollController? scrollController;

  const AnimatedBackground({super.key, this.scrollController});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    // Use different durations for organic chaotic feeling
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  Widget _buildBlob({
    required Color color,
    required double size,
    required Animation<double> controller,
    double xAmplitude = 0,
    double yAmplitude = 0,
    double startX = 0,
    double startY = 0,
    bool invertX = false,
    bool invertY = false,
    double parallaxFactor = 0.0,
  }) {
    // Determine scroll offset safely
    double scrollOffset = 0;
    if (widget.scrollController != null &&
        widget.scrollController!.hasClients) {
      scrollOffset = widget.scrollController!.offset;
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        double xValue = sin(controller.value * 2 * pi);
        double yValue = cos(controller.value * 2 * pi);

        if (invertX) xValue = -xValue;
        if (invertY) yValue = -yValue;

        double left = startX * screenWidth;
        double top = startY * screenHeight;

        // Add Animation Movement
        left += xValue * xAmplitude;
        top += yValue * yAmplitude;

        // Add Parallax Movement (Moves opposite to scroll)
        top -= scrollOffset * parallaxFactor;

        return Positioned(
          top: top - size / 2,
          left: left - size / 2,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color.withOpacity(0.4), color.withOpacity(0.0)],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If a scrollController is provided, wrap in an AnimatedBuilder to rebuild on scroll
    // effectively animating the parallax.
    Widget content(BuildContext context) {
      return Stack(
        children: [
          // Background Color
          Container(color: Theme.of(context).scaffoldBackgroundColor),

          // Blobs
          _buildBlob(
            color: AppColors.primary,
            size: 400,
            controller: _controller1,
            startX: 0.1,
            startY: 0.1,
            xAmplitude: 100,
            yAmplitude: 80,
            parallaxFactor: 0.2,
          ),
          _buildBlob(
            color: AppColors.secondary,
            size: 450,
            controller: _controller2,
            startX: 0.8,
            startY: 0.2,
            xAmplitude: 120,
            yAmplitude: 200,
            invertX: true,
            parallaxFactor: 0.4, // Faster movement
          ),
          _buildBlob(
            color: AppColors.accentLight,
            size: 300,
            controller: _controller3,
            startX: 0.5,
            startY: 0.5,
            xAmplitude: 150,
            yAmplitude: 120,
            invertY: true,
            parallaxFactor: 0.1,
          ),
          _buildBlob(
            color: AppColors.warning.withOpacity(0.6),
            size: 350,
            controller: _controller1,
            startX: 0.2,
            startY: 0.8,
            xAmplitude: 90,
            yAmplitude: 90,
            invertX: true,
            invertY: true,
            parallaxFactor: -0.2, // Moves in reverse direction
          ),
          _buildBlob(
            color: Colors.purpleAccent.withOpacity(0.4), // New Blob
            size: 250,
            controller: _controller2,
            startX: 0.7,
            startY: 0.7,
            xAmplitude: 110,
            yAmplitude: 110,
            parallaxFactor: 0.5,
          ),
          _buildBlob(
            color: Colors.tealAccent.withOpacity(0.3), // New Blob
            size: 300,
            controller: _controller3,
            startX: 0.4,
            startY: 0.9,
            xAmplitude: 130,
            yAmplitude: 70,
            parallaxFactor: -0.1,
          ),

          // Glassmorphism Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.scrollController != null) {
      return AnimatedBuilder(
        animation: widget.scrollController!,
        builder: (context, child) => content(context),
      );
    } else {
      return content(context);
    }
  }
}
