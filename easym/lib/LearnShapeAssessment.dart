import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'ReadingMaterialsPage.dart';

class LearnShapeAssessment extends StatefulWidget {
  @override
  _LearnShapeAssessmentState createState() => _LearnShapeAssessmentState();
}

class _LearnShapeAssessmentState extends State<LearnShapeAssessment> {
  final FlutterTts flutterTts = FlutterTts();
  late ConfettiController _confettiController;
  int currentQuestion = 0;
  int score = 0;

  final List<Map<String, Object>> questions = [
    {
      'question': 'Match the doughnut to the shapes',
      'objectName': 'doughnut',
      'image': 'assets/doughnut1.png',
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
      'question': 'Match the box to the shapes',
      'objectName': 'box',
      'image': 'assets/box1.png',
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
      'question': 'Match the pizza to the shapes',
      'objectName': 'pizza',
      'image': 'assets/pizza1.png',
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
      'question': 'Match the envelope to the shapes',
      'objectName': 'envelope',
      'image': 'assets/envelope1.png',
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
      'question': 'Match the balloons to the shapes',
      'objectName': 'balloons',
      'image': 'assets/balloons.png',
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
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _speakQuestion();
  }

  void _speakQuestion() async {
    await flutterTts.stop();
    final question = questions[currentQuestion]['question'] as String;
    await flutterTts.speak(question);
  }

  void answerQuestion(String selected) async {
    await flutterTts.stop();

    bool isCorrect = selected == questions[currentQuestion]['answer'];
    if (isCorrect) {
      score++;
      await flutterTts.speak("Correct");
    } else {
      await flutterTts.speak("Wrong");
    }

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      if (currentQuestion < questions.length - 1) {
        currentQuestion++;
        _speakQuestion();
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    _confettiController.play(); // Start confetti animation

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            backgroundColor: const Color(0xFFF7F9FC),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.yellow,
                    Colors.purple,
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32.0,
                      horizontal: 24.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Great Job!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Your score: $score/${questions.length}",
                          style: const TextStyle(
                            fontSize: 22,
                            color: Color(0xFF34495E),
                          ),
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5DB2FF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => Readingmaterialspage(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text(
                            "Back to Learning",
                            style: TextStyle(fontSize: 22, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
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
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Skip Assessment",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              "Are you sure you want to skip the assessment?",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => Readingmaterialspage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text(
                    "Yes, Skip",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionData = questions[currentQuestion];
    final options = questionData['options'] as List<Map<String, String>>;
    final screenSize = MediaQuery.of(context).size;
    final isSmall = screenSize.width < 600;

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
                bottom: 20,
                right: 0,
                child: SizedBox(
                  width: isSmall ? 200 : 350,
                  height: isSmall ? 200 : 350,
                ),
              ),
              Positioned(
                top: 24,
                right: 24,
                child: ElevatedButton(
                  onPressed: _showSkipConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4E69),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCE5FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Question ${currentQuestion + 1} of ${questions.length}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              questionData['image'] as String,
                              height: 400,
                              width: 400,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              questionData['question'] as String,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 20,
                      children:
                          options.map((option) {
                            return GestureDetector(
                              onTap: () => answerQuestion(option['shape']!),
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Image.asset(
                                  option['image']!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
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
