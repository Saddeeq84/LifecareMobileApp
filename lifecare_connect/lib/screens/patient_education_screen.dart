import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

class PatientEducationScreen extends StatefulWidget {
  const PatientEducationScreen({super.key});

  @override
  State<PatientEducationScreen> createState() => _PatientEducationScreenState();
}

class _PatientEducationScreenState extends State<PatientEducationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String language = 'English';
  Set<String> _viewedContent = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _viewedContent = prefs.getStringList('viewed_content')?.toSet() ?? {};
    });
  }

  Future<void> _markViewed(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _viewedContent.add(id);
      prefs.setStringList('viewed_content', _viewedContent.toList());
    });
  }

  void _toggleLanguage() {
    setState(() {
      language = (language == 'English') ? 'Hausa' : 'English';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Education ($language)'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: 'Switch Language',
            onPressed: _toggleLanguage,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.ondemand_video), text: 'Videos'),
            Tab(icon: Icon(Icons.audiotrack), text: 'Audio'),
            Tab(icon: Icon(Icons.image), text: 'Infographics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVideoTab(),
          _buildAudioTab(),
          _buildInfographicTab(),
        ],
      ),
    );
  }

  Widget _buildVideoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _educationCard(
          id: 'video1',
          title: 'Nutrition During Pregnancy',
          imagePath: 'assets/videos/nutrition.png',
          onTap: () => _openVideoPlayer('assets/videos/sample_video.mp4', 'video1'),
        ),
        _educationCard(
          id: 'video2',
          title: 'Hygiene for New Mothers',
          imagePath: 'assets/videos/hygiene.png',
          onTap: () => _openVideoPlayer('assets/videos/sample_video2.mp4', 'video2'),
        ),
      ],
    );
  }

  Widget _buildAudioTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _educationCard(
          id: 'audio1',
          title: 'Danger Signs in Pregnancy',
          imagePath: 'assets/audio/alert.png',
          onTap: () => _openAudioPlayer('assets/audio/sample_audio.mp3', 'audio1'),
        ),
        _educationCard(
          id: 'audio2',
          title: 'Child Nutrition (Hausa)',
          imagePath: 'assets/audio/food.png',
          onTap: () => _openAudioPlayer('assets/audio/sample_audio2.mp3', 'audio2'),
        ),
      ],
    );
  }

  Widget _buildInfographicTab() {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _infographicCard('Breastfeeding Tips', 'assets/images/breastfeeding.png'),
        _infographicCard('Mosquito Net Use', 'assets/images/mosquito.png'),
      ],
    );
  }

  Widget _educationCard({
    required String id,
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final viewed = _viewedContent.contains(id);
    return Card(
      child: ListTile(
        leading: Image.asset(imagePath, width: 50),
        title: Text(title),
        subtitle: viewed ? const Text("Viewed", style: TextStyle(color: Colors.green)) : null,
        trailing: const Icon(Icons.play_circle_fill),
        onTap: () {
          onTap();
          _markViewed(id);
        },
      ),
    );
  }

  Widget _infographicCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Viewing "$title"...')));
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _openVideoPlayer(String assetPath, String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(videoAsset: assetPath),
      ),
    );
  }

  void _openAudioPlayer(String assetPath, String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AudioPlayerScreen(audioAsset: assetPath),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoAsset;

  const VideoPlayerScreen({super.key, required this.videoAsset});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video")),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class AudioPlayerScreen extends StatefulWidget {
  final String audioAsset;

  const AudioPlayerScreen({super.key, required this.audioAsset});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.setAsset(widget.audioAsset);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle,
                size: 100, color: Colors.green),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _togglePlay,
              child: Text(_isPlaying ? "Pause" : "Play"),
            ),
          ],
        ),
      ),
    );
  }
}
// This code defines a screen for patient education with tabs for videos, audio, and infographics, allowing users to switch languages between English and Hausa.