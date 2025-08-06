import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class DoctorClinicalResourcesScreen extends StatefulWidget {
  const DoctorClinicalResourcesScreen({super.key});

  @override
  State<DoctorClinicalResourcesScreen> createState() => _DoctorClinicalResourcesScreenState();
}

class _DoctorClinicalResourcesScreenState extends State<DoctorClinicalResourcesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _downloadingFiles = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Get clinical resources filtered by type
  Stream<QuerySnapshot> _getResourcesStream(String type) {
    return FirebaseFirestore.instance
        .collection('training_materials')
        .where('targetRole', isEqualTo: 'doctor')
        .where('type', isEqualTo: type)
        .where('isActive', isEqualTo: true)
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  /// Launch video URL in browser or video player
  Future<void> _playVideo(String url, String title) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open video')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening video: $e')),
        );
      }
    }
  }

  /// Download and open PDF file
  Future<void> _downloadAndOpenPdf(String url, String fileName, String docId) async {
    setState(() => _downloadingFiles[docId] = true);

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/$fileName';
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);


        FirebaseFirestore.instance
            .collection('training_materials')
            .doc(docId)
            .update({'downloadCount': FieldValue.increment(1)});


        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open PDF file')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download file')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading file: $e')),
        );
      }
    } finally {
      setState(() => _downloadingFiles[docId] = false);
    }
  }

  /// Build resource list for videos or materials
  Widget _buildResourceList(String type) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getResourcesStream(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(type);
        }

        final resources = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final doc = resources[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return type == 'video' 
                ? _buildVideoCard(data, doc.id)
                : _buildMaterialCard(data, doc.id);
          },
        );
      },
    );
  }

  /// Build empty state for each tab
  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'video' ? Icons.video_library : Icons.description,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            type == 'video' ? 'No Training Videos' : 'No Clinical Materials',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            type == 'video'
                ? 'Training videos will appear here when\nadmin uploads them for doctors.'
                : 'Clinical materials and documents will\nappear here when admin uploads them.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build video card
  Widget _buildVideoCard(Map<String, dynamic> data, String docId) {
    final title = data['title'] ?? 'Untitled Video';
    final description = data['description'] ?? 'No description';
    final uploadedAt = data['uploadedAt'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (uploadedAt != null)
                        Text(
                          'Uploaded: ${_formatDate(uploadedAt.toDate())}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Watch Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _playVideo(data['url'] ?? '', title),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build material (PDF) card
  Widget _buildMaterialCard(Map<String, dynamic> data, String docId) {
    final title = data['title'] ?? 'Untitled Document';
    final description = data['description'] ?? 'No description';
    final uploadedAt = data['uploadedAt'] as Timestamp?;
    final fileName = data['fileName'] ?? 'document.pdf';
    final downloadCount = data['downloadCount'] ?? 0;
    final isDownloading = _downloadingFiles[docId] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (uploadedAt != null)
                        Text(
                          'Uploaded: ${_formatDate(uploadedAt.toDate())}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      if (downloadCount > 0)
                        Text(
                          'Downloaded $downloadCount times',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: isDownloading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(isDownloading ? 'Downloading...' : 'Download & Open'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: isDownloading 
                    ? null
                    : () => _downloadAndOpenPdf(data['url'] ?? '', fileName, docId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Resources'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.video_library),
              text: 'Training Videos',
            ),
            Tab(
              icon: Icon(Icons.description),
              text: 'Clinical Materials',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResourceList('video'),
          _buildResourceList('pdf'),
        ],
      ),
    );
  }
}
