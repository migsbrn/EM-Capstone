import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:video_player/video_player.dart';
import 'package:confetti/confetti.dart';
import 'ReadingMaterialsPage.dart';

class DailyTasksAssessment extends StatefulWidget {
  const DailyTasksAssessment({super.key});

  @override
  State<DailyTasksAssessment> createState() => _DailyTasksAssessmentState();
}

class _DailyTasksAssessmentState extends State<DailyTasksAssessment> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _controller = TextEditingController();
  late VideoPlayerController _videoController;
  late ConfettiController _confettiController;
  int currentIndex = 0;
  int score = 0;
  List<Map<String, String>> reflections = [];

  final List<Map<String, dynamic>> questions = [
    {
      'video': 'assets/videos/wake.mp4',
      'question': 'What did Maria do first?',
      'answer': 'woke up early',
    },
    {
      'video': 'assets/videos/sweep.mp4',
      'question': 'What did she use to sweep the room?',
      'answer': 'broom',
    },
    {
      'video': 'assets/videos/wash.mp4',
      'question': 'What did Maria use to wash the dishes?',
      'answer': 'soap and water',
    },
    {
      'video': 'assets/videos/drinking.mp4',
      'question': 'What did Maria drink?',
      'answer': 'cold water',
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _initializeVideo();
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.asset(
        questions[currentIndex]['video'],
      )
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
        _videoController.setLooping(false);
        _speakQuestion();
      });
  }

  Future<void> _speakQuestion() async {
    await flutterTts.stop();
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.2);
    await flutterTts.speak(questions[currentIndex]['question']);
  }

  void _checkAnswer() async {
    final userAnswer = _controller.text.trim().toLowerCase();
    final correctAnswer = questions[currentIndex]['answer'].toLowerCase();

    await flutterTts.stop();
    if (userAnswer == correctAnswer) {
      score++;
      await flutterTts.speak("Correct");
    } else {
      await flutterTts.speak("Wrong");
    }

    reflections.add({
      'question': questions[currentIndex]['question'],
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
    });

    await Future.delayed(const Duration(seconds: 2));

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        _controller.clear();
        _initializeVideo();
      });
    } else {
      _confettiController.play();
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
            backgroundColor: const Color(0xFFF7F9FC),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  numberOfParticles: 25,
                  colors: const [
                    Colors.red,
                    Colors.green,
                    Colors.blue,
                    Colors.orange,
                    Colors.purple,
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: SingleChildScrollView(
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
                          const SizedBox(height: 20),
                          const Text(
                            "Answer Summary",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reflections.length,
                            itemBuilder: (_, index) {
                              final item = reflections[index];
                              final isCorrect =
                                  item['userAnswer'] == item['correctAnswer'];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        isCorrect
                                            ? Colors.green[50]
                                            : Colors.red[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color:
                                          isCorrect ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Q: ${item['question']}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Your Answer: ${item['userAnswer']}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              isCorrect
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                      ),
                                      if (!isCorrect)
                                        Text(
                                          "Correct Answer: ${item['correctAnswer']}",
                                          style: const TextStyle(fontSize: 18),
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
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5DB2FF),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
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
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
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
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              "Are you sure you want to skip the assessment?",
              style: TextStyle(fontSize: 22, color: Colors.black87),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final maxVideoWidth = screenWidth > 600 ? 600.0 : screenWidth * 0.9;

    return WillPopScope(
      onWillPop: () async {
        _showSkipConfirmation();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EAD5),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
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
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    questions[currentIndex]['question'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_videoController.value.isInitialized)
                    Center(
                      child: Container(
                        width: maxVideoWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black12,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AspectRatio(
                          aspectRatio: _videoController.value.aspectRatio,
                          child: VideoPlayer(_videoController),
                        ),
                      ),
                    )
                  else
                    const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 32),
                  Center(
                    child: SizedBox(
                      width: screenWidth > 600 ? 400 : screenWidth * 0.85,
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Type your answer here...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: screenWidth > 600 ? 200 : screenWidth * 0.6,
                      child: ElevatedButton(
                        onPressed: _checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF648BA2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
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

  @override
  void dispose() {
    _videoController.dispose();
    _controller.dispose();
    flutterTts.stop();
    _confettiController.dispose();
    super.dispose();
  }
}
