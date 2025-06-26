import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class UploadedMaterialsPage extends StatefulWidget {
  @override
  _UploadedMaterialsPageState createState() => _UploadedMaterialsPageState();
}

class _UploadedMaterialsPageState extends State<UploadedMaterialsPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> materials = [];
  List<Map<String, dynamic>> assessments = [];
  String? errorMessage;
  late TabController _tabController;
  int? _hoveredTabIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchMaterials();
    fetchAssessments();
    _tabController.addListener(() {
      setState(() {
        errorMessage = null;
        if (_tabController.index == 0 && materials.isEmpty) {
          errorMessage = 'No uploaded materials found.';
        } else if (_tabController.index == 1 && assessments.isEmpty) {
          errorMessage = 'No assessments found.';
        }
        _hoveredTabIndex = _tabController.index;
      });
    });
    _hoveredTabIndex = 0;
  }

  void fetchMaterials() {
    FirebaseFirestore.instance
        .collection('contents')
        .where('type', isEqualTo: 'uploaded-material')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              setState(() {
                materials =
                    querySnapshot.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                errorMessage =
                    _tabController.index == 0 && materials.isEmpty
                        ? 'No uploaded materials found.'
                        : null;
              });
              print('Uploaded materials found: ${materials.length}');
            } else {
              setState(() {
                materials = [];
                errorMessage =
                    _tabController.index == 0
                        ? 'No uploaded materials found.'
                        : null;
              });
              print('No uploaded materials found');
            }
          },
          onError: (error) {
            setState(() {
              errorMessage = 'Error fetching materials: $error';
            });
            print('Error fetching materials: $error');
          },
        );
  }

  void fetchAssessments() {
    FirebaseFirestore.instance
        .collection('contents')
        .where('type', isEqualTo: 'assessment')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              setState(() {
                assessments =
                    querySnapshot.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                errorMessage =
                    _tabController.index == 1 && assessments.isEmpty
                        ? 'No assessments found.'
                        : null;
              });
              print('Assessments found: ${assessments.length}');
              print('Assessments data: ${assessments.toString()}');
            } else {
              setState(() {
                assessments = [];
                errorMessage =
                    _tabController.index == 1 ? 'No assessments found.' : null;
              });
              print('No assessments found');
            }
          },
          onError: (error) {
            setState(() {
              errorMessage = 'Error fetching assessments: $error';
            });
            print('Error fetching assessments: $error');
          },
        );
  }

  IconData getFileIcon(String? fileType) {
    if (fileType == 'application/pdf') return Icons.picture_as_pdf;
    if (fileType == 'application/vnd.ms-powerpoint' ||
        fileType ==
            'application/vnd.openxmlformats-officedocument.presentationml.presentation')
      return Icons.slideshow;
    if (fileType == 'application/msword' ||
        fileType ==
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
      return Icons.description;
    return Icons.insert_drive_file;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Tab Bar with Hover Effect on Individual Tabs
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE9D5),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(
                    0xFF4A4E69,
                  ), // Removed blue, using original text color
                  unselectedLabelColor: const Color(
                    0xFF4A4E69,
                  ).withOpacity(0.6),
                  indicator: BoxDecoration(
                    color: const Color(
                      0xFF648BA2,
                    ), // Kept original indicator color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                  ),
                  tabs: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _hoveredTabIndex = 0),
                      onExit:
                          (_) => setState(
                            () => _hoveredTabIndex = _tabController.index,
                          ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color:
                              _hoveredTabIndex == 0 || _tabController.index == 0
                                  ? Colors.grey[200]
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        child: const Tab(text: 'Materials'),
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _hoveredTabIndex = 1),
                      onExit:
                          (_) => setState(
                            () => _hoveredTabIndex = _tabController.index,
                          ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color:
                              _hoveredTabIndex == 1 || _tabController.index == 1
                                  ? Colors.grey[200]
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        child: const Tab(text: 'Quiz'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    errorMessage != null
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                errorMessage!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF4A4E69),
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF648BA2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  fetchMaterials();
                                  fetchAssessments();
                                },
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : TabBarView(
                          controller: _tabController,
                          children: [
                            materials.isEmpty
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF648BA2),
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: materials.length,
                                  itemBuilder: (context, index) {
                                    final material = materials[index];
                                    final file =
                                        material['file']
                                            as Map<String, dynamic>?;

                                    final fileName =
                                        file?['name']?.toString() ??
                                        'Unknown File';
                                    final fileType = file?['type']?.toString();
                                    final fileData = file?['data']?.toString();
                                    final topic =
                                        material['title']?.toString() ??
                                        'No Title';

                                    return Card(
                                      color: Colors.white,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      elevation: 2,
                                      child: ListTile(
                                        leading: Icon(
                                          getFileIcon(fileType),
                                          color: const Color(0xFF648BA2),
                                          size: 40,
                                        ),
                                        title: Text(
                                          fileName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4A4E69),
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        subtitle: Text(
                                          topic,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF6EABCF),
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      MaterialDetailPage(
                                                        fileName: fileName,
                                                        fileType: fileType,
                                                        fileData: fileData,
                                                        topic: topic,
                                                      ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                            assessments.isEmpty
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF648BA2),
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: assessments.length,
                                  itemBuilder: (context, index) {
                                    final assessment = assessments[index];
                                    final title =
                                        assessment['title']?.toString() ??
                                        'No Title';
                                    final category =
                                        assessment['category']?.toString() ??
                                        'No Category';
                                    final questions =
                                        assessment['questions']
                                            as List<dynamic>? ??
                                        [];

                                    return Card(
                                      color: Colors.white,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      elevation: 2,
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.quiz,
                                          color: Color(0xFF648BA2),
                                          size: 40,
                                        ),
                                        title: Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4A4E69),
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        subtitle: Text(
                                          '$category • ${questions.length} Questions',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF6EABCF),
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      AssessmentDetailPage(
                                                        title: title,
                                                        category: category,
                                                        questions: questions,
                                                      ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MaterialDetailPage extends StatefulWidget {
  final String fileName;
  final String? fileType;
  final String? fileData;
  final String topic;

  const MaterialDetailPage({
    required this.fileName,
    required this.fileType,
    required this.fileData,
    required this.topic,
  });

  @override
  _MaterialDetailPageState createState() => _MaterialDetailPageState();
}

class _MaterialDetailPageState extends State<MaterialDetailPage> {
  String? _tempFilePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _prepareFileForPreview();
  }

  Future<void> _prepareFileForPreview() async {
    if (widget.fileData == null || widget.fileType == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final bytes = base64Decode(widget.fileData!);
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/${widget.fileName}';
      final file = File(tempFilePath);
      await file.writeAsBytes(bytes);

      setState(() {
        _tempFilePath = tempFilePath;
        _isLoading = false;
      });
    } catch (e) {
      print('Error preparing file for preview: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> downloadFile(BuildContext context) async {
    if (widget.fileData == null || widget.fileType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File data or type is missing')),
      );
      return;
    }

    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
          return;
        }
      }

      final bytes = base64Decode(widget.fileData!);
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not access Downloads directory')),
        );
        return;
      }

      final downloadsDir = Directory(directory.path);
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      String extension;
      if (widget.fileType == 'application/pdf') {
        extension = '.pdf';
      } else if (widget.fileType == 'application/vnd.ms-powerpoint' ||
          widget.fileType ==
              'application/vnd.openxmlformats-officedocument.presentationml.presentation') {
        extension = '.pptx';
      } else if (widget.fileType == 'application/msword' ||
          widget.fileType ==
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
        extension = '.docx';
      } else {
        extension = '.bin';
      }

      final sanitizedFileName = widget.fileName.replaceAll(
        RegExp(r'[^\w\s-.]'),
        '_',
      );
      final filePath = '${downloadsDir.path}/$sanitizedFileName$extension';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: ${result.message}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded and opened: $filePath')),
        );
      }
    } catch (e) {
      print('Download error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error downloading file: $e')));
    }
  }

  IconData getFileIcon() {
    if (widget.fileType == 'application/pdf') return Icons.picture_as_pdf;
    if (widget.fileType == 'application/vnd.ms-powerpoint' ||
        widget.fileType ==
            'application/vnd.openxmlformats-officedocument.presentationml.presentation')
      return Icons.slideshow;
    if (widget.fileType == 'application/msword' ||
        widget.fileType ==
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
      return Icons.description;
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF648BA2),
        title: Text(
          widget.fileName,
          style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(getFileIcon(), color: const Color(0xFF648BA2), size: 50),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.fileName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4E69),
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.topic,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF6EABCF),
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF648BA2),
                        ),
                      )
                      : _tempFilePath != null &&
                          widget.fileType == 'application/pdf'
                      ? PDFView(
                        filePath: _tempFilePath!,
                        enableSwipe: true,
                        swipeHorizontal: false,
                        autoSpacing: true,
                        pageFling: true,
                        onError: (error) {
                          print('PDFView error: $error');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error loading PDF: $error'),
                            ),
                          );
                        },
                        onRender: (pages) {
                          print('PDF rendered with $pages pages');
                        },
                      )
                      : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                getFileIcon(),
                                size: 100,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Preview not available\nClick Download to view the file',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF4A4E69),
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed:
                    widget.fileData != null && widget.fileType != null
                        ? () => downloadFile(context)
                        : null,
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  'Download',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF648BA2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_tempFilePath != null) {
      File(_tempFilePath!).delete().catchError((e) {
        print('Error deleting temp file: $e');
      });
    }
    super.dispose();
  }
}

