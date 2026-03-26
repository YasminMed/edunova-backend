import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _starController;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String _currentTrack = 'focus_nature';
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  final List<Map<String, dynamic>> _library = [
    {
      'id': 'nature_focus',
      'title': 'Nature Focus',
      'icon': Icons.forest_rounded,
      'color': const Color(0xFF10B981),
      'url': 'assets/audio/nature_focus.mp3',
    },
    {
      'id': 'piano_focus',
      'title': 'Piano Focus',
      'icon': Icons.piano_rounded,
      'color': Colors.blue,
      'url': 'assets/audio/piano_focus.mp3',
    },
    {
      'id': 'rainy_focus',
      'title': 'Rainy Focus',
      'icon': Icons.umbrella_rounded,
      'color': Colors.indigo,
      'url': 'assets/audio/rainy_focus.mp3',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAudioSession();
    _setupAudioListeners();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _setupAudioListeners() {
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (_isPlaying) {
            _pulseController.repeat();
          } else {
            _pulseController.stop();
          }
        });
      }
    });

    _player.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration.zero);
    });

    _player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _starController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_player.processingState == ProcessingState.idle) {
      final track = _library.firstWhere((t) => t['id'] == _currentTrack);
      await _playTrack(track);
    } else {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
    }
  }

  Future<void> _playTrack(Map<String, dynamic> track) async {
    try {
      if (track['url'] != null) {
        if (track['url'].startsWith('assets/')) {
          await _player.setAsset(track['url']);
        } else {
          await _player.setUrl(track['url']);
        }
      } else if (track['filePath'] != null) {
        await _player.setFilePath(track['filePath']);
      }
      _currentTrack = track['id'];
      await _player.play();
    } catch (e) {
      debugPrint("Error playing track: $e");
    }
  }

  void _skip(int seconds) {
    var newPosition = _position + Duration(seconds: seconds);
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > _duration) newPosition = _duration;
    _player.seek(newPosition);
  }

  Future<void> _pickAndAddMusic() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      
      if (!mounted) return;
      
      final TextEditingController nameController = TextEditingController();
      String? customName = await showDialog<String>(
        context: context,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              AppLocalizations.of(context)?.translate('music_name') ?? 'Music Name',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)?.translate('enter_music_name') ?? 'Enter music name',
              ),
              autofocus: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text(AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, nameController.text.trim()),
                child: Text(AppLocalizations.of(context)?.translate('add') ?? 'Add'),
              ),
            ],
          );
        },
      );

      if (customName == null || customName.isEmpty) return;

      setState(() {
        _library.add({
          'id': customName,
          'icon': Icons.audiotrack_rounded,
          'color': Colors.purple,
          'filePath': file.path,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

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
            // Top Player Card with Dreamy Animation
            _buildEnhancedPlayerCard(context),
            const SizedBox(height: 32),

            // Library Section
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
              itemCount: _library.length + 1,
              itemBuilder: (context, index) {
                if (index < _library.length) {
                  final item = _library[index];
                  final isCurrent = _currentTrack == item['id'];
                  return _buildInteractiveMusicCard(context, item, isCurrent);
                } else {
                  return _buildAddMusicCard(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPlayerCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161D) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dreamy Star Field & Bokeh Background
            AnimatedBuilder(
              animation: _starController,
              builder: (context, child) {
                return CustomPaint(
                  painter: DreamyBackgroundPainter(
                    progress: _starController.value,
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                  size: const Size(double.infinity, double.infinity),
                );
              },
            ),

            // Glassmorphism Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(isDark ? 0.02 : 0.3),
                    Colors.white.withOpacity(isDark ? 0.01 : 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Player Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n?.translate('now_playing') ?? 'NOW PLAYING',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                    Text(
                      l10n?.translate(_currentTrack) ??
                          _library.firstWhere((t) => t['id'] == _currentTrack, orElse: () => {'id': _currentTrack})['title'] ??
                          _currentTrack.replaceAll('_', ' '),
                      style: TextDesign.h2.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 32),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(Icons.replay_10_rounded, () => _skip(-10)),
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      _buildControlButton(Icons.forward_10_rounded, () => _skip(10)),
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

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 36),
      color: AppColors.primary.withOpacity(0.8),
      onPressed: onTap,
    );
  }

  Widget _buildInteractiveMusicCard(
    BuildContext context,
    Map<String, dynamic> item,
    bool isCurrent,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 1.0, end: isCurrent ? 1.05 : 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () async {
              setState(() {
                _currentTrack = item['id'];
              });
              await _playTrack(item);
            },
            child: Container(
              decoration: BoxDecoration(
                color: isCurrent
                    ? Colors.transparent
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                gradient: isCurrent
                    ? LinearGradient(
                        colors: [
                          item['color'].withOpacity(0.2),
                          item['color'].withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: Border.all(
                  color: isCurrent
                      ? item['color']
                      : Theme.of(context).dividerColor.withOpacity(0.1),
                  width: isCurrent ? 3 : 2,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: item['color'].withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  if (isCurrent && _isPlaying)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CardGlowPainter(color: item['color']),
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: item['color'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'],
                            color: item['color'],
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n?.translate(item['id']) ?? item['title'] ?? item['id'],
                          style: TextDesign.h3.copyWith(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
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

  Widget _buildAddMusicCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: _pickAndAddMusic,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mutedText.withOpacity(0.1),
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

      paint.color = Colors.white.withOpacity(opacity * (isDark ? 0.4 : 0.6));
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }

    // Draw larger luminous bokeh circles (spread out across 4 quadrants)
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

      // Create a soft radial-like look using layered circles
      paint.color = color.withOpacity(isDark ? 0.05 : 0.15);
      canvas.drawCircle(Offset(x, y), circleRadius, paint);

      // Add a smaller, brighter core for some circles to mimic light spots
      paint.color = color.withOpacity(isDark ? 0.03 : 0.1);
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
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Subtle glow radiating from center of card
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.6,
      paint,
    );
  }

  @override
  bool shouldRepaint(CardGlowPainter oldDelegate) => false;
}
