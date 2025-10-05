  // Imports
  import 'dart:math';
  import 'package:flutter/material.dart';
  import 'package:flutter_tts/flutter_tts.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:confetti/confetti.dart';
  import 'ReadingMaterialsPage.dart';

  class AlphabetAssessment extends StatefulWidget {
    const AlphabetAssessment({super.key});

    @override
    State<AlphabetAssessment> createState() => _AlphabetAssessmentState();
  }

  class _AlphabetAssessmentState extends State<AlphabetAssessment>
      with TickerProviderStateMixin {
    final FlutterTts flutterTts = FlutterTts();
    final TextEditingController _controller = TextEditingController();

    int currentQuestion = 0;
    int score = 0;
    bool isOptionDisabled = false;
    bool isSpeaking = false;

    late AnimationController _waveController;
    late AnimationController _borderAnimationController;
    late ConfettiController _confettiController;
    Color borderColor = const Color(0xFF5DB2FF);

    final List<Map<String, dynamic>> questions = [
      {"letter": "A", "answer": "A"},
      {"letter": "E", "answer": "E"},
      {"letter": "M", "answer": "M"},
      {"letter": "T", "answer": "T"},
      {"letter": "Z", "answer": "Z"},
    ];

    List<Map<String, String>> reflection = [];

    @override
    void initState() {
      super.initState();
      setupTts();

      _waveController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      );

      _borderAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _borderAnimationController.reverse();
          }
        });

      _confettiController =
          ConfettiController(duration: const Duration(seconds: 3));
      loadProgress().then((_) => speakQuestion());
    }

    @override
    void dispose() {
      flutterTts.stop();
      _waveController.dispose();
      _borderAnimationController.dispose();
      _confettiController.dispose();
      super.dispose();
    }

    void setupTts() {
      flutterTts.setLanguage("en-US");
      flutterTts.setPitch(1.0);
      flutterTts.setSpeechRate(0.45);

      flutterTts.setStartHandler(() {
        setState(() => isSpeaking = true);
        _waveController.repeat();
      });

      flutterTts.setCompletionHandler(() {
        setState(() => isSpeaking = false);
        _waveController.stop();
      });

      flutterTts.setErrorHandler((msg) {
        setState(() => isSpeaking = false);
        _waveController.stop();
      });
    }

    Future<void> loadProgress() async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        currentQuestion = prefs.getInt('alphabet_currentQuestion') ?? 0;
        score = prefs.getInt('alphabet_score') ?? 0;
      });
    }

    Future<void> saveProgress() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('alphabet_currentQuestion', currentQuestion);
      await prefs.setInt('alphabet_score', score);
    }

    Future<void> clearProgress() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('alphabet_currentQuestion');
      await prefs.remove('alphabet_score');
    }

    Future<void> speak(String text) async {
      if (isSpeaking) await flutterTts.stop();
      await flutterTts.speak(text);
    }

    Future<void> speakQuestion() async {
      await flutterTts.stop();
      await speak("Listen carefully.");
      await Future.delayed(const Duration(milliseconds: 500));
      await speak(questions[currentQuestion]["letter"]);
    }

    void checkAnswer() async {
      if (isOptionDisabled) return;

      final userAnswer = _controller.text.trim().toUpperCase();
      if (userAnswer.isEmpty) {
        await speak("Please enter a letter before submitting.");
        return;
      }

      setState(() => isOptionDisabled = true);
      await flutterTts.stop();

      final correctAnswer = questions[currentQuestion]["answer"];
      final isCorrect = userAnswer == correctAnswer;

      reflection.add({
        'question': questions[currentQuestion]["letter"],
        'userAnswer': userAnswer,
        'correctAnswer': correctAnswer,
      });

      setState(() {
        borderColor = isCorrect ? Colors.green : Colors.red;
      });
      _borderAnimationController.forward();

      if (isCorrect) {
        await speak("Correct! Well done.");
        score++;
      } else {
        await speak("Wrong. The correct answer is $correctAnswer.");
      }

      await saveProgress();

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        borderColor = const Color(0xFF5DB2FF);
      });

      if (currentQuestion < questions.length - 1) {
        setState(() {
          currentQuestion++;
          _controller.clear();
          isOptionDisabled = false;
        });
        await Future.delayed(const Duration(milliseconds: 500));
        await speakQuestion();
      } else {
        await clearProgress();
        _confettiController.play();
        await Future.delayed(const Duration(milliseconds: 400));
        _showCompletionDialog();
      }
    }

    void _resetAssessment() async {
      await clearProgress();
      setState(() {
        currentQuestion = 0;
        score = 0;
        isOptionDisabled = false;
        _controller.clear();
        reflection.clear();
        borderColor = const Color(0xFF5DB2FF);
      });
      await speakQuestion();
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
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 60,
                    color: Color(0xFFFF6B6B),
                  ),
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
                            await saveProgress();
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
                colors: const [
                  Color(0xFF5DB2FF),
                  Color(0xFF4A4E69),
                  Color(0xFF22223B)
                ],
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
                          itemCount: reflection.length,
                          itemBuilder: (_, index) {
                            final item = reflection[index];
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
                                  "Letter: ${item['question']}",
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
                                    builder: (_) => Readingmaterialspage()),
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

    Widget buildWaveform() {
      return Center(
        child: SizedBox(
          height: 150,
          width: 650,
          child: AnimatedBuilder(
            animation: _waveController,
            builder: (_, __) =>
                CustomPaint(painter: WaveformPainter(_waveController.value)),
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      final isSmall = MediaQuery.of(context).size.width < 600;

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _showSkipConfirmation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22223B),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 36, vertical: 20),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 36, vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text("Reset",
                            style: TextStyle(fontSize: 24, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                buildWaveform(),
                const SizedBox(height: 20),

                // === PAGE NUMBER DISPLAY ===
                Text(
                  "Question ${currentQuestion + 1} of ${questions.length}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: isSpeaking ? null : speakQuestion,
                  icon: const Icon(Icons.replay_rounded, size: 36, color: Colors.white),
                  label: const Text(
                    "Repeat Sound",
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5DB2FF),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),

                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _borderAnimationController,
                  builder: (context, child) {
                    final glow = (sin(_borderAnimationController.value * pi) + 0.5) * 4;
                    return Column(
                      children: [
                        Container(
                          width: isSmall ? 320 : 400,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderColor, width: glow),
                          ),
                          child: child,
                        ),
                        const SizedBox(height: 8),
                        if (isOptionDisabled &&
                            _controller.text.toUpperCase() !=
                                questions[currentQuestion]["answer"])
                          Text(
                            "Correct Answer: ${questions[currentQuestion]["answer"]}",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    );
                  },
                  child: TextField(
                    controller: _controller,
                    enabled: !isOptionDisabled,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 1,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3A405A)),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "Enter letter",
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => checkAnswer(),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 240,
                  height: 80,
                  child: ElevatedButton(
                    onPressed: isOptionDisabled ? null : checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5DB2FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }
  }

  // === Waveform Painter ===
  class WaveformPainter extends CustomPainter {
    final double progress;
    WaveformPainter(this.progress);

    @override
    void paint(Canvas canvas, Size size) {
      final Paint paint = Paint()
        ..color = const Color(0xFF5DB2FF)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final centerY = size.height / 2;
      final waveWidth = size.width / 30;

      for (int i = 0; i < 30; i++) {
        final dx = waveWidth * i;
        final height = sin(progress * 2 * pi + i * 0.5) * 20 + 30;
        canvas.drawLine(
            Offset(dx, centerY - height / 2),
            Offset(dx, centerY + height / 2),
            paint);
      }
    }

    @override
    bool shouldRepaint(covariant WaveformPainter oldDelegate) =>
        oldDelegate.progress != progress;
  }
