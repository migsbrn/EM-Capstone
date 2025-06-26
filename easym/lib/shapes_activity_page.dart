import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ShapeAssessment.dart'; // Import the assessment page

class ShapesActivityPage extends StatefulWidget {
  const ShapesActivityPage({super.key});

  @override
  _ShapesActivityPageState createState() => _ShapesActivityPageState();
}

class _ShapesActivityPageState extends State<ShapesActivityPage> {
  final PageController _pageController = PageController();
  final FlutterTts _flutterTts = FlutterTts();
  int _currentPage = 0;
  int _previousPageIndex = 0;

  final List<Map<String, String>> shapes = const [
    {
      'sides': 'I have 4 sides',
      'corners': 'I have 4 corners',
      'name': 'I am a square',
      'image': 'assets/square.png',
    },
    {
      'sides': 'I have 3 sides',
      'corners': 'I have 3 corners',
      'name': 'I am a triangle',
      'image': 'assets/triangle.png',
    },
    {
      'sides': 'I have 5 sides',
      'corners': 'I have 5 corners',
      'name': 'I am a pentagon',
      'image': 'assets/pentagon.png',
    },
    {
      'sides': 'I have 6 sides',
      'corners': 'I have 6 corners',
      'name': 'I am a hexagon',
      'image': 'assets/hexagon.png',
    },
    {
      'sides': 'I have 8 sides',
      'corners': 'I have 8 corners',
      'name': 'I am an octagon',
      'image': 'assets/octagon.png',
    },
    {
      'sides': 'I have infinite sides',
      'corners': 'I have no corners',
      'name': 'I am a circle',
      'image': 'assets/circle.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadProgress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playShapeSound(_currentPage);
    });
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPage = prefs.getInt('shapeIndex') ?? 0;
      _pageController.jumpToPage(_currentPage);
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shapeIndex', _currentPage);
  }

  void _playShapeSound(int index) async {
    final shape = shapes[index];
    final text = '${shape['sides']}. ${shape['corners']}. ${shape['name']}';
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentPage < shapes.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
      _saveProgress();
    } else {
      await _flutterTts.stop();
      _showCompletionDialog();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
      _saveProgress();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFFFF6DC),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/star.png', height: 150, width: 150),
                    const SizedBox(height: 20),
                    const Text(
                      "What would you like to do next?",
                      style: TextStyle(
                        fontSize: 26,
                        color: Color(0xFF4C4F6B),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setInt('shapeIndex', 0);
                          setState(() {
                            _currentPage = 0;
                            _previousPageIndex = 0;
                            _pageController.jumpToPage(0);
                          });
                          Navigator.pop(context);
                          _playShapeSound(0);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C4F6B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Restart Module",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const ShapeAssessment()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C7E71),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Take Assessment",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 180,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context), // Navigate back to main menu
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF648BA2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Instruction: Identify the measurement of the shapes.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4E69),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: shapes.length,
                onPageChanged: (index) async {
                  setState(() {
                    _currentPage = index;
                  });
                  await _flutterTts.stop();
                  if (index > _previousPageIndex) {
                    _playShapeSound(index);
                  }
                  _previousPageIndex = index;
                  _saveProgress();
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildShapePage(
                        shapes[index]['sides']!,
                        shapes[index]['corners']!,
                        shapes[index]['name']!,
                        shapes[index]['image']!,
                        index,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _currentPage > 0 ? _previousPage : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF648BA2),
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 30,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Previous',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF648BA2),
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 30,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapePage(
      String sidesText, String cornersText, String shapeText, String imagePath, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: screenWidth * 0.7,
          height: screenHeight * 0.53,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.volume_up, size: 50, color: Colors.black),
                  onPressed: () => _playShapeSound(index),
                ),
              ),
              const SizedBox(height: 5),
              Image.asset(
                imagePath,
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                sidesText,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 33,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                cornersText,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                shapeText,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}