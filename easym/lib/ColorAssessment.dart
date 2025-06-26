import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'ReadingMaterialsPage.dart';

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: ColorAssessment()),
  );
}

class ColorAssessment extends StatefulWidget {
  @override
  _ColorAssessmentState createState() => _ColorAssessmentState();
}

class _ColorAssessmentState extends State<ColorAssessment> {
  int currentIndex = 0;
  int score = 0;
  bool isSpeaking = false;
  bool questionRead = false;

  final FlutterTts flutterTts = FlutterTts();

  final List<Question> questions = [
    Question(
      imagePath: 'assets/shoes.png',
      questionText: 'What is the color of these shoes?',
      options: {
        'Black': Colors.black,
        'Brown': Colors.brown,
        'Red': Colors.redAccent,
        'Orange': Colors.orange,
        'Green': Colors.green,
      },
      correctAnswer: 'Black',
    ),
    Question(
      imagePath: 'assets/orange.png',
      questionText: 'What is the color of this fruit?',
      options: {
        'Black': Colors.black,
        'Orange': Colors.orange,
        'Purple': Colors.purple,
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
        'Red': Colors.red,
        'Black': Colors.black,
        'Blue Grey': Colors.blueGrey,
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
        'Deep Orange': Colors.deepOrange,
        'Green': Colors.green,
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
        'Pink': Colors.pinkAccent,
        'Blue': Colors.blue,
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
        'Purple': Colors.purple,
        'Yellow': Colors.yellow,
      },
      correctAnswer: 'Pink',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _configureTts();
    readQuestion();
  }

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.4); // Higher pitch for more feminine voice
    // Attempt to set a more feminine voice
    try {
      await flutterTts.setVoice({
        "name": "en-us-x-tpf#female_1-local",
        "locale": "en-US",
      });
    } catch (e) {
      // Fallback to another female voice if the primary one is unavailable
      await flutterTts.setVoice({
        "name": "en-us-x-sfg#female_2-local",
        "locale": "en-US",
      });
    }
    await flutterTts.awaitSpeakCompletion(true);
  }

  void readQuestion() async {
    final question = questions[currentIndex];
    setState(() {
      isSpeaking = true;
      questionRead = false;
    });
    await flutterTts.speak(question.questionText);
    setState(() {
      isSpeaking = false;
      questionRead = true;
    });
  }

  void _speakOption(String option) async {
    await flutterTts.stop();
    await flutterTts.speak(option);
  }

  void playSoundAndCheck(String selectedColor) async {
    if (!isSpeaking && questionRead) {
      setState(() {
        isSpeaking = true;
        questionRead = false;
      });

      final currentQuestion = questions[currentIndex];
      final bool isCorrect = selectedColor == currentQuestion.correctAnswer;

      // Speak the selected color first
      await flutterTts.speak(selectedColor);
      await Future.delayed(const Duration(milliseconds: 800));

      // Speak feedback after saying the selected color
      if (isCorrect) {
        await flutterTts.speak("Correct!");
        score++;
      } else {
        await flutterTts.speak(
          "Wrong! The correct color is ${currentQuestion.correctAnswer}",
        );
      }

      setState(() {
        isSpeaking = false;
      });

      Future.delayed(const Duration(milliseconds: 2000), () {
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

  void showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFFF7F9FC),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 80, color: Colors.amber),
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5DB2FF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
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
                    Navigator.pop(context);
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
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                          icon: const Icon(
                            Icons.volume_up,
                            color: Colors.black87,
                            size: 40,
                          ),
                          onPressed: readQuestion,
                        ),
                        const SizedBox(height: 30),
                        Image.asset(question.imagePath, height: 200),
                        const SizedBox(height: 30),
                        ...question.options.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: ElevatedButton(
                              onPressed: () => playSoundAndCheck(entry.key),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: entry.value,
                                minimumSize: const Size(double.infinity, 70),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.volume_up,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: () => _speakOption(entry.key),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
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
              ),
            ],
          ),
        ),
      ),
    );
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
