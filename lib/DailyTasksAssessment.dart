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

class _DailyTasksAssessmentState extends State<DailyTasksAssessment>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late VideoPlayerController _videoController;
  late ConfettiController _confettiController;
  late AnimationController _shakeController;

  int currentIndex = 0;
  int score = 0;
  List<Map<String, String>> reflections = [];
  String? selectedAnswer;

  bool answered = false;
  String? correctAnswer;

  final List<Map<String, dynamic>> questions = [
    {
      'video': 'assets/videos/wake.mp4',
      'question': 'What did Maria do first?',
      'answer': 'woke up early',
      'options': ['woke up early', 'went to bed', 'ate breakfast'],
    },
    {
      'video': 'assets/videos/sweep.mp4',
      'question': 'What did she use to sweep the room?',
      'answer': 'broom',
      'options': ['broom', 'mop', 'vacuum'],
    },
    {
      'video': 'assets/videos/wash.mp4',
      'question': 'What did Maria use to wash the dishes?',
      'answer': 'soap and water',
      'options': ['soap and water', 'sponge', 'detergent'],
    },
    {
      'video': 'assets/videos/drinking.mp4',
      'question': 'What did Maria drink?',
      'answer': 'cold water',
      'options': ['cold water', 'hot tea', 'juice'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _initializeVideo();
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.asset(questions[currentIndex]['video'])
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

  void _speakOption(String option) async {
    await flutterTts.stop();
    await flutterTts.speak(option);
  }

  void _checkAnswer(String option) async {
    if (answered) return;

    setState(() {
      selectedAnswer = option;
      correctAnswer = questions[currentIndex]['answer'];
      answered = true;
    });

    if (option.toLowerCase() == correctAnswer!.toLowerCase()) {
      score++;
      await flutterTts.speak("Correct");
      Future.delayed(const Duration(seconds: 1), _nextQuestion);
    } else {
      await flutterTts.speak("Wrong");
      _shakeController.forward(from: 0);
      Future.delayed(const Duration(seconds: 1), _nextQuestion);
    }

    reflections.add({
      'question': questions[currentIndex]['question'],
      'userAnswer': option,
      'correctAnswer': correctAnswer!,
    });
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
        answered = false;
        correctAnswer = null;
        _initializeVideo();
      });
    } else {
      _confettiController.play();
      _showCompletionDialog();
    }
  }

  void _resetAssessment() {
    setState(() {
      currentIndex = 0;
      score = 0;
      reflections.clear();
      selectedAnswer = null;
      answered = false;
      correctAnswer = null;
      _initializeVideo();
    });
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
                        onPressed: () async {
                          Navigator.pop(context);
                          Navigator.pop(context);
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
              colors: const [Color(0xFF5DB2FF), Color(0xFF4A4E69), Color(0xFF22223B)],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 60, color: Color(0xFF5DB2FF)),
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
                        style: const TextStyle(
                            fontSize: 22, color: Color(0xFF4A4E69)),
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
                        itemCount: reflections.length,
                        itemBuilder: (_, index) {
                          final item = reflections[index];
                          final isCorrect =
                              item['userAnswer'] == item['correctAnswer'];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: isCorrect
                                ? const Color(0xFFD6FFE0)
                                : const Color(0xFFFFD6D6),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    isCorrect ? Colors.green : Colors.red,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                "${item['question']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your Answer: ${item['userAnswer']}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: isCorrect
                                            ? Colors.green[800]
                                            : Colors.red[800]),
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxVideoWidth = screenWidth > 600 ? 600.0 : screenWidth * 0.9;
    final options = questions[currentIndex]['options'] as List<String>;

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
                        padding:
                            const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Close",
                          style: TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _resetAssessment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A4E69),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Reset",
                          style: TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
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
                      const SizedBox(height: 40),
                      ...options.map(
                        (option) {
                          Color bgColor = const Color(0xFF648BA2);
                          if (answered) {
                            if (option == selectedAnswer) {
                              bgColor = (option == correctAnswer)
                                  ? Colors.green
                                  : Colors.red;
                            }
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: AnimatedBuilder(
                              animation: _shakeController,
                              builder: (context, child) {
                                double offset = 0;
                                if (answered &&
                                    selectedAnswer == option &&
                                    selectedAnswer != correctAnswer) {
                                  offset = 8 * (1 - _shakeController.value * 2);
                                }
                                return Transform.translate(
                                  offset: Offset(offset, 0),
                                  child: ElevatedButton(
                                    onPressed: () => _checkAnswer(option),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: bgColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 20),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      minimumSize: const Size(double.infinity, 70),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            option,
                                            style: const TextStyle(
                                                fontSize: 20, color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.volume_up,
                                              color: Colors.white, size: 28),
                                          onPressed: () => _speakOption(option),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
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
    _videoController.dispose();
    flutterTts.stop();
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
}
