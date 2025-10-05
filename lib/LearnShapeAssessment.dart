import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import '../ReadingMaterialsPage.dart';

class LearnShapeAssessment extends StatefulWidget {
  const LearnShapeAssessment({super.key});

  @override
  _LearnShapeAssessmentState createState() => _LearnShapeAssessmentState();
}

class _LearnShapeAssessmentState extends State<LearnShapeAssessment>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late ConfettiController _confettiController;

  int currentQuestion = 0;
  int score = 0;
  int attempts = 0;
  bool isCorrectShapeDropped = false;
  bool showIncorrectIcon = false;
  bool isQuestionFinished = false;

  final List<Map<String, Object>> questions = [
    {
      'question': 'Drop the correct shape to the broken line',
      'matchWith': 'Circle',
      'options': [
        {'shape': 'Circle', 'image': 'assets/circle.png'},
        {'shape': 'Square', 'image': 'assets/square.png'},
        {'shape': 'Triangle', 'image': 'assets/triangle.png'},
        {'shape': 'Rectangle', 'image': 'assets/rectangle.png'},
      ],
      'answer': 'Circle',
    },
    {
      'question': 'Drop the correct shape to the broken line',
      'matchWith': 'Square',
      'options': [
        {'shape': 'Rectangle', 'image': 'assets/rectangle.png'},
        {'shape': 'Square', 'image': 'assets/square.png'},
        {'shape': 'Star', 'image': 'assets/sta.png'},
        {'shape': 'Circle', 'image': 'assets/circle.png'},
      ],
      'answer': 'Square',
    },
    {
      'question': 'Drop the correct shape to the broken line',
      'matchWith': 'Triangle',
      'options': [
        {'shape': 'Star', 'image': 'assets/sta.png'},
        {'shape': 'Triangle', 'image': 'assets/triangle.png'},
        {'shape': 'Rectangle', 'image': 'assets/rectangle.png'},
        {'shape': 'Square', 'image': 'assets/square.png'},
      ],
      'answer': 'Triangle',
    },
    {
      'question': 'Drop the correct shape to the broken line',
      'matchWith': 'Rectangle',
      'options': [
        {'shape': 'Triangle', 'image': 'assets/triangle.png'},
        {'shape': 'Circle', 'image': 'assets/circle.png'},
        {'shape': 'Rectangle', 'image': 'assets/rectangle.png'},
        {'shape': 'Star', 'image': 'assets/sta.png'},
      ],
      'answer': 'Rectangle',
    },
    {
      'question': 'Drop the correct shape to the broken line',
      'matchWith': 'Star',
      'options': [
        {'shape': 'Square', 'image': 'assets/square.png'},
        {'shape': 'Circle', 'image': 'assets/circle.png'},
        {'shape': 'Triangle', 'image': 'assets/triangle.png'},
        {'shape': 'Star', 'image': 'assets/sta.png'},
      ],
      'answer': 'Star',
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _initializeTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakQuestion();
    });
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speakQuestion() async {
    await flutterTts.stop();
    if (currentQuestion < questions.length) {
      final question = questions[currentQuestion]['question'] as String;
      await flutterTts.speak("Question ${currentQuestion + 1}: $question");
    }
  }

  Future<void> _repeatQuestion() async {
    await _speakQuestion();
  }

  void _handleDrop(String? droppedShape) async {
    if (isQuestionFinished) return;

    await flutterTts.stop();
    setState(() {
      attempts++;
      isCorrectShapeDropped =
          droppedShape == questions[currentQuestion]['answer'];
      showIncorrectIcon = !isCorrectShapeDropped;
    });

    if (isCorrectShapeDropped) {
      score++;
      await flutterTts.speak("Correct");
      setState(() => isQuestionFinished = true);
      Future.delayed(const Duration(seconds: 1), _proceedToNextQuestion);
    } else {
      await flutterTts.speak("Incorrect. Try again.");
      if (attempts >= 3) {
        setState(() => isQuestionFinished = true);
        Future.delayed(const Duration(seconds: 1), _proceedToNextQuestion);
      }
    }
  }

  void _proceedToNextQuestion() {
    setState(() {
      if (currentQuestion < questions.length - 1) {
        currentQuestion++;
        attempts = 0;
        isCorrectShapeDropped = false;
        showIncorrectIcon = false;
        isQuestionFinished = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _speakQuestion();
        });
      } else {
        _showResultDialog();
      }
    });
  }

  void _resetAssessment() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      attempts = 0;
      isCorrectShapeDropped = false;
      showIncorrectIcon = false;
      isQuestionFinished = false;
    });
    _speakQuestion();
  }

  void _showResultDialog() {
    _confettiController.play();
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
              colors: const [
                Color(0xFF5DB2FF),
                Color(0xFF4A4E69),
                Color(0xFF22223B)
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      size: 80, color: Color(0xFF5DB2FF)),
                  const SizedBox(height: 16),
                  const Text(
                    "Great Job!",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22223B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your score: $score / ${questions.length}",
                    style: const TextStyle(
                        fontSize: 22, color: Color(0xFF4A4E69)),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFF4A4E69)),
                  const SizedBox(height: 12),
                  Column(
                    children: List.generate(questions.length, (index) {
                      final q = questions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Q${index + 1}: ${q['question']}",
                                style: const TextStyle(
                                    fontSize: 16, color: Color(0xFF22223B))),
                            Text("${q['answer']}",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5DB2FF))),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const Readingmaterialspage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5DB2FF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Back to Learning",
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _resetAssessment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22223B),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Reset Assessment",
                        style: TextStyle(fontSize: 20, color: Colors.white)),
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
                const Icon(Icons.warning_amber_rounded,
                    size: 60, color: Color(0xFFFF6B6B)),
                const SizedBox(height: 20),
                const Text(
                  "Skip Assessment?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF22223B),
                  ),
                  textAlign: TextAlign.center,
                ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const Readingmaterialspage()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final questionData = questions[currentQuestion];
    final options = questionData['options'] as List<Map<String, String>>;

    return WillPopScope(
      onWillPop: () async {
        _showSkipConfirmation();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEFE9D5),
        body: SafeArea(
          child: Column(
            children: [
              // Top Buttons Row (Close & Reset)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _showSkipConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22223B),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _resetAssessment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5DB2FF),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Reset",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: const Color(0xFFCCE5FF),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            'Question ${currentQuestion + 1} of ${questions.length}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(questionData['question'] as String,
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.w600)),
                            IconButton(
                                icon: const Icon(Icons.volume_up),
                                iconSize: 30,
                                onPressed: _repeatQuestion),
                            const SizedBox(height: 20),
                            DragTarget<String>(
                              onAcceptWithDetails: (details) =>
                                  _handleDrop(details.data),
                              builder: (context, candidateData, rejectedData) {
                                return SizedBox(
                                  width: 250,
                                  height: 250,
                                  child: isCorrectShapeDropped
                                      ? Image.asset(
                                          options.firstWhere((opt) =>
                                                  opt['shape'] ==
                                                  questionData['answer'])['image']!,
                                          fit: BoxFit.contain,
                                        )
                                      : CustomPaint(
                                          size: const Size(250, 250),
                                          painter: DashedShapePainter(
                                              questionData['matchWith']
                                                  as String),
                                        ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Text("Attempts: $attempts/3",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: options.map((option) {
                          return Draggable<String>(
                            data: option['shape'],
                            feedback: Material(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black26),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Image.asset(option['image']!,
                                    fit: BoxFit.contain),
                              ),
                            ),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Image.asset(option['image']!,
                                  fit: BoxFit.contain),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    flutterTts.stop();
    super.dispose();
  }
}

// Dashed Shape Painter
class DashedShapePainter extends CustomPainter {
  final String shape;
  DashedShapePainter(this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dashWidth = 6.0;
    final dashSpace = 4.0;
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    const double shapeSize = 150.0;

    if (shape == 'Circle') {
      final rect = Rect.fromCircle(center: center, radius: shapeSize / 2);
      _drawDashedCircle(canvas, rect, paint, dashWidth, dashSpace);
    } else if (shape == 'Square') {
      path.addRect(Rect.fromCenter(
          center: center, width: shapeSize, height: shapeSize));
      _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
    } else if (shape == 'Triangle') {
      path.moveTo(center.dx, center.dy - shapeSize / 2);
      path.lineTo(center.dx - shapeSize / 2, center.dy + shapeSize / 2);
      path.lineTo(center.dx + shapeSize / 2, center.dy + shapeSize / 2);
      path.close();
      _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
    } else if (shape == 'Rectangle') {
      path.addRect(Rect.fromCenter(
          center: center, width: shapeSize * 1.5, height: shapeSize));
      _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
    } else if (shape == 'Star') {
      for (int i = 0; i < 5; i++) {
        final angle = (i * 4 * pi / 5) - pi / 2;
        final outerX = center.dx + cos(angle) * (shapeSize / 2);
        final outerY = center.dy + sin(angle) * (shapeSize / 2);
        final innerAngle = angle + pi / 5;
        final innerX = center.dx + cos(innerAngle) * (shapeSize / 4);
        final innerY = center.dy + sin(innerAngle) * (shapeSize / 4);
        if (i == 0) {
          path.moveTo(outerX, outerY);
        } else {
          path.lineTo(outerX, outerY);
        }
        path.lineTo(innerX, innerY);
      }
      path.close();
      _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
    }
  }

  void _drawDashedCircle(
      Canvas canvas, Rect rect, Paint paint, double dashWidth, double dashSpace) {
    double circumference = 2 * pi * (rect.width / 2);
    int dashCount = (circumference / (dashWidth + dashSpace)).floor();
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashWidth + dashSpace)) * 2 * pi / circumference;
      final sweepAngle = dashWidth * 2 * pi / circumference;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, double dashWidth,
      double dashSpace) {
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedShapePainter oldDelegate) =>
      oldDelegate.shape != shape;
}
