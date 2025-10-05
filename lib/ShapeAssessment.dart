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

class _ShapeAssessmentState extends State<ShapeAssessment>
    with SingleTickerProviderStateMixin {
  final _flutterTts = FlutterTts();
  final _random = Random();
  int _index = 0, _score = 0;
  final List<Map<String, dynamic>> _questions = [];
  late ConfettiController _confettiController;

  AnimationController? _shakeController;
  Animation<double>? _shakeAnimation;

  String _selectedImage = '';
  Map<String, Color> _buttonColors = {};

  List<Map<String, dynamic>> _userAnswers = [];

  final List<Map<String, String>> shapes = const [
    {'sides': 'I have 4 sides', 'corners': 'I have 4 corners', 'name': 'Square', 'image': 'assets/square.png'},
    {'sides': 'I have 3 sides', 'corners': 'I have 3 corners', 'name': 'Triangle', 'image': 'assets/triangle.png'},
    {'sides': 'I have 5 sides', 'corners': 'I have 5 corners', 'name': 'Pentagon', 'image': 'assets/pentagon.png'},
    {'sides': 'I have 6 sides', 'corners': 'I have 6 corners', 'name': 'Hexagon', 'image': 'assets/hexagon.png'},
    {'sides': 'I have 8 sides', 'corners': 'I have 8 corners', 'name': 'Octagon', 'image': 'assets/octagon.png'},
    {'sides': 'I have infinite sides', 'corners': 'I have no corners', 'name': 'Circle', 'image': 'assets/circle.png'},
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

    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController!)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController!.reset();
        }
      });
  }

  void _generateQuestions() {
    _questions.clear();
    _userAnswers.clear();
    final used = <int>{};
    while (_questions.length < 5) {
      int correct = _random.nextInt(shapes.length);
      if (used.add(correct)) {
        final q = _random.nextBool()
            ? '${shapes[correct]['sides']!.replaceFirst('I have', 'Which shape has')}?'
            : '${shapes[correct]['corners']!.replaceFirst('I have', 'Which shape has')}?';
        final options = [shapes[correct]];
        while (options.length < 4) {
          int i = _random.nextInt(shapes.length);
          if (options.every((o) => o['image'] != shapes[i]['image'])) {
            options.add(shapes[i]);
          }
        }
        options.shuffle();
        _questions.add({
          'question': q,
          'correct': shapes[correct]['image'],
          'options': options
        });
      }
    }
    _buttonColors = {for (var o in _questions[_index]['options']) o['image']: Colors.white};
  }

  void _speak([String? text]) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text ?? _questions[_index]['question']);
  }

  void _check(String selected) async {
    if (_selectedImage.isNotEmpty) return; 
    setState(() => _selectedImage = selected);

    bool correct = selected == _questions[_index]['correct'];
    _buttonColors[selected] = correct ? Colors.green : Colors.red;
    _speak(correct ? "Correct!" : "Wrong!");
    if (!correct) _shakeController!.forward();

    if (correct) _score++;

    // save user's answer for summary
    _userAnswers.add({
      'question': _questions[_index]['question'],
      'userAnswer': shapes.firstWhere((s) => s['image'] == selected)['name'],
      'correctAnswer': shapes.firstWhere((s) => s['image'] == _questions[_index]['correct'])['name']
    });

    await Future.delayed(const Duration(seconds: 1));
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _selectedImage = '';
        _buttonColors = {for (var o in _questions[_index]['options']) o['image']: Colors.white};
      });
      _speak();
    } else {
      _showCompletionDialog();
    }
  }

  void _resetAssessment() {
    setState(() {
      _index = 0;
      _score = 0;
      _generateQuestions();
      _selectedImage = '';
    });
    _speak();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFF6DC),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 25,
              colors: const [
                Color(0xFF5DB2FF),
                Color(0xFF4A4E69),
                Color(0xFF22223B)
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 60, color: Color(0xFF5DB2FF)),
                      const SizedBox(height: 12),
                      const Text(
                        "Great Job!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22223B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Your score: $_score / ${_questions.length}",
                        style: const TextStyle(fontSize: 22, color: Color(0xFF4A4E69)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Answer Summary",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22223B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _userAnswers.length,
                        itemBuilder: (_, index) {
                          final item = _userAnswers[index];
                          final isCorrect = item['userAnswer'] == item['correctAnswer'];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: isCorrect
                                ? const Color(0xFFD6FFE0)
                                : const Color(0xFFFFD6D6),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isCorrect ? Colors.green : Colors.red,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                item['question'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your Answer: ${item['userAnswer']}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: isCorrect ? Colors.green[800] : Colors.red[800]),
                                  ),
                                  if (!isCorrect)
                                    Text(
                                      "Correct Answer: ${item['correctAnswer']}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5DB2FF),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => Readingmaterialspage()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text(
                            "Back to Learning",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
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
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _confettiController.dispose();
    _shakeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_index];
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final crossAxisCount = isPortrait ? 2 : 4;
    final childAspect = isPortrait ? 1.0 : 0.8;

    return WillPopScope(
      onWillPop: () async {
        _showSkipConfirmation();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF6DC),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _showSkipConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22223B),
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 3,
                      ),
                      child: const Text("Close", style: TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _resetAssessment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A4E69),
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 3,
                      ),
                      child: const Text("Reset", style: TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.volume_up),
                                iconSize: 36,
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
                          const SizedBox(height: 16),
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _shakeController!,
                              builder: (context, child) {
                                double offset = _shakeAnimation!.value;
                                return Transform.translate(
                                  offset: Offset(_selectedImage.isNotEmpty &&
                                          _buttonColors[_selectedImage] == Colors.red
                                      ? offset
                                      : 0,
                                      0),
                                  child: child,
                                );
                              },
                              child: GridView.builder(
                                padding: EdgeInsets.zero,
                                physics: const BouncingScrollPhysics(),
                                itemCount: 4,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: childAspect,
                                ),
                                itemBuilder: (_, i) {
                                  final opt = question['options'][i];
                                  return GestureDetector(
                                    onTap: () => _check(opt['image']),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      decoration: BoxDecoration(
                                        color: _buttonColors[opt['image']],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: Image.asset(
                                        opt['image'],
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showSkipConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFF6DC),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 60, color: Color(0xFFFF6B6B)),
                const SizedBox(height: 20),
                const Text("Skip Assessment?",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF22223B)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                const Text(
                  "Are you sure you want to skip this assessment? Your progress will be saved.",
                  style: TextStyle(fontSize: 18, color: Color(0xFF4A4E69)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A4E69),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Cancel",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Skip",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
