import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:easym/ReadingMaterialsPage.dart';

class ShapeAssessment extends StatefulWidget {
  const ShapeAssessment({super.key});

  @override
  State<ShapeAssessment> createState() => _ShapeAssessmentState();
}

class _ShapeAssessmentState extends State<ShapeAssessment> {
  final _flutterTts = FlutterTts();
  final _random = Random();
  int _index = 0, _score = 0;
  List<Map<String, dynamic>> _questions = [];
  late ConfettiController _confettiController;

  final List<Map<String, String>> shapes = const [
    {'sides': 'I have 4 sides', 'corners': 'I have 4 corners', 'name': 'I am a square', 'image': 'assets/square.png'},
    {'sides': 'I have 3 sides', 'corners': 'I have 3 corners', 'name': 'I am a triangle', 'image': 'assets/triangle.png'},
    {'sides': 'I have 5 sides', 'corners': 'I have 5 corners', 'name': 'I am a pentagon', 'image': 'assets/pentagon.png'},
    {'sides': 'I have 6 sides', 'corners': 'I have 6 corners', 'name': 'I am a hexagon', 'image': 'assets/hexagon.png'},
    {'sides': 'I have 8 sides', 'corners': 'I have 8 corners', 'name': 'I am an octagon', 'image': 'assets/octagon.png'},
    {'sides': 'I have infinite sides', 'corners': 'I have no corners', 'name': 'I am a circle', 'image': 'assets/circle.png'},
  ];

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage('en-US');
    _flutterTts.setPitch(1);
    _flutterTts.setSpeechRate(0.5);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _generateQuestions();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
  }

  void _generateQuestions() {
    _questions.clear();
    final used = <int>{};
    while (_questions.length < 5) {
      int correct = _random.nextInt(shapes.length);
      if (used.add(correct)) {
        final q = _random.nextBool()
            ? shapes[correct]['sides']!.replaceFirst('I have', 'Which shape has') + '?'
            : shapes[correct]['corners']!.replaceFirst('I have', 'Which shape has') + '?';
        final options = [shapes[correct]];
        while (options.length < 4) {
          int i = _random.nextInt(shapes.length);
          if (options.every((o) => o['image'] != shapes[i]['image'])) {
            options.add(shapes[i]);
          }
        }
        options.shuffle();
        _questions.add({'question': q, 'correct': shapes[correct]['image'], 'options': options});
      }
    }
  }

  void _speak() async {
    await _flutterTts.stop();
    await _flutterTts.speak(_questions[_index]['question']);
  }

  void _check(String selected) {
    if (selected == _questions[_index]['correct']) _score++;
    if (_index < _questions.length - 1) {
      setState(() => _index++);
      _speak();
    } else {
      _showResult();
    }
  }

  void _showResult() {
    _flutterTts.stop();
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: const Color(0xFFF7F9FC),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 80),
                  const SizedBox(height: 16),
                  const Text("Great Job!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                  const SizedBox(height: 12),
                  Text("Your score: $_score/${_questions.length}", style: const TextStyle(fontSize: 22, color: Color(0xFF34495E))),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5DB2FF),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 3,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _index = 0;
                        _score = 0;
                        _generateQuestions();
                      });
                      _speak();
                    },
                    child: const Text("Retry", style: TextStyle(fontSize: 22, color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5DB2FF),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 3,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => Readingmaterialspage()),
                        (route) => false,
                      );
                    },
                    child: const Text("Back to Learning", style: TextStyle(fontSize: 22, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSkipConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Skip Assessment", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 28, color: Colors.black87), textAlign: TextAlign.center),
        content: const Text("Are you sure you want to skip the assessment?", style: TextStyle(fontFamily: 'Poppins', fontSize: 22, color: Colors.black87), textAlign: TextAlign.center),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(fontFamily: 'Poppins', fontSize: 22, color: Colors.black87, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 3,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => Readingmaterialspage()),
                  (route) => false,
                );
              },
              child: const Text("Yes, Skip", style: TextStyle(fontFamily: 'Poppins', fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_index];
    return WillPopScope(
      onWillPop: () async {
        _showSkipConfirmation();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEFE9D5),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 24,
                right: 24,
                child: ElevatedButton(
                  onPressed: _showSkipConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4E69),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: const Text("Close", style: TextStyle(fontSize: 22, fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFCCE5FF), borderRadius: BorderRadius.circular(12)),
                        child: Text('Question ${_index + 1} of ${_questions.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Card(
                                margin: const EdgeInsets.all(16),
                                color: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.volume_up, size: 32),
                                            onPressed: _speak,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              question['question'],
                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      GridView.builder(
                                        shrinkWrap: true,
                                        itemCount: 4,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 1.2, // Adjusted for smaller shape size
                                        ),
                                        itemBuilder: (_, i) {
                                          final opt = question['options'][i];
                                          return GestureDetector(
                                            onTap: () => _check(opt['image']),
                                            child: Card(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              child: Padding(
                                                padding: const EdgeInsets.all(6), // Reduced padding
                                                child: Image.asset(
                                                  opt['image'],
                                                  fit: BoxFit.contain,
                                                  height: 80,
                                                  width: 80,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
