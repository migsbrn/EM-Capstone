import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'ReadingMaterialsPage.dart';

class PictureStoryAssessment extends StatefulWidget {
  const PictureStoryAssessment({Key? key}) : super(key: key);

  @override
  State<PictureStoryAssessment> createState() => _PictureStoryAssessmentState();
}

class _PictureStoryAssessmentState extends State<PictureStoryAssessment> {
  final FlutterTts flutterTts = FlutterTts();
  int currentQuestion = 0;
  int score = 0;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Who is lost in the park?",
      "image": 'assets/puppy.png',
      "options": ["puppy", "dog", "cat", "bird"],
      "answer": "puppy",
    },
    {
      "question": "Who finds the lost puppy?",
      "image": 'assets/grl.jpg',
      "options": ["boy", "girl", "dog", "cat"],
      "answer": "girl",
    },
    {
      "question": "Who reunites with the puppy?",
      "image": 'assets/girl.png',
      "options": ["puppy", "owner", "boy", "cat"],
      "answer": "owner",
    },
  ];

  List<String> shuffledOptions = [];

  @override
  void initState() {
    super.initState();
    _configureTts();
    shuffleOptions();
    speakQuestion();
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

  Future<void> speakQuestion() async {
    await flutterTts.stop();
    await flutterTts.speak(questions[currentQuestion]["question"]);
  }

  Future<void> _speakOption(String option) async {
    await flutterTts.stop();
    await flutterTts.speak(option);
  }

  void shuffleOptions() {
    shuffledOptions = List<String>.from(questions[currentQuestion]["options"]);
    shuffledOptions.shuffle(Random());
  }

  void checkAnswer(String selectedOption) async {
    await flutterTts.stop();

    if (selectedOption == questions[currentQuestion]["answer"]) {
      score++;
      await flutterTts.speak("Correct");
    } else {
      await flutterTts.speak("Wrong");
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        shuffleOptions();
      });
      await Future.delayed(const Duration(milliseconds: 500));
      speakQuestion();
    } else {
      _showResultDialog();
    }
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
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 80),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCE5FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          questionData["question"],
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          questionData["image"],
                          fit: BoxFit.contain,
                          height: 250,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children:
                            shuffledOptions.map((option) {
                              return GestureDetector(
                                onTap: () => checkAnswer(option),
                                child: Container(
                                  width: isSmall ? screenSize.width * 0.8 : 300,
                                  child: ElevatedButton(
                                    onPressed: () => checkAnswer(option),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      minimumSize: const Size(
                                        double.infinity,
                                        70,
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFF66B3FF),
                                        width: 3,
                                      ),
                                      shadowColor: Colors.grey.shade300,
                                      elevation: 5,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            option,
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.volume_up,
                                            color: Colors.black87,
                                            size: 30,
                                          ),
                                          onPressed: () => _speakOption(option),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.volume_up),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4D94FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          speakQuestion();
                        },
                        label: const Text(
                          "Repeat Question",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 40),
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
}
