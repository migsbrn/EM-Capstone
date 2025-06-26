import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

class MorningRoutineAssessment extends StatefulWidget {
  final String nickname;
  const MorningRoutineAssessment({Key? key, required this.nickname})
    : super(key: key);

  @override
  State<MorningRoutineAssessment> createState() =>
      _MorningRoutineAssessmentState();
}

class _MorningRoutineAssessmentState extends State<MorningRoutineAssessment> {
  final FlutterTts flutterTts = FlutterTts();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();
  int currentQuestion = 0;
  int score = 0;
  bool isOptionDisabled = false;
  bool isSpeaking = false;
  late ConfettiController _confettiController;

  final List<Map<String, dynamic>> questions = [
    {"task": "Wash my face upon waking up.", "answer": "wash face"},
    {"task": "Brush my teeth three times daily.", "answer": "brush teeth"},
    {"task": "Take a bath daily.", "answer": "take bath"},
    {"task": "Wear clean clothes.", "answer": "wear clean clothes"},
    {"task": "Sleep early at night.", "answer": "sleep early"},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    setupTts();
    loadProgress().then((_) {
      speakQuestion();
    });
  }

  void setupTts() {
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.45);
    flutterTts.setStartHandler(() {
      setState(() => isSpeaking = true);
    });
    flutterTts.setCompletionHandler(() {
      setState(() => isSpeaking = false);
    });
    flutterTts.setErrorHandler((msg) {
      setState(() => isSpeaking = false);
    });
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentQuestion = prefs.getInt('morning_currentQuestion') ?? 0;
      score = prefs.getInt('morning_score') ?? 0;
    });
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('morning_currentQuestion', currentQuestion);
    await prefs.setInt('morning_score', score);
  }

  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('morning_currentQuestion');
    await prefs.remove('morning_score');
  }

  Future<void> speak(String text) async {
    if (isSpeaking) await flutterTts.stop();
    await flutterTts.speak(text);
  }

  Future<void> speakQuestion() async {
    await flutterTts.stop();
    await speak("What should I do? ${questions[currentQuestion]["task"]}");
  }

  void checkAnswer() async {
    if (isOptionDisabled) return;

    final userAnswer = _controller.text.trim().toLowerCase();

    if (userAnswer.isEmpty) {
      await speak("Please enter an answer before submitting.");
      return;
    }

    setState(() {
      isOptionDisabled = true;
    });

    await flutterTts.stop();

    if (userAnswer == questions[currentQuestion]["answer"]) {
      await speak("Correct! Good job!");
      _confettiController.play();
      score++;
    } else {
      await speak(
        "Wrong. The correct answer is ${questions[currentQuestion]["answer"]}",
      );
    }

    await saveProgress();

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        _controller.clear();
        isOptionDisabled = false;
      });
      await Future.delayed(const Duration(milliseconds: 800));
      await speakQuestion();
    } else {
      await _saveResult();
      await clearProgress();
      await Future.delayed(const Duration(milliseconds: 400));
      _showCompletionDialog();
    }
  }

  Future<void> _saveResult({
    String status = 'Completed',
    bool passed = false,
  }) async {
    await firestore.collection('functionalAssessments').add({
      'nickname': widget.nickname,
      'assessmentType': 'MorningRoutine',
      'score': score,
      'totalQuestions': questions.length,
      'status': status,
      'passed': status == 'Completed' ? score >= questions.length / 2 : passed,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _showSkipConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
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
                fontSize: 20,
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
                    backgroundColor: const Color(0xFF5DB2FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      color: Colors.white,
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () async {
                    await _saveResult(status: 'Skipped', passed: false);
                    await clearProgress();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Yes, Skip",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
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

  void _resetAssessment() async {
    await clearProgress();
    setState(() {
      currentQuestion = 0;
      score = 0;
      isOptionDisabled = false;
      _controller.clear();
    });
    await speakQuestion();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 10,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                  ),
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.amber,
                    size: 96,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Great Job!",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Your score: $score / ${questions.length}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      color: Color(0xFF34495E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5DB2FF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Back to Learning",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
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
        backgroundColor: const Color(0xFFFFF6DC),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _showSkipConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22223B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _resetAssessment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A4E69),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Morning Routine Assessment",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Color(0xFF3A405A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        questionData["task"],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Color(0xFF3A405A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: isSmall ? 280 : 360,
                        child: TextField(
                          controller: _controller,
                          enabled: !isOptionDisabled,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Color(0xFF3A405A),
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter answer",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onSubmitted: (_) => checkAnswer(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 160,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isOptionDisabled ? null : checkAnswer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5DB2FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
}
