import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'LearnMyFamily.dart';

class MyFamilyAssessment extends StatefulWidget {
  @override
  _MyFamilyAssessmentState createState() => _MyFamilyAssessmentState();
}

class _MyFamilyAssessmentState extends State<MyFamilyAssessment> {
  final FlutterTts flutterTts = FlutterTts();
  late ConfettiController _confettiController;
  int currentQuestion = 0;
  int score = 0;

  final List<Map<String, Object>> questions = [
    {
      'question': 'Who do I live with?',
      'image': 'assets/happy.jpg',
      'options': [
        'My mother and father',
        'My friend and teacher',
        'My neighbor',
      ],
      'answer': 'My mother and father',
    },
    {
      'question': 'When do we eat dinner together?',
      'image': 'assets/eating_dinner.jpg',
      'options': ['Every night', 'In the morning', 'At school'],
      'answer': 'Every night',
    },
    {
      'question': 'Why do I love my family?',
      'image': 'assets/love_family.jpg',
      'options': [
        'They take care of me',
        'They give me homework',
        'They ride bikes',
      ],
      'answer': 'They take care of me',
    },
    {
      'question': 'What do my sister and I do after school?',
      'image': 'assets/playing.jpg',
      'options': ['Play with toys', 'Do the dishes', 'Go to the store'],
      'answer': 'Play with toys',
    },
    {
      'question': 'What does my father do when my mother is working?',
      'image': 'assets/cooking.jpg',
      'options': ['He cooks dinner', 'He watches TV', 'He reads a book'],
      'answer': 'He cooks dinner',
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _configureTts();
    _speakQuestion();
  }

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.4); // Higher pitch for feminine voice
    try {
      await flutterTts.setVoice({
        "name": "en-us-x-tpf#female_1-local",
        "locale": "en-US",
      });
    } catch (e) {
      await flutterTts.setVoice({
        "name": "en-us-x-sfg#female_2-local",
        "locale": "en-US",
      });
    }
    await flutterTts.awaitSpeakCompletion(true);
  }

  void _speakQuestion() async {
    await flutterTts.stop();
    await flutterTts.speak(questions[currentQuestion]['question'] as String);
  }

  void _speakOption(String option) async {
    await flutterTts.stop();
    await flutterTts.speak(option);
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
    _confettiController.play();
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
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => LearnMyFamily(),
                              ),
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
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => LearnMyFamily()),
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
  void dispose() {
    _confettiController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "My Family - Assessment",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4E69),
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black26,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Answer each question by selecting the correct option.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        color: Color(0xFF6C757D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              'Question ${currentQuestion + 1} of ${questions.length}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: Image.asset(
                              questions[currentQuestion]['image'] as String,
                              height: 300,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            questions[currentQuestion]['question'] as String,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          IconButton(
                            icon: const Icon(
                              Icons.volume_up,
                              color: Colors.black87,
                              size: 40,
                            ),
                            onPressed: _speakQuestion,
                          ),
                          const SizedBox(height: 30),
                          ...((questions[currentQuestion]['options']
                                  as List<String>)
                              .map((option) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => answerQuestion(option),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF648BA2),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                        horizontal: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      minimumSize: const Size(
                                        double.infinity,
                                        70,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            option,
                                            style: const TextStyle(
                                              fontSize: 22,
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
                                          onPressed: () => _speakOption(option),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                              .toList()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
