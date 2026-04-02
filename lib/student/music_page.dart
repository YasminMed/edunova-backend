import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../providers/music_provider.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _starController;
  
  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseController.stop(); // Start stopped, resume on play

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _starController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Future<void> _pickAndAddMusic(MusicProvider musicProvider) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true, // Crucial for Web since path is null
    );
    
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;

      if (!mounted) return;

      final TextEditingController nameController = TextEditingController();
      String? customName = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: Theme.of(ctx).cardColor,
            title: Text(
              AppLocalizations.of(ctx)?.translate('music_name') ?? 'Music Name',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(ctx)?.translate('enter_music_name') ?? 'Enter music name',
              ),
              autofocus: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: Text(AppLocalizations.of(ctx)?.translate('cancel') ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
                child: Text(AppLocalizations.of(ctx)?.translate('add') ?? 'Add'),
              ),
            ],
          );
        },
      );

      if (customName == null || customName.isEmpty) return;

      // Pass the name, the path (might be null on web), and the bytes (for web support)
      await musicProvider.addCustomTrack(
        name: customName, 
        filePath: file.path, 
        bytes: file.bytes,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final musicProvider = Provider.of<MusicProvider>(context);

    // Update pulse controller based on global playing state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (musicProvider.isPlaying && !_pulseController.isAnimating) {
        _pulseController.repeat();
      } else if (!musicProvider.isPlaying && _pulseController.isAnimating) {
        _pulseController.stop();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.translate('music_page') ?? 'Study Music',
          style: TextDesign.h2.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEnhancedPlayerCard(context, musicProvider),
            const SizedBox(height: 32),
            Text(
              l10n?.translate('library') ?? 'Focus Library',
              style: TextDesign.h3.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: musicProvider.library.length + 1,
              itemBuilder: (context, index) {
                if (index < musicProvider.library.length) {
                  final item = musicProvider.library[index];
                  final isCurrent = musicProvider.currentTrack == item['id'];
                  return _buildInteractiveMusicCard(context, item, isCurrent, musicProvider);
                } else {
                  return _buildAddMusicCard(context, musicProvider);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPlayerCard(BuildContext context, MusicProvider provider) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final currentTrackData = provider.library.firstWhere(
      (t) => t['id'] == provider.currentTrack,
      orElse: () => provider.library.first,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161D) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Dreamy Star Field & Bokeh Background
            SizedBox(
              width: double.infinity,
              height: 300,
              child: AnimatedBuilder(
                animation: _starController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: DreamyBackgroundPainter(
                      progress: _starController.value,
                      color: currentTrackData['color'] as Color,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),

            // Glassmorphism Overlay
            Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.02 : 0.3),
                    Colors.white.withValues(alpha: isDark ? 0.01 : 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Player Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Now Playing Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (currentTrackData['color'] as Color).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n?.translate('now_playing') ?? 'NOW PLAYING',
                      style: TextStyle(
                        color: currentTrackData['color'] as Color,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Track icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (currentTrackData['color'] as Color).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      currentTrackData['icon'] as IconData,
                      color: currentTrackData['color'] as Color,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Track title
                  Text(
                    provider.formatTitle(currentTrackData['title'] ?? currentTrackData['id']),
                    style: TextDesign.h2.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Progress bar
                  if (provider.duration > Duration.zero)
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                            activeTrackColor: currentTrackData['color'] as Color,
                            inactiveTrackColor: (currentTrackData['color'] as Color).withValues(alpha: 0.2),
                            thumbColor: currentTrackData['color'] as Color,
                          ),
                          child: Slider(
                            value: provider.position.inSeconds.toDouble().clamp(0, provider.duration.inSeconds.toDouble()),
                            max: provider.duration.inSeconds.toDouble(),
                            onChanged: (value) {
                              provider.player.seek(Duration(seconds: value.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(provider.position),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                              ),
                              Text(
                                _formatDuration(provider.duration),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),

                  // Controls: -10 | play/pause | +10
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        Icons.replay_10_rounded,
                        () => provider.skip(-10),
                        currentTrackData['color'] as Color,
                      ),
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: () => provider.togglePlay(null),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                currentTrackData['color'] as Color,
                                (currentTrackData['color'] as Color).withValues(alpha: 0.7),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (currentTrackData['color'] as Color).withValues(alpha: 0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            provider.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      _buildControlButton(
                        Icons.forward_10_rounded,
                        () => provider.skip(10),
                        currentTrackData['color'] as Color,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap, Color color) {
    return IconButton(
      icon: Icon(icon, size: 36),
      color: color.withValues(alpha: 0.85),
      onPressed: onTap,
    );
  }

  Widget _buildInteractiveMusicCard(
    BuildContext context,
    Map<String, dynamic> item,
    bool isCurrent,
    MusicProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final Color cardColor = item['color'] as Color;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 1.0, end: isCurrent ? 1.05 : 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => provider.togglePlay(item),
            child: Container(
              decoration: BoxDecoration(
                color: isCurrent ? Colors.transparent : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                gradient: isCurrent
                    ? LinearGradient(
                        colors: [
                          cardColor.withValues(alpha: 0.2),
                          cardColor.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: Border.all(
                  color: isCurrent
                      ? cardColor
                      : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  width: isCurrent ? 3 : 2,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: cardColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  if (isCurrent && provider.isPlaying)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CardGlowPainter(color: cardColor),
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'] as IconData, // Kept the item's original icon as requested
                            color: cardColor,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          provider.formatTitle(l10n?.translate(item['id']) ?? item['title'] ?? item['id']),
                          style: TextDesign.h3.copyWith(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddMusicCard(BuildContext context, MusicProvider provider) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => _pickAndAddMusic(provider),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mutedText.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.mutedText,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.translate('add_music') ?? 'Add Music',
              style: TextDesign.body.copyWith(
                fontSize: 14,
                color: AppColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DreamyBackgroundPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  DreamyBackgroundPainter({
    required this.progress,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw small stars
    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 2.0;
      final opacity = (math.sin(progress * 2 * math.pi + i) + 1) / 2;

      paint.color = Colors.white.withValues(alpha: opacity * (isDark ? 0.4 : 0.6));
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }

    // Draw larger luminous bokeh circles
    final quadrants = [
      const Offset(0.2, 0.2),
      const Offset(0.8, 0.3),
      const Offset(0.3, 0.8),
      const Offset(0.7, 0.7),
    ];

    for (int i = 0; i < quadrants.length; i++) {
      final q = quadrants[i];
      final movementX = math.sin(progress * math.pi + i) * 20;
      final movementY = math.cos(progress * math.pi + i) * 20;

      final x = (q.dx * size.width) + movementX;
      final y = (q.dy * size.height) + movementY;
      final circleRadius = 50.0 + (i * 10);

      paint.color = color.withValues(alpha: isDark ? 0.07 : 0.18);
      canvas.drawCircle(Offset(x, y), circleRadius, paint);

      paint.color = color.withValues(alpha: isDark ? 0.04 : 0.1);
      canvas.drawCircle(Offset(x, y), circleRadius * 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DreamyBackgroundPainter oldDelegate) => true;
}

class CardGlowPainter extends CustomPainter {
  final Color color;
  CardGlowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.6,
      paint,
    );
  }

  @override
  bool shouldRepaint(CardGlowPainter oldDelegate) => false;
}
