import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import 'selection_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SelectionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    final List<Map<String, dynamic>> slides = [
      {
        "title": "Welcome to EduNova",
        "subtitle":
            "Your academic journey, reimagined. Manage assignments, track grades, and excel in every subject.",
        "animation": "assets/animations/student_learning.json",
        "color": AppColors.primary,
      },
      {
        "title": "Empower Your Teaching",
        "subtitle":
            "Seamlessly organize courses, engage with students, and streamline your workflow with advanced tools.",
        "animation": "assets/animations/teacher_explained.json",
        "color": AppColors.secondary,
      },
      {
        "title": "AI-Powered Learning",
        "subtitle":
            "Get instant support from our smart AI assistant. Questions answered, concepts clarified, anytime.",
        "animation": "assets/animations/ai_assistant.json",
        "color": const Color(0xFFF4A261),
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Dynamic Background Gradient (Subtle)
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        slides[_currentPage]['color'].withOpacity(0.1),
                        Colors.black,
                      ]
                    : [
                        slides[_currentPage]['color'].withOpacity(0.05),
                        Colors.white,
                      ],
              ),
            ),
          ),

          // Main PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return _OnboardingSlide(
                data: slides[index],
                isDark: isDark,
                screenSize: screenSize,
              );
            },
          ),

          // Improved Bottom Navigation Area
          Positioned(
            bottom: 50,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Pagination Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 32 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? slides[_currentPage]['color']
                            : (isDark ? Colors.white24 : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Navigation Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip Button
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _currentPage == 2 ? 0.0 : 1.0,
                      child: TextButton(
                        onPressed: _currentPage == 2
                            ? null
                            : () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SelectionPage(),
                                ),
                              ),
                        child: Text(
                          "Skip",
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Next/Start Button
                    GestureDetector(
                      onTap: _onNext,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentPage == 2 ? 160 : 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: slides[_currentPage]['color'],
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: slides[_currentPage]['color'].withOpacity(
                                0.4,
                              ),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_currentPage == 2) ...[
                              const Text(
                                "Get Started",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final Size screenSize;

  const _OnboardingSlide({
    required this.data,
    required this.isDark,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation Container
          Expanded(
            flex: 3,
            child: Center(
              child: Lottie.asset(
                data['animation'],
                width: screenSize.width * 0.8,
                height: screenSize.width * 0.8,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if Lottie JSON is missing
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.image_not_supported_rounded,
                        size: 80,
                        color: isDark ? Colors.white24 : Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        // "Add ${data['animation']} to assets",
                        "Error: $error", // Debugging: Show actual error
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Text Content
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  data['title'],
                  textAlign: TextAlign.center,
                  style: TextDesign.h1.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    data['subtitle'],
                    textAlign: TextAlign.center,
                    style: TextDesign.body.copyWith(
                      fontSize: 16,
                      height: 1.5,
                      color: isDark ? Colors.white70 : AppColors.bodyText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
