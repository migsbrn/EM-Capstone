import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../ReadingMaterialsPage.dart';

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: ColorAssessment()),
  );
}

class ColorAssessment extends StatefulWidget {
  const ColorAssessment({super.key});

  @override
  _ColorAssessmentState createState() => _ColorAssessmentState();
}

class _ColorAssessmentState extends State<ColorAssessment>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  int score = 0;
  bool isSpeaking = false;
  bool questionRead = false;
  String? selectedOption;
  bool showAnswerFeedback = false;

  final FlutterTts flutterTts = FlutterTts();

  final List<Map<String, String>> reflection = [];

  late final AnimationController _shakeController;

  final List<Question> questions = [
    Question(
      imagePath: 'assets/shoes.png',
      questionText: 'What is the color of these shoes?',
      options: {
        'Black': Colors.black,
        'Brown': Colors.brown,
        'Red': Colors.redAccent,
      },
      correctAnswer: 'Black',
    ),
    Question(
      imagePath: 'assets/orange.png',
      questionText: 'What is the color of this fruit?',
      options: {
        'Orange': Colors.orange,
        'Green': Colors.green,
        'Brown': Colors.brown,
      },
      correctAnswer: 'Orange',
    ),
    Question(
      imagePath: 'assets/grape.png',
      questionText: 'What is the color of grapes?',
      options: {
        'Purple': Colors.purple,
        'Green': Colors.green,
        'Black': Colors.black,
      },
      correctAnswer: 'Purple',
    ),
    Question(
      imagePath: 'assets/chair.png',
      questionText: 'What is the color of this chair?',
      options: {
        'Brown': Colors.brown,
        'Grey': Colors.grey,
        'Black': Colors.black,
      },
      correctAnswer: 'Brown',
    ),
    Question(
      imagePath: 'assets/board.png',
      questionText: 'What is the color of this board?',
      options: {
        'Green': Colors.green,
        'Orange': Colors.orange,
        'Black': Colors.black,
      },
      correctAnswer: 'Green',
    ),
    Question(
      imagePath: 'assets/flower.png',
      questionText: 'What is the color of this carnation flower?',
      options: {
        'Pink': Colors.pinkAccent,
        'Red': Colors.red,
        'Orange': Colors.orange,
      },
      correctAnswer: 'Pink',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _configureTts();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    readQuestion();
  }

  Future<void> _configureTts() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setPitch(1.4);
      await flutterTts.awaitSpeakCompletion(true);
    } catch (_) {}
  }

  Future<void> readQuestion() async {
    final question = questions[currentIndex];
    setState(() {
      isSpeaking = true;
      questionRead = false;
    });
    await flutterTts.stop();
    flutterTts.speak(question.questionText);
    setState(() {
      isSpeaking = false;
      questionRead = true;
    });
  }

  Future<void> _speakOption(String option) async {
    await flutterTts.stop();
    flutterTts.speak(option);
  }

  Future<void> playSoundAndCheck(String selectedColor) async {
    if (!isSpeaking && questionRead) {
      setState(() {
        isSpeaking = true;
        questionRead = false;
        selectedOption = selectedColor;
        showAnswerFeedback = true;
      });

      final currentQuestion = questions[currentIndex];
      final bool isCorrect = selectedColor == currentQuestion.correctAnswer;

      reflection.add({
        "question": currentQuestion.questionText,
        "userAnswer": selectedColor,
        "correctAnswer": currentQuestion.correctAnswer,
      });

      flutterTts.stop();
      flutterTts.speak(selectedColor);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (isCorrect) {
          flutterTts.speak("Correct!");
          score++;
        } else {
          flutterTts.speak(
              "Wrong! The correct color is ${currentQuestion.correctAnswer}");
          _shakeController.forward(from: 0.0);
        }
      });

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          isSpeaking = false;
          selectedOption = null;
          showAnswerFeedback = false;
        });
        goToNext();
      });
    }
  }

  void goToNext() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        questionRead = false;
      });
      readQuestion();
    } else {
      showResultDialog();
    }
  }

  void resetAssessment() {
    setState(() {
      currentIndex = 0;
      score = 0;
      selectedOption = null;
      questionRead = false;
      reflection.clear();
    });
    readQuestion();
  }

  void showResultDialog() {
    flutterTts.stop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFF6DC),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                    "Your score: $score / ${questions.length}",
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
                    itemCount: reflection.length,
                    itemBuilder: (_, index) {
                      final item = reflection[index];
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
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            item['question']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Answer: ${item['userAnswer']}",
                                style: TextStyle(
                                    color: isCorrect ? Colors.green[800] : Colors.red[800]),
                              ),
                              if (!isCorrect)
                                Text(
                                  "Correct Answer: ${item['correctAnswer']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, color: Colors.green),
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
                          MaterialPageRoute(
                              builder: (_) => const Readingmaterialspage()),
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
      ),
    );
  }

  void _showSkipConfirmation() {
    flutterTts.stop();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFF6DC),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
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

  Widget _buildOption(String optionLabel, Color optionColor) {
    final question = questions[currentIndex];
    Color bgColor = optionColor;
    if (showAnswerFeedback && selectedOption != null) {
      if (optionLabel == selectedOption) {
        bgColor = optionLabel == question.correctAnswer ? Colors.green : Colors.red;
      } else if (optionLabel == question.correctAnswer) {
        bgColor = Colors.green;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          double offset = 0;
          if ((_shakeController.isAnimating || !_shakeController.isDismissed) &&
              selectedOption == optionLabel &&
              optionLabel != question.correctAnswer) {
            offset = sin(_shakeController.value * pi * 10) * 8;
          }
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => playSoundAndCheck(optionLabel),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        optionLabel,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up,
                          color: Colors.white, size: 28),
                      onPressed: () => _speakOption(optionLabel),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];
    return WillPopScope(
      onWillPop: () async {
        _showSkipConfirmation();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF6EC),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 24,
                right: 24,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: _showSkipConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22223B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: resetAssessment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A4E69),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCE5FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Question ${currentIndex + 1} of ${questions.length}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          question.questionText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3A3B3C),
                          ),
                        ),
                        const SizedBox(height: 10),
                        IconButton(
                          icon: const Icon(Icons.volume_up,
                              color: Colors.black87, size: 40),
                          onPressed: readQuestion,
                        ),
                        const SizedBox(height: 30),
                        Image.asset(
                          question.imagePath,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ...question.options.entries.map(
                          (entry) => _buildOption(entry.key, entry.value),
                        ),
                      ],
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

  @override
  void dispose() {
    flutterTts.stop();
    _shakeController.dispose();
    super.dispose();
  }
}

class Question {
  final String imagePath;
  final String questionText;
  final Map<String, Color> options;
  final String correctAnswer;

  Question({
    required this.imagePath,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });
}
