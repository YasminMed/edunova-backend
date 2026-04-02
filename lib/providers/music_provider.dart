import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_audio_source.dart';

class MusicProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String _currentTrack = 'rain_focus';
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  List<Map<String, dynamic>> _library = [
    {
      'id': 'rain_focus',
      'title': 'Calming Rain',
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFF6366F1),
      'asset': 'assets/audio/calming-rain.mp3',
    },
    {
      'id': 'nature_focus',
      'title': 'Birds & Nature',
      'icon': Icons.forest_rounded,
      'color': const Color(0xFF10B981),
      'asset': 'assets/audio/birds-nature.mp3',
    },
    {
      'id': 'piano_focus',
      'title': 'Study Piano',
      'icon': Icons.piano_rounded,
      'color': const Color(0xFF3B82F6),
      'asset': 'assets/audio/study-piano-music.mp3',
    },
  ];

  AudioPlayer get player => _player;
  bool get isPlaying => _isPlaying;
  String get currentTrack => _currentTrack;
  Duration get duration => _duration;
  Duration get position => _position;
  List<Map<String, dynamic>> get library => _library;

  MusicProvider() {
    _initAudioSession();
    _setupAudioListeners();
    _loadCustomTracks();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _setupAudioListeners() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _player.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      notifyListeners();
    });

    _player.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });
  }

  Future<void> togglePlay(Map<String, dynamic>? trackToPlay) async {
    if (trackToPlay != null && trackToPlay['id'] != _currentTrack) {
      await playTrack(trackToPlay);
      return;
    }

    if (_player.processingState == ProcessingState.idle) {
      final track = _library.firstWhere(
        (t) => t['id'] == _currentTrack,
        orElse: () => _library.first,
      );
      await playTrack(track);
    } else {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
    }
  }

  Future<void> playTrack(Map<String, dynamic> track) async {
    try {
      await _player.stop();
      if (track['bytes'] != null) {
        await _player.setAudioSource(MyAudioSource(track['bytes'] as Uint8List));
      } else if (track['asset'] != null) {
        await _player.setAsset(track['asset']);
      } else if (track['filePath'] != null) {
        await _player.setFilePath(track['filePath']);
      }
      
      // Ensure looping is on
      await _player.setLoopMode(LoopMode.one);
      
      _currentTrack = track['id'];
      await _player.play();
      notifyListeners();
    } catch (e) {
      debugPrint("Error playing track: $e");
    }
  }

  void skip(int seconds) {
    var newPosition = _position + Duration(seconds: seconds);
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > _duration) newPosition = _duration;
    _player.seek(newPosition);
  }

  // Generate a display friendly title (e.g. "nature_focus" -> "Nature Focus")
  String formatTitle(String rawName) {
    if (rawName.isEmpty) return rawName;
    return rawName
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((str) => str.isEmpty ? '' : '${str[0].toUpperCase()}${str.substring(1)}')
        .join(' ');
  }

  Future<void> addCustomTrack({required String name, String? filePath, Uint8List? bytes}) async {
    final newTrack = {
      'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
      'title': name,
      // IconData can't be easily serialized, so we assign a default mapped one when loading
      'iconName': 'audiotrack',
      'colorValue': Colors.purple.value,
      'filePath': filePath,
      'bytes': bytes,
    };

    final tempTrack = _deserializeTrack(newTrack);
    _library.add(tempTrack);
    notifyListeners();
    await _saveCustomTracks();
  }

  Future<void> _saveCustomTracks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Only save custom tracks
      final customTracks = _library
          .where((t) => t['id'].toString().startsWith('custom_'))
          .map((t) => {
                'id': t['id'],
                'title': t['title'],
                'iconName': 'audiotrack',
                'colorValue': (t['color'] as Color).value,
                'filePath': t['filePath'],
              })
          .toList();
      
      await prefs.setString('custom_music_tracks', jsonEncode(customTracks));
    } catch (e) {
      debugPrint("Could not save custom tracks to SharedPreferences (likely Web quota exceeded): $e");
    }
  }

  Future<void> _loadCustomTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final customTracksJson = prefs.getString('custom_music_tracks');
    
    if (customTracksJson != null) {
      final List<dynamic> decoded = jsonDecode(customTracksJson);
      for (var item in decoded) {
        _library.add(_deserializeTrack(item as Map<String, dynamic>));
      }
      notifyListeners();
    }
  }

  Map<String, dynamic> _deserializeTrack(Map<String, dynamic> data) {
    Uint8List? parsedBytes;
    if (data['bytes'] != null) {
      parsedBytes = data['bytes'] as Uint8List;
    }

    return {
      'id': data['id'],
      'title': data['title'],
      'icon': Icons.audiotrack_rounded,
      'color': Color(data['colorValue'] ?? Colors.purple.value),
      'filePath': data['filePath'],
      'bytes': parsedBytes,
    };
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
