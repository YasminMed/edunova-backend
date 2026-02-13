import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_page.dart';

// Provider for Welcome Logic
class WelcomeProvider extends ChangeNotifier {
  bool _showContent = false;
  bool get showContent => _showContent;

  void setShowContent(bool value) {
    _showContent = value;
    notifyListeners();
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  late AnimationController _transitionController;
  late Animation<double> _scaleAnimation;
  late AnimationController _logoPulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;
  late AnimationController _particleController;
  late Animation<double> _floatAnimation; // New Floating Movement
  final List<Offset> _particles = List.generate(
    25,
    (_) => Offset(Random().nextDouble(), Random().nextDouble()),
  );

  // To verify if intro is completed to show content
  bool _introCompleted = false;

  @override
  void initState() {
    super.initState();

    // Background Controllers
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

    // Transition Logic
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1500,
      ), // Slower base duration for smoothness
      value: 1.0, // Start fully expanded
    );

    _scaleAnimation = Tween<double>(begin: 0.1, end: 4.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Cubic(0.2, 0.0, 0.2, 1.0),
      ),
    );

    // Logo Pulse Animation
    _logoPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _logoPulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    _pulseOpacity = Tween<double>(begin: 0.2, end: 0.4).animate(
      CurvedAnimation(
        parent: _logoPulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _floatAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(
        parent: _logoPulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // 1. Initial State: The screen is covered (Big Circle).
    // Allow a brief moment for the user to perceive the brand color/cover.
    await Future.delayed(const Duration(milliseconds: 600));

    // 2. Shrink to reveal content (Big -> Small)
    // We start at value 1.0 (Big) and reverse to 0.0 (Small).
    _transitionController.duration = const Duration(milliseconds: 1800);
    await _transitionController.reverse();

    // Hide the tiny remnant
    setState(() {
      _introCompleted = true;
    });

    // Trigger Content Fade In
    if (mounted) {
      context.read<WelcomeProvider>().setShowContent(true);
    } // ... rest of the function continues as previously defined

    // 4. Wait for reading time
    await Future.delayed(const Duration(milliseconds: 3500));

    // 5. Outro: Smooth Fade/Slide instead of Circle
    if (mounted) {
      // Hide content first smoothly
      context.read<WelcomeProvider>().setShowContent(false);

      // Short delay for the fade out to complete
      await Future.delayed(const Duration(milliseconds: 1000));

      // 6. Navigate
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingPage(),
            transitionsBuilder: (_, animation, __, child) {
              const begin = Offset(0.0, 0.1); // Slight slide up
              const end = Offset.zero;
              const curve = Curves.easeOutQuart;

              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              var fadeAnimation = Tween(
                begin: 0.0,
                end: 1.0,
              ).animate(animation);

              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(position: offsetAnimation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 1200),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _transitionController.dispose();
    _logoPulseController.dispose();
    _particleController.dispose();
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
  }) {
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

        left += xValue * xAmplitude;
        top += yValue * yAmplitude;

        return Positioned(
          top: top - size / 2,
          left: left - size / 2,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color.withOpacity(0.6), color.withOpacity(0.0)],
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
    final screenSize = MediaQuery.of(context).size;
    // Calculate diagonal for full cover
    final maxDimension = max(screenSize.width, screenSize.height);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // --- 1. Background Layer (Always animating) ---
          _buildBlob(
            color: AppColors.primary,
            size: 450,
            controller: _controller1,
            startX: 0.8,
            startY: 0.2,
            xAmplitude: 150,
            yAmplitude: 100,
          ),
          _buildBlob(
            color: AppColors.secondary,
            size: 500,
            controller: _controller2,
            startX: 0.2,
            startY: 0.8,
            xAmplitude: 120,
            yAmplitude: 200,
            invertX: true,
          ),
          _buildBlob(
            color: AppColors.accentLight,
            size: 350,
            controller: _controller3,
            startX: 0.5,
            startY: 0.5,
            xAmplitude: 180,
            yAmplitude: 120,
            invertY: true,
          ),
          _buildBlob(
            color: AppColors.warning.withOpacity(0.5),
            size: 400,
            controller: _controller1,
            startX: 0.9,
            startY: 0.9,
            xAmplitude: 100,
            yAmplitude: 80,
            invertX: true,
            invertY: true,
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 40,
                sigmaY: 40,
              ), // Reduced blur for performance
              child: Container(color: Colors.white.withOpacity(0.05)),
            ),
          ),

          // --- 2. Particle Layer ---
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Stack(
                children: _particles.map((p) {
                  final x = (p.dx + _particleController.value) % 1.0;
                  final y = (p.dy + sin(_particleController.value * pi)) % 1.0;
                  return Positioned(
                    left: x * screenSize.width,
                    top: y * screenSize.height,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // --- 3. Content Layer ---
          Consumer<WelcomeProvider>(
            builder: (context, provider, child) {
              return SafeArea(
                child: Stack(
                  children: [
                    Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 1000),
                        opacity: provider.showContent ? 1.0 : 0.0,
                        curve: Curves.easeOut,
                        child: SingleChildScrollView(
                          // Add scroll for small screens
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _logoPulseController,
                                builder: (context, child) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Pulsating Glow Effect
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary.withOpacity(
                                            0.05,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(
                                                    _pulseOpacity.value,
                                                  ),
                                              blurRadius: 80,
                                              spreadRadius: 25,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Refined Brand Logo (Slightly smaller as requested)
                                      Transform.translate(
                                        offset: Offset(
                                          0,
                                          _floatAnimation.value,
                                        ),
                                        child: Transform.scale(
                                          scale: _pulseScale.value,
                                          child: Image.asset(
                                            "assets/edunova_logo.png",
                                            width: min(
                                              screenSize.width * 0.65,
                                              260,
                                            ),
                                            height: min(
                                              screenSize.width * 0.65,
                                              260,
                                            ),
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Icon(
                                                    Icons.auto_awesome_rounded,
                                                    size: min(
                                                      screenSize.width * 0.3,
                                                      100,
                                                    ),
                                                    color: AppColors.primary,
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              const SizedBox(height: 16),
                              // Elegant Script Typography with Vibrant Gradient
                              Text(
                                "EduNova", // Corrected casing to EduNova
                                style: GoogleFonts.libreBaskerville(
                                  fontSize: min(
                                    screenSize.width * 0.15,
                                    60,
                                  ), // Adjusted size for Serif font
                                  fontWeight: FontWeight.bold,
                                  color: AppColors
                                      .primaryText, // Restored Navy Blue
                                  height: 1.0,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primary.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.1),
                                  ),
                                ),
                                child: Text(
                                  "YOUR LEARNING STAR",
                                  textAlign: TextAlign.center,
                                  style: TextDesign.pageSubtitle.copyWith(
                                    color: AppColors.primary,
                                    fontSize: min(screenSize.width * 0.04, 16),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                    ), // Closes Center
                    // Copyright Footer
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 1000),
                        opacity: provider.showContent ? 1.0 : 0.0,
                        child: Center(
                          child: Text(
                            "© 2025 EduNova • Your Learning Star",
                            style: TextDesign.small.copyWith(
                              color: AppColors.mutedText.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // --- 3. Transition Overlay Circle ---
          if (!_introCompleted)
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                // Determine scale based on animation value.
                // Value 0.1 -> Small | Value 3.0 -> Covers screen
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: maxDimension,
                    height: maxDimension,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Updated Gradient for "Comfort"
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentLight.withOpacity(0.9), // Softer Mint
                          AppColors.primary.withOpacity(0.6), // Hint of Teal
                        ],
                        stops: const [0.0, 1.0],
                        radius: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 50,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
