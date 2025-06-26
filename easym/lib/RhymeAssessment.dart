import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'ReadingMaterialsPage.dart';

class RhymeAssessment extends StatefulWidget {
  @override
  _RhymeAssessmentState createState() => _RhymeAssessmentState();
}

class _RhymeAssessmentState extends State<RhymeAssessment> {
  final FlutterTts flutterTts = FlutterTts();
  int currentQuestion = 0;
  int score = 0;

  final List<Map<String, Object>> questions = [
    {
      'question': 'Which word rhymes with "Cat"?',
      'options': ['Hat', 'Book', 'Car'],
      'answer': 'Hat',
    },
    {
      'question': 'Where does the hen live?',
      'options': ['In the pen', 'On the mat', 'Under the tree'],
      'answer': 'In the pen',
    },
    {
      'question': 'What does the hand feel?',
      'options': ['Soft sand', 'A cold pen', 'A sleepy cat'],
      'answer': 'Soft sand',
    },
  ];

  @override
  void initState() {
    super.initState();
    _configureTts();
    _speakQuestion();
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

  void _speakQuestion() async {
    await flutterTts.stop();
    final question = questions[currentQuestion]['question'] as String;
    await flutterTts.speak(question);
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
            child: SizedBox(
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
    final options = questionData['options'] as List<String>;
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
                            Flexible(
                              child: Text(
                                questionData['question'] as String,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 10),
                            IconButton(
                              icon: const Icon(
                                Icons.volume_up,
                                color: Colors.black87,
                                size: 40, // Increased size
                              ),
                              onPressed: _speakQuestion,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          onPressed: () => answerQuestion(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF648BA2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(
                              double.infinity,
                              70,
                            ), // Updated from ColorAssessment
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 20,
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
                      ),
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
    flutterTts.stop();
    super.dispose();
  }
}
