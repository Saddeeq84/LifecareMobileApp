// ignore_for_file: avoid_print, prefer_const_constructors, avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'file_opener_stub.dart'
    if (dart.library.io) 'file_opener_io.dart';
import 'dart:io';
import 'dart:async';

class CHWTrainingScreen extends StatefulWidget {
  const CHWTrainingScreen({super.key});

  @override
  State<CHWTrainingScreen> createState() => _CHWTrainingScreenState();
}

class _CHWTrainingScreenState extends State<CHWTrainingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _downloadingFiles = {};
  final Map<String, bool> _loadingTimeouts = {
    'video': false,
    'pdf': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _testFirestoreConnection();
    
    // Set timeouts for each type
    Timer(Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _loadingTimeouts['video'] = true;
        });
      }
    });
    
    Timer(Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _loadingTimeouts['pdf'] = true;
        });
      }
    });
  }

  Future<void> _testFirestoreConnection() async {
    try {
      print('🔍 Testing Firestore connection...');
      
      // Test authentication first
      final user = FirebaseAuth.instance.currentUser;
      print('🔍 Current user: ${user?.uid}');
      print('🔍 User email: ${user?.email}');
      
      // Test basic collection access without any filters
      print('🔍 Testing basic collection access...');
      final basicSnapshot = await FirebaseFirestore.instance
          .collection('training_materials')
          .limit(10)
          .get();
      print('✅ Basic collection access successful. Found ${basicSnapshot.docs.length} documents');
      
      if (basicSnapshot.docs.isNotEmpty) {
        basicSnapshot.docs.forEach((doc) {
          final data = doc.data();
          print('📄 Document: ${data['title'] ?? 'No title'} | Type: ${data['type'] ?? 'No type'} | Active: ${data['isActive'] ?? 'No isActive'}');
        });
      } else {
        print('⚠️ No documents found in training_materials collection');
      }
      
      // Test specific type queries separately
      print('🔍 Testing video query...');
      try {
        final videoQuery = await FirebaseFirestore.instance
            .collection('training_materials')
            .where('type', isEqualTo: 'video')
            .get()
            .timeout(Duration(seconds: 5));
        print('🎥 Videos found: ${videoQuery.docs.length}');
        videoQuery.docs.forEach((doc) {
          print('🎥 Video: ${doc.data()['title']}');
        });
      } catch (e) {
        print('❌ Video query failed: $e');
      }
      
      print('🔍 Testing PDF query...');
      try {
        final pdfQuery = await FirebaseFirestore.instance
            .collection('training_materials')
            .where('type', isEqualTo: 'pdf')
            .get()
            .timeout(Duration(seconds: 5));
        print('📄 PDFs found: ${pdfQuery.docs.length}');
        pdfQuery.docs.forEach((doc) {
          print('📄 PDF: ${doc.data()['title']}');
        });
      } catch (e) {
        print('❌ PDF query failed: $e');
      }
      
    } catch (e) {
      print('❌ Firestore connection error: $e');
      print('❌ Error type: ${e.runtimeType}');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Get training resources filtered by type
  Stream<QuerySnapshot> _getResourcesStream(String type) {
    print('🔍 Loading training materials for type: $type');
    // Ultra-simplified query for debugging - just type filter with timeout
    return FirebaseFirestore.instance
        .collection('training_materials')
        .where('type', isEqualTo: type)
        .snapshots()
        .timeout(
          Duration(seconds: 10),
          onTimeout: (sink) {
            print('❌ Query timeout for type: $type');
            sink.addError('Query timeout - check your connection');
          },
        );
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
        // Update download count
        FirebaseFirestore.instance
            .collection('training_materials')
            .doc(docId)
            .update({'downloadCount': FieldValue.increment(1)});
        try {
          await openFile(filePath);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open PDF file')),
            );
          }
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
        print('📱 StreamBuilder for $type - State: ${snapshot.connectionState}');
        print('📱 Has data: ${snapshot.hasData}');
        print('📱 Has error: ${snapshot.hasError}');
        
        if (snapshot.hasData) {
          print('📱 Documents count for $type: ${snapshot.data!.docs.length}');
          snapshot.data!.docs.forEach((doc) {
            final data = doc.data() as Map<String, dynamic>;
            print('📱 Document: ${data['title']} (${data['type']}) - Active: ${data['isActive']}');
          });
        }

        if (snapshot.hasError) {
          print('📱 Firestore error for $type: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading training materials'),
                const SizedBox(height: 8),
                Text('${snapshot.error}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Check if we should show timeout state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('📱 Showing loading indicator for $type');
          
          // If timeout occurred, show the empty state instead of endless loading
          if (_loadingTimeouts[type] == true) {
            print('📱 Loading timeout reached for $type, showing empty state');
            return _buildEmptyState(type);
          }
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Loading $type materials...'),
                const SizedBox(height: 24),
                // Add a manual refresh button during loading
                TextButton(
                  onPressed: () {
                    print('🔍 Manual refresh triggered for $type');
                    setState(() {
                      _loadingTimeouts[type] = false; // Reset timeout
                    });
                  },
                  child: Text('Taking too long? Tap to refresh'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('📱 No data or empty docs for $type');
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
            type == 'video' ? 'No Training Videos' : 'No Training Materials',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            type == 'video'
                ? 'Training videos will appear here when\nadmin uploads them for CHWs.'
                : 'Training materials and documents will\nappear here when admin uploads them.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              print('🔍 Manual debug test for $type');
              try {
                final testSnapshot = await FirebaseFirestore.instance
                    .collection('training_materials')
                    .where('type', isEqualTo: type)
                    .get();
                print('🔍 Manual test results for $type: ${testSnapshot.docs.length} docs');
                testSnapshot.docs.forEach((doc) {
                  print('🔍 Found: ${doc.data()['title']}');
                });
              } catch (e) {
                print('🔍 Manual test error: $e');
              }
            },
            child: Text('Debug: Test $type Query'),
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
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.teal,
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
                  backgroundColor: Colors.teal,
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
        title: const Text('CHW Training'),
        backgroundColor: Colors.teal,
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
              text: 'Training Materials',
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
