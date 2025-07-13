import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          _buildFirestoreEducationTab('video'),
          _buildFirestoreEducationTab('audio'),
          _buildFirestoreEducationTab('infographic'),
        ],
      ),
    );
  }

  Widget _buildFirestoreEducationTab(String contentType) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('education_materials')
          .where('contentType', isEqualTo: contentType)
          .where('language', isEqualTo: language)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading education materials'));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('No content available.'));
        }

        if (contentType == 'infographic') {
          return GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: docs.map((doc) {
              final title = doc['title'] ?? 'Untitled';
              final url = doc['url'];
              return _infographicCard(title, url);
            }).toList(),
          );
        } else {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((doc) {
              final id = doc.id;
              final title = doc['title'] ?? 'Untitled';
              final url = doc['url'];
              final viewed = _viewedContent.contains(id);
              final thumbnail = doc['thumbnailUrl'];

              return _educationCard(
                id: id,
                title: title,
                imageUrl: thumbnail,
                viewed: viewed,
                onTap: () {
                  _markViewed(id);
                  if (contentType == 'video') {
                    _openVideoPlayer(url);
                  } else if (contentType == 'audio') {
                    _openAudioPlayer(url);
                  }
                },
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _educationCard({
    required String id,
    required String title,
    String? imageUrl,
    required bool viewed,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: imageUrl != null
            ? Image.network(imageUrl, width: 50, fit: BoxFit.cover)
            : const Icon(Icons.image),
        title: Text(title),
        subtitle: viewed ? const Text("Viewed", style: TextStyle(color: Colors.green)) : null,
        trailing: const Icon(Icons.play_circle_fill),
        onTap: onTap,
      ),
    );
  }

  Widget _infographicCard(String title, String imageUrl) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Viewing "$title"...')));
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
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

  void _openVideoPlayer(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(videoUrl: url),
      ),
    );
  }

  void _openAudioPlayer(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AudioPlayerScreen(audioUrl: url),
      ),
    );
  }
}

// -------------------- Video Player --------------------

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
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

// -------------------- Audio Player --------------------

class AudioPlayerScreen extends StatefulWidget {
  final String audioUrl;
  const AudioPlayerScreen({super.key, required this.audioUrl});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.setUrl(widget.audioUrl);
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
// -------------------- End of Patient Education Screen --------------------