class AssessmentDetailPage extends StatefulWidget {
  final String title;
  final String category;
  final List<dynamic> questions;

  const AssessmentDetailPage({
    required this.title,
    required this.category,
    required this.questions,
  });

  @override
  _AssessmentDetailPageState createState() => _AssessmentDetailPageState();
}

class _AssessmentDetailPageState extends State<AssessmentDetailPage> {
  List<dynamic> selectedAnswers = [];
  bool isSubmitted = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    print('Questions received: ${widget.questions}');
    selectedAnswers = List.generate(widget.questions.length, (index) {
      final question = widget.questions[index];
      if (question is Map<String, dynamic>) {
        final type = question['type']?.toString() ?? 'multiple-choice';
        return (type == 'fill-in-the-blank') ? '' : null;
      } else {
        return '';
      }
    });
    print('Initialized selectedAnswers: $selectedAnswers');
  }

  void handleSubmit() {
    if (selectedAnswers.any(
      (answer) => answer == null || (answer is String && answer.isEmpty),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before submitting.'),
        ),
      );
      return;
    }

    int calculatedScore = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      String correctAnswer = '';
      if (question is Map<String, dynamic>) {
        correctAnswer = question['correctAnswer']?.toString() ?? '';
      }
      final studentAnswer = selectedAnswers[i];
      if (studentAnswer != null &&
          studentAnswer.toString().toLowerCase() ==
              correctAnswer.toLowerCase()) {
        calculatedScore++;
      }
    }

    setState(() {
      score = calculatedScore;
      isSubmitted = true;
    });
    print('Submitted - Score: $score');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF648BA2),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4E69),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: ${widget.category} • ${widget.questions.length} Questions',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6EABCF),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (isSubmitted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'You scored $score/${widget.questions.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              widget.questions.isEmpty
                  ? const Center(
                    child: Text(
                      'No questions available.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF4A4E69),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  )
                  : Column(
                    children:
                        widget.questions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final question = entry.value;
                          String questionText = 'No question text';
                          List<dynamic> options = [];
                          String correctAnswer = '';
                          String questionType = 'multiple-choice';
                          bool isFillInTheBlank = false;

                          if (question is Map<String, dynamic>) {
                            questionText =
                                question['questionText']?.toString() ??
                                'No question text';
                            options =
                                question['options'] as List<dynamic>? ?? [];
                            correctAnswer =
                                question['correctAnswer']?.toString() ?? '';
                            questionType =
                                question['type']?.toString() ??
                                'multiple-choice';
                            isFillInTheBlank =
                                questionType == 'fill-in-the-blank';
                          } else if (question is String) {
                            questionText = question;
                            isFillInTheBlank = true;
                          } else {
                            questionText = 'Invalid question format';
                          }

                          final selectedAnswer = selectedAnswers[index];
                          final isCorrect =
                              selectedAnswer != null &&
                              selectedAnswer.toString().toLowerCase() ==
                                  correctAnswer.toLowerCase();

                          print(
                            'Rendering question $index: type=$questionType, text=$questionText, options=$options, correct=$correctAnswer',
                          );

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Question ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6EABCF),
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  questionText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A4E69),
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (!isFillInTheBlank &&
                                    !isSubmitted &&
                                    options.isNotEmpty)
                                  Column(
                                    children:
                                        options.map((option) {
                                          final optionStr = option.toString();
                                          return RadioListTile<String>(
                                            title: Text(
                                              optionStr,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    isSubmitted
                                                        ? (optionStr ==
                                                                correctAnswer
                                                            ? Colors.green
                                                            : (optionStr ==
                                                                        selectedAnswer &&
                                                                    !isCorrect
                                                                ? Colors.red
                                                                : Color(
                                                                  0xFF4A4E69,
                                                                )))
                                                        : Color(0xFF4A4E69),
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                            value: optionStr,
                                            groupValue: selectedAnswer,
                                            onChanged:
                                                isSubmitted
                                                    ? null
                                                    : (value) {
                                                      setState(() {
                                                        selectedAnswers[index] =
                                                            value;
                                                      });
                                                      print(
                                                        'Selected answer for $index: $value',
                                                      );
                                                    },
                                            activeColor: const Color(
                                              0xFF648BA2,
                                            ),
                                          );
                                        }).toList(),
                                  )
                                else if (isFillInTheBlank && !isSubmitted)
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Your answer',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFF6EABCF),
                                        fontFamily: 'Montserrat',
                                      ),
                                      border: const UnderlineInputBorder(),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF6EABCF),
                                        ),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF648BA2),
                                        ),
                                      ),
                                    ),
                                    enabled: !isSubmitted,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAnswers[index] = value;
                                      });
                                      print('Input answer for $index: $value');
                                    },
                                    controller: TextEditingController(
                                      text: selectedAnswer?.toString() ?? '',
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Color(0xFF4A4E69),
                                    ),
                                  )
                                else if (!isSubmitted)
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Your answer (fallback)',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFF6EABCF),
                                        fontFamily: 'Montserrat',
                                      ),
                                      border: const UnderlineInputBorder(),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF6EABCF),
                                        ),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF648BA2),
                                        ),
                                      ),
                                    ),
                                    enabled: !isSubmitted,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAnswers[index] = value;
                                      });
                                      print(
                                        'Fallback input for $index: $value',
                                      );
                                    },
                                    controller: TextEditingController(
                                      text: selectedAnswer?.toString() ?? '',
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Color(0xFF4A4E69),
                                    ),
                                  ),
                                if (isSubmitted)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Your Answer: ${selectedAnswer ?? "Not answered"}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                isCorrect
                                                    ? Colors.green
                                                    : Colors.red,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Correct Answer: $correctAnswer',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
              if (!isSubmitted)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF648BA2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